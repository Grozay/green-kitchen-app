import 'chat_response.dart';

class ChatPagingResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool isLast;

  ChatPagingResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.isLast,
  });

  factory ChatPagingResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ChatPagingResponse<T>(
      content: (json['content'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 0,
      size: json['size'] ?? 20,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      isLast: json['isLast'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'page': page,
      'size': size,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'isLast': isLast,
    };
  }

  // Helper for ChatResponse specifically
  static ChatPagingResponse<ChatResponse> chatFromJson(Map<String, dynamic> json) {
    return ChatPagingResponse<ChatResponse>.fromJson(json, ChatResponse.fromJson);
  }
}
