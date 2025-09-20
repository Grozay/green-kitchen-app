import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../constants/app_constants.dart';
import '../models/chat_response.dart';

class ChatWebSocketService {
  static final ChatWebSocketService _instance = ChatWebSocketService._internal();
  factory ChatWebSocketService() => _instance;
  ChatWebSocketService._internal();

  StompClient? _client;
  bool _isConnecting = false;
  final Map<int, StompUnsubscribe> _subscriptions = {}; // conversationId -> unsubscribe
  final StreamController<ChatResponse> _messageStreamController = StreamController.broadcast();

  Stream<ChatResponse> get messages => _messageStreamController.stream;
  bool get isConnected => _client?.connected ?? false;

  Future<void> connect({String? authToken}) async {
    if (_client?.connected == true || _isConnecting) return;
    _isConnecting = true;

    _client = StompClient(
      config: StompConfig.sockJS(
        url: ChatSocketConfig.wsEndpoint,
        reconnectDelay: ChatSocketConfig.reconnectDelay,
        heartbeatOutgoing: ChatSocketConfig.heartbeatOutgoing,
        heartbeatIncoming: ChatSocketConfig.heartbeatIncoming,
        stompConnectHeaders: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        webSocketConnectHeaders: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        onConnect: _onConnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        onDisconnect: _onDisconnect,
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
      ),
    );

    _client!.activate();
    _isConnecting = false;
  }

  void _onConnect(StompFrame frame) {
    print('🔌 WebSocket connected successfully');
    // Re-subscribe tất cả topic khi reconnect
    final existing = Map<int, StompUnsubscribe>.from(_subscriptions);
    _subscriptions.clear();
    for (final entry in existing.entries) {
      print('🔄 Re-subscribing to conversation ${entry.key}');
      subscribeConversation(entry.key);
    }
  }

  void _onStompError(StompFrame frame) {
    print('❌ STOMP Error: ${frame.body}');
  }

  void _onWebSocketError(dynamic error) {
    print('❌ WebSocket Error: $error');
  }

  void _onDisconnect(StompFrame frame) {
    // Giữ subscriptions keys để re-subscribe sau khi reconnect
  }

  // Subscribe vào conversation topic
  void subscribeConversation(int conversationId) {
    if (_client == null || _client!.connected != true) {
      print('❌ Cannot subscribe: WebSocket not connected');
      return;
    }
    if (_subscriptions.containsKey(conversationId)) {
      print('⚠️ Already subscribed to conversation $conversationId');
      return;
    }

    print('📡 Subscribing to conversation $conversationId');
    final unsub = _client!.subscribe(
      destination: '/topic/conversations/$conversationId',
      callback: (StompFrame frame) {
        try {
          final body = frame.body;
          if (body == null || body.isEmpty) {
            print('⚠️ Empty message received');
            return;
          }
          print('📨 Raw message received: $body');
          final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
          final message = ChatResponse.fromJson(data);
          print('📨 Parsed message: ${message.content} from ${message.senderRole}');
          
          // Kiểm tra stream chưa bị đóng trước khi add
          if (!_messageStreamController.isClosed) {
            _messageStreamController.add(message);
          } else {
            print('⚠️ Cannot add message: Stream is closed');
          }
        } catch (e) {
          print('❌ Error parsing message: $e');
        }
      },
    );

    _subscriptions[conversationId] = unsub;
    print('✅ Subscribed to conversation $conversationId');
  }

  void unsubscribeConversation(int conversationId) {
    final unsub = _subscriptions.remove(conversationId);
    if (unsub != null) {
      unsub();
    }
  }

  Future<void> disconnect() async {
    // Hủy tất cả subscriptions
    for (final entry in _subscriptions.entries) {
      entry.value();
    }
    _subscriptions.clear();

    final client = _client;
    _client = null;
    if (client != null && client.connected) {
      client.deactivate();
    }
    
    // Chỉ close stream nếu chưa bị đóng
    if (!_messageStreamController.isClosed) {
      await _messageStreamController.close();
    }
  }

  // no-op helpers
}
