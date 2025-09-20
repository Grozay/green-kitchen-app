class ConversationResponse {
  final int id;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? customerId;
  final String? customerName;
  final int? employeeId;
  final String? employeeName;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ConversationResponse({
    required this.id,
    required this.status,
    this.startTime,
    this.endTime,
    this.customerId,
    this.customerName,
    this.employeeId,
    this.employeeName,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'AI',
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'])
          : null,
      customerId: json['customerId'],
      customerName: json['customerName'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      unreadCount: json['unreadCount'] ?? 0,
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null 
          ? DateTime.parse(json['lastMessageTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      if (startTime != null) 'startTime': startTime!.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      if (customerId != null) 'customerId': customerId,
      if (customerName != null) 'customerName': customerName,
      if (employeeId != null) 'employeeId': employeeId,
      if (employeeName != null) 'employeeName': employeeName,
      'unreadCount': unreadCount,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageTime != null) 'lastMessageTime': lastMessageTime!.toIso8601String(),
    };
  }

  // Helper getters
  bool get isAI => status == 'AI';
  bool get isEmployee => status == 'EMP';
  bool get isWaitingEmployee => status == 'WAITING_EMP';
  
  bool get hasUnread => unreadCount > 0;
  
  String get statusDisplayName {
    switch (status) {
      case 'AI':
        return 'AI Tư vấn';
      case 'EMP':
        return 'Nhân viên';
      case 'WAITING_EMP':
        return 'Chờ nhân viên';
      default:
        return status;
    }
  }
}
