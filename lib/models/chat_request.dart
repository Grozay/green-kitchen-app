class ChatRequest {
  final String content;
  final String senderRole;
  final String? lang;
  final int? conversationId;
  final String? idempotencyKey;

  ChatRequest({
    required this.content,
    required this.senderRole,
    this.lang,
    this.conversationId,
    this.idempotencyKey,
  });

  factory ChatRequest.fromJson(Map<String, dynamic> json) {
    return ChatRequest(
      content: json['content'] ?? '',
      senderRole: json['senderRole'] ?? '',
      lang: json['lang'],
      conversationId: json['conversationId'],
      idempotencyKey: json['idempotencyKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'senderRole': senderRole,
      if (lang != null) 'lang': lang,
      if (conversationId != null) 'conversationId': conversationId,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
    };
  }

  // Helper factory for customer messages
  factory ChatRequest.customer({
    required String content,
    String lang = 'vi',
    int? conversationId,
    String? idempotencyKey,
  }) {
    return ChatRequest(
      content: content,
      senderRole: 'CUSTOMER',
      lang: lang,
      conversationId: conversationId,
      idempotencyKey: idempotencyKey,
    );
  }

  // Helper factory for employee messages
  factory ChatRequest.employee({
    required String content,
    String lang = 'vi',
    int? conversationId,
    String? idempotencyKey,
  }) {
    return ChatRequest(
      content: content,
      senderRole: 'EMP',
      lang: lang,
      conversationId: conversationId,
      idempotencyKey: idempotencyKey,
    );
  }
}
