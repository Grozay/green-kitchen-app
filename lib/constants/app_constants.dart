// App constants for Chat/WebSocket
const CURRENT_CUSTOMER_ID = 4;
class ChatSocketConfig {
  // SockJS/STOMP endpoint (Spring Boot starter websocket)
  // Ví dụ: http://<host>:<port>/apis/v1/ws
  static const String wsEndpoint = 'http://192.168.1.252:8080/apis/v1/ws';

  // Heartbeat
  static const Duration heartbeatOutgoing = Duration(seconds: 10);
  static const Duration heartbeatIncoming = Duration(seconds: 10);

  // Reconnect backoff base (client sẽ dùng giá trị riêng)
  static const Duration reconnectDelay = Duration(milliseconds: 5000);
}

class ChatBubbleConfig {
  // Các route prefix mà chat bubble sẽ ẩn
  static const List<String> hiddenRoutePrefixes = <String>[
    '/auth',
    '/payment',
    '/chat',
  ];
}