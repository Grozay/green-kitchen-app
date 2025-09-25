import 'menu_meal_lite_response.dart';

class ChatResponse {
  final int? id;
  final int? conversationId;
  final String senderRole;
  final String? senderName;
  final String content;
  final List<MenuMealLiteResponse>? menu;
  final DateTime timestamp;
  final String status;
  final String? conversationStatus;

  ChatResponse({
    this.id,
    this.conversationId,
    required this.senderRole,
    this.senderName,
    required this.content,
    this.menu,
    required this.timestamp,
    required this.status,
    this.conversationStatus,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      id: json['id'],
      conversationId: json['conversationId'],
      senderRole: json['senderRole'] ?? '',
      senderName: json['senderName'],
      content: json['content'] ?? '',
      menu: json['menu'] != null 
          ? (json['menu'] as List)
              .map((item) => MenuMealLiteResponse.fromJson(item))
              .toList()
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'SENT',
      conversationStatus: json['conversationStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (conversationId != null) 'conversationId': conversationId,
      'senderRole': senderRole,
      if (senderName != null) 'senderName': senderName,
      'content': content,
      if (menu != null) 'menu': menu!.map((item) => item.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      if (conversationStatus != null) 'conversationStatus': conversationStatus,
    };
  }

  // Helper getters
  bool get isFromCustomer => senderRole == 'CUSTOMER';
  bool get isFromEmployee => senderRole == 'EMP';
  bool get isFromAI => senderRole == 'AI';
  bool get isFromSystem => senderRole == 'SYSTEM';
  
  bool get isPending => status == 'PENDING';
  bool get isSent => status == 'SENT';
  bool get isFailed => status == 'FAILED';
  
  bool get hasMenu => menu != null && menu!.isNotEmpty;
  
  // For UI display
  String get displayName {
    switch (senderRole) {
      case 'CUSTOMER':
        return senderName ?? 'You';
      case 'EMP':
        return senderName ?? 'Employee';
      case 'AI':
        return 'AI Support';
      case 'SYSTEM':
        return 'System';
      default:
        return senderName ?? 'Unknown';
    }
  }

  // Check if this message is from current user (for UI alignment)
  bool isMine(int? currentCustomerId) {
    if (isFromCustomer && currentCustomerId != null) {
      // In a real app, you might need to compare with actual customer ID
      // For now, we'll assume all CUSTOMER messages are "mine"
      return true;
    }
    return false;
  }
}
