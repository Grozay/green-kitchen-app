import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/chat_response.dart';
import '../models/chat_request.dart';
import '../services/chat_api_service.dart';
import '../services/chat_websocket_service.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class ChatProvider extends ChangeNotifier {
  final ChatApiService _api = ChatApiService();
  final ChatWebSocketService _ws = ChatWebSocketService();
  StreamSubscription<ChatResponse>? _wsSubscription;
  BuildContext? _context;
  VoidCallback? _onNewMessage;

  int? _conversationId;
  bool _loading = false;
  bool _connecting = false;
  String? _error;
  bool _aiTyping = false;

  final List<ChatResponse> _messages = [];
  final Set<int> _messageIds = {}; // dedupe theo id
  int _currentPage = 0;
  bool _isLast = false;
  bool _loadingMore = false;

  int? get conversationId => _conversationId;
  bool get loading => _loading;
  bool get connecting => _connecting;
  String? get error => _error;
  bool get aiTyping => _aiTyping;
  UnmodifiableListView<ChatResponse> get messages => UnmodifiableListView(_messages);
  bool get loadingMore => _loadingMore;

  Future<void> initAndConnect(BuildContext context, {int? initialConversationId}) async {
    _context = context;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Init conversation (chỉ tạo mới nếu chưa có)
      if (_conversationId == null) {
        _conversationId = initialConversationId ?? await _api.initGuest();
        debugPrint('🆕 Created new conversation: $_conversationId');
      } else {
        debugPrint('♻️ Reusing existing conversation: $_conversationId');
      }

      // 2. Load messages paged (page 0) - chỉ load nếu chưa có tin nhắn
      if (_messages.isEmpty) {
        debugPrint('📥 Loading initial messages for conversation $_conversationId');
        final page = await _api.getMessagesPaged(_conversationId!, page: 0, size: 20);
        debugPrint('📥 Loaded ${page.content.length} messages');
        _messages.addAll(page.content);
        for (final m in page.content) {
          if (m.id != null) _messageIds.add(m.id!);
          debugPrint('📝 Message: ${m.content} from ${m.senderRole}');
        }
        _currentPage = 0;
        _isLast = page.isLast;
      } else {
        debugPrint('♻️ Messages already loaded, skipping initial load');
      }

      // 3. Connect WS và subscribe
      _connecting = true;
      notifyListeners();
      await _ws.connect();
      
      // Đợi một chút để WebSocket kết nối hoàn toàn
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('🔗 Attempting to subscribe to conversation $_conversationId');
      _ws.subscribeConversation(_conversationId!);
      // Hủy subscription cũ nếu có để tránh leak/duplicate
      await _wsSubscription?.cancel();
      _wsSubscription = _ws.messages.listen((msg) {
        debugPrint('🔔 Received message via WS: ${msg.content} from ${msg.senderRole}');
        
        // Xử lý tin nhắn theo từng loại
        if (msg.senderRole == 'CUSTOMER') {
          // CUSTOMER: Thay thế tin nhắn tạm thời hoặc thêm mới
          final tempIndex = _messages.indexWhere((m) => m.id == -1 && m.content == msg.content);
          if (tempIndex != -1) {
            _messages[tempIndex] = msg;
            debugPrint('🔄 Replaced temp CUSTOMER message with real message');
          } else {
            _messages.add(msg);
            debugPrint('✅ Added new CUSTOMER message');
          }
        } else if (msg.senderRole == 'AI') {
          // AI: Chỉ thêm tin nhắn có content
          debugPrint('🤖 Processing AI message: content="${msg.content}", isEmpty=${msg.content.isEmpty}');
          if (msg.content.isNotEmpty) {
            _messages.add(msg);
            debugPrint('✅ Added AI message: "${msg.content}"');
          } else {
            debugPrint('⚠️ Skipped AI message with empty content');
          }
        } else if (msg.senderRole == 'EMP') {
          // EMP: Luôn thêm mới (không replace)
          _messages.add(msg);
          debugPrint('✅ Added EMP message: "${msg.content}" from ${msg.senderName}');
        } else {
          // Các loại khác: Thêm mới
          _messages.add(msg);
          debugPrint('✅ Added ${msg.senderRole} message: "${msg.content}"');
        }
        
        if (msg.id != null) _messageIds.add(msg.id!);
        
        // Xử lý typing indicator cho AI
        if (msg.senderRole == 'AI') {
          if (msg.status == 'PENDING' && msg.content.isEmpty) {
            // Bắt đầu typing khi nhận tin nhắn PENDING rỗng từ AI
            // KHÔNG thêm tin nhắn rỗng vào danh sách
            _aiTyping = true;
            debugPrint('🤖 AI typing started - received PENDING message');
            notifyListeners(); // Chỉ notify để hiển thị typing indicator
            return; // Không thêm tin nhắn rỗng vào danh sách
          } else if (msg.status == 'SENT' && msg.content.isNotEmpty) {
            // Dừng typing khi nhận tin nhắn SENT có content từ AI
            _aiTyping = false;
            debugPrint('🤖 AI typing stopped - received SENT message with content');
          }
        }
        
        // Debug cho tin nhắn EMP
        if (msg.senderRole == 'EMP') {
          debugPrint('👨‍💼 EMP message received: ID=${msg.id}, content="${msg.content}", from=${msg.senderName}');
        }
        
        debugPrint('📝 Total messages: ${_messages.length}');
        debugPrint('📝 Messages list: ${_messages.map((m) => '${m.senderRole}: ${m.content}').join(', ')}');
        notifyListeners();
        
        // Trigger auto-scroll nếu có tin nhắn mới
        _triggerAutoScroll();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _connecting = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (_conversationId == null) return;
    final validation = _api.validateMessage(content);
    if (validation != null) {
      _error = validation;
      notifyListeners();
      return;
    }

    try {
      // Lấy customerId từ AuthProvider
      final customerId = _getCustomerId();
      debugPrint('📤 Sending message: "$content" with customerId: $customerId');
      
      // Thêm tin nhắn tạm thời để hiển thị ngay
      final tempMessage = ChatResponse(
        id: -1, // ID tạm thời
        conversationId: _conversationId,
        senderRole: 'CUSTOMER',
        senderName: 'Bạn',
        content: content,
        timestamp: DateTime.now(),
        status: 'SENDING',
      );
      _messages.add(tempMessage);
      notifyListeners();
      debugPrint('📝 Added temp message, total: ${_messages.length}');
      
      final req = ChatRequest.customer(
        content: content,
        conversationId: _conversationId,
        idempotencyKey: _api.generateIdempotencyKey(),
      );
      await _api.sendMessage(req, customerId: customerId);
      debugPrint('✅ Message sent successfully');
      
      // Timeout typing indicator sau 30 giây (fallback nếu không nhận được response)
      Future.delayed(const Duration(seconds: 30), () {
        if (_aiTyping) {
          _aiTyping = false;
          notifyListeners();
          debugPrint('🤖 AI typing timeout - stopped');
        }
      });
      
      // Kiểm tra WebSocket connection và subscription
      debugPrint('🔍 WebSocket connected: ${_ws.isConnected}');
      debugPrint('🔍 Conversation ID: $_conversationId');
      
      // Cập nhật trạng thái tin nhắn tạm
      final index = _messages.indexWhere((m) => m.id == -1 && m.content == content);
      if (index != -1) {
        _messages[index] = ChatResponse(
          id: -1,
          conversationId: _conversationId,
          senderRole: 'CUSTOMER',
          senderName: 'Bạn',
          content: content,
          timestamp: DateTime.now(),
          status: 'SENT',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markRead() async {
    if (_conversationId == null) return;
    try {
      await _api.markRead(_conversationId!);
    } catch (_) {}
  }

  Future<void> loadMoreMessages() async {
    if (_conversationId == null) return;
    if (_loadingMore || _isLast) return;
    _loadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final page = await _api.getMessagesPaged(_conversationId!, page: nextPage, size: 20);
      // prepend older messages (giả định page sau là cũ hơn)
      final List<ChatResponse> newOnes = [];
      for (final m in page.content) {
        if (m.id != null && _messageIds.contains(m.id!)) continue;
        newOnes.add(m);
        if (m.id != null) _messageIds.add(m.id!);
      }
      if (newOnes.isNotEmpty) {
        _messages.insertAll(0, newOnes);
      }
      _currentPage = nextPage;
      _isLast = page.isLast;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> disposeConnection() async {
    if (_conversationId != null) {
      _ws.unsubscribeConversation(_conversationId!);
    }
    await _wsSubscription?.cancel();
    _wsSubscription = null;
    await _ws.disconnect();
    debugPrint('ChatProvider disposed cleanly');
  }

  // Method để disconnect nhưng giữ lại conversation
  Future<void> disconnectButKeepConversation() async {
    if (_conversationId != null) {
      _ws.unsubscribeConversation(_conversationId!);
    }
    await _wsSubscription?.cancel();
    _wsSubscription = null;
    await _ws.disconnect();
    debugPrint('ChatProvider disconnected but kept conversation $_conversationId');
  }

  // Method để subscribe lại khi WebSocket kết nối
  Future<void> resubscribeIfNeeded() async {
    if (_conversationId != null && _ws.isConnected) {
      debugPrint('🔄 Re-subscribing to conversation $_conversationId');
      _ws.subscribeConversation(_conversationId!);
    }
  }

  // Method để bắt đầu conversation mới
  Future<void> startNewConversation() async {
    debugPrint('🆕 Starting new conversation');
    
    // Disconnect WebSocket trước
    if (_conversationId != null) {
      _ws.unsubscribeConversation(_conversationId!);
    }
    await _wsSubscription?.cancel();
    _wsSubscription = null;
    await _ws.disconnect();
    
    // Clear tất cả data
    _conversationId = null;
    _messages.clear();
    _messageIds.clear();
    _currentPage = 0;
    _isLast = false;
    _aiTyping = false;
    _error = null;
    notifyListeners();
  }

  // Method để set callback auto-scroll
  void setOnNewMessageCallback(VoidCallback callback) {
    _onNewMessage = callback;
  }

  // Method để trigger auto-scroll
  void _triggerAutoScroll() {
    if (_onNewMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onNewMessage!();
      });
    }
  }

  // Lấy customerId từ AuthProvider
  int? _getCustomerId() {
    if (_context == null) return null;
    
    try {
      final authProvider = Provider.of<AuthProvider>(_context!, listen: false);
      final user = authProvider.currentUser;
      
      // Lấy customerId từ user.id hoặc customerDetails
      if (user?.id != null) {
        return int.tryParse(user!.id);
      }
      
      // Fallback: lấy từ customerDetails nếu có
      final customerDetails = authProvider.customerDetails;
      if (customerDetails != null && customerDetails['id'] != null) {
        return int.tryParse(customerDetails['id'].toString());
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting customerId: $e');
      return null;
    }
  }
}
