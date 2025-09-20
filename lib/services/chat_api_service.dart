import 'package:uuid/uuid.dart';
import '../apis/endpoint.dart';
import '../models/chat_request.dart';
import '../models/chat_response.dart';
import '../models/chat_paging_response.dart';
import '../utils/api_error.dart';
import 'service.dart';

class ChatApiService {
  static final ChatApiService _instance = ChatApiService._internal();
  factory ChatApiService() => _instance;
  ChatApiService._internal();

  final ApiService _apiService = ApiService();
  final Uuid _uuid = const Uuid();
  static const int _retryMaxAttempts = 3; // 1 lần + 2 retry
  static const Duration _retryBaseDelay = Duration(milliseconds: 300);

  Future<T> _withRetry<T>(Future<T> Function() action) async {
    int attempt = 0;
    while (true) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (e is ApiError) {
          final code = e.statusCode;
          if (code != null && code >= 400 && code < 500) {
            // Lỗi 4xx không retry
            rethrow;
          }
        }
        if (attempt >= _retryMaxAttempts) rethrow;
        final delay = _retryBaseDelay * (1 << (attempt - 1)); // 300ms, 600ms, 1200ms
        await Future.delayed(delay);
      }
    }
  }

  /// Initialize guest conversation
  /// POST /apis/v1/chat/init-guest
  /// Returns: Long conversationId
  Future<int> initGuest() async {
    try {
      final response = await _withRetry(() => _apiService.post(
            ApiEndpoints.initGuest,
            includeAuth: false, // Guest không cần auth
          ));
      
      // BE trả về Long, Flutter nhận int
      if (response is int) {
        return response;
      } else if (response is String) {
        return int.parse(response);
      } else if (response is Map<String, dynamic> && response.containsKey('conversationId')) {
        return response['conversationId'] as int;
      } else {
        throw ApiError(message: 'Unexpected response format from init-guest API', statusCode: 500);
      }
    } on ApiError catch (e) {
      throw e;
    } catch (e) {
      throw ApiError(message: 'Failed to initialize guest conversation: ${e.toString()}', statusCode: 500);
    }
  }

  /// Send message
  /// POST /apis/v1/chat/send?customerId={id}&employeeId={id}
  /// Body: ChatRequest
  /// Returns: ChatResponse
  Future<ChatResponse> sendMessage(
    ChatRequest request, {
    int? customerId,
    int? employeeId,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (customerId != null) queryParams['customerId'] = customerId.toString();
      if (employeeId != null) queryParams['employeeId'] = employeeId.toString();
      
      String url = ApiEndpoints.send;
      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        final newUri = uri.replace(queryParameters: queryParams);
        url = newUri.toString();
      }

      final response = await _withRetry(() => _apiService.post(
            url,
            body: request.toJson(),
            includeAuth: customerId != null, // Cần auth nếu có customerId
          ));

      return ChatResponse.fromJson(response as Map<String, dynamic>);
    } on ApiError catch (e) {
      throw e;
    } catch (e) {
      throw ApiError(message: 'Failed to send message: ${e.toString()}', statusCode: 500);
    }
  }

  /// Send message with auto-generated idempotency key
  Future<ChatResponse> sendMessageWithDedup(
    String content, {
    int? conversationId,
    int? customerId,
    int? employeeId,
    String lang = 'vi',
  }) async {
    final idempotencyKey = _uuid.v4();
    final request = ChatRequest.customer(
      content: content,
      conversationId: conversationId,
      lang: lang,
      idempotencyKey: idempotencyKey,
    );

    return sendMessage(request, customerId: customerId, employeeId: employeeId);
  }

  /// Get messages with pagination
  /// GET /apis/v1/chat/messages-paged?conversationId={id}&page={page}&size={size}
  /// Returns: ChatPagingResponse<ChatResponse>
  Future<ChatPagingResponse<ChatResponse>> getMessagesPaged(
    int conversationId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final uri = Uri.parse(ApiEndpoints.messagesPaged).replace(
        queryParameters: {
          'conversationId': conversationId.toString(),
          'page': page.toString(),
          'size': size.toString(),
        },
      );

      final response = await _withRetry(() => _apiService.get(uri.toString()));
      return ChatPagingResponse.chatFromJson(response as Map<String, dynamic>);
    } on ApiError catch (e) {
      throw e;
    } catch (e) {
      throw ApiError(message: 'Failed to get messages: ${e.toString()}', statusCode: 500);
    }
  }

  /// Get all messages for a conversation
  /// GET /apis/v1/chat/messages?conversationId={id}
  /// Returns: List<ChatResponse>
  Future<List<ChatResponse>> getMessages(int conversationId) async {
    try {
      final uri = Uri.parse(ApiEndpoints.messages).replace(
        queryParameters: {
          'conversationId': conversationId.toString(),
        },
      );

      final response = await _withRetry(() => _apiService.get(uri.toString()));
      
      if (response is List) {
        return response
            .map((item) => ChatResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiError(message: 'Unexpected response format from messages API', statusCode: 500);
      }
    } on ApiError catch (e) {
      throw e;
    } catch (e) {
      throw ApiError(message: 'Failed to get messages: ${e.toString()}', statusCode: 500);
    }
  }

  /// Get conversations for customer
  /// GET /apis/v1/chat/conversations?customerId={id}
  /// Returns: List<Long> (conversation IDs)
  Future<List<int>> getConversations(int customerId) async {
    try {
      final uri = Uri.parse(ApiEndpoints.conversations).replace(
        queryParameters: {
          'customerId': customerId.toString(),
        },
      );

      final response = await _withRetry(() => _apiService.get(uri.toString()));
      
      if (response is List) {
        return response.cast<int>();
      } else {
        throw ApiError(message: 'Unexpected response format from conversations API', statusCode: 500);
      }
    } on ApiError catch (e) {
      throw e;
    } catch (e) {
      throw ApiError(message: 'Failed to get conversations: ${e.toString()}', statusCode: 500);
    }
  }

  /// Mark messages as read
  /// POST /apis/v1/chat/mark-read?conversationId={id}
  /// Returns: 200 OK
  Future<void> markRead(int conversationId) async {
    try {
      final uri = Uri.parse(ApiEndpoints.markRead).replace(
        queryParameters: {
          'conversationId': conversationId.toString(),
        },
      );

      await _withRetry(() => _apiService.post(uri.toString()));
    } on ApiError catch (e) {
      throw e;
    } catch (e) {
      throw ApiError(message: 'Failed to mark messages as read: ${e.toString()}', statusCode: 500);
    }
  }

  /// Get conversation status (for debugging)
  /// GET /apis/v1/chat/status?conversationId={id}
  /// Returns: String status ("AI", "EMP", "WAITING_EMP")
  Future<String> getConversationStatus(int conversationId) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.chatRoot}/status').replace(
        queryParameters: {
          'conversationId': conversationId.toString(),
        },
      );

      final response = await _withRetry(() => _apiService.get(uri.toString()));
      
      if (response is String) {
        return response;
      } else {
        throw ApiError(message: 'Unexpected response format from status API', statusCode: 500);
      }
    } on ApiError catch (e) {
      throw e;
    } catch (e) {
      throw ApiError(message: 'Failed to get conversation status: ${e.toString()}', statusCode: 500);
    }
  }

  /// Helper: Generate idempotency key for message deduplication
  String generateIdempotencyKey() {
    return _uuid.v4();
  }

  /// Helper: Check if content is a special command
  bool isSpecialCommand(String content) {
    final trimmed = content.trim().toLowerCase();
    return trimmed == '/meet_emp' || trimmed == '/backtoai';
  }

  /// Helper: Validate message content before sending
  String? validateMessage(String content) {
    if (content.trim().isEmpty) {
      return 'Message content cannot be empty';
    }
    if (content.length > 1000) {
      return 'Message too long (max 1000 characters)';
    }
    return null;
  }
}
