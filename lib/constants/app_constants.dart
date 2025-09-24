import '../apis/endpoint.dart';

// App constants for Chat/WebSocket
const int CURRENT_CUSTOMER_ID = 11;
class ChatSocketConfig {
  // SockJS/STOMP endpoint (Spring Boot starter websocket)
  static String get wsEndpoint => '${ApiEndpoints.baseUrl}/ws';

  // Heartbeat
  static const Duration heartbeatOutgoing = Duration(seconds: 10);
  static const Duration heartbeatIncoming = Duration(seconds: 10);

  // Reconnect backoff base (client will use separate value)
  static const Duration reconnectDelay = Duration(milliseconds: 5000);
}

class ChatBubbleConfig {
  // Route prefixes where chat bubble will be hidden
  static const List<String> hiddenRoutePrefixes = <String>[
    '/auth',
    '/payment',
    '/chat',
  ];
}