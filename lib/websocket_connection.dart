import 'dart:io';

class WebSocketConnection {
  late WebSocket _socket;

  Future<void> connect(String url) async {
    try {
      _socket = await WebSocket.connect(url);
      ('WebSocket connected to: $url');

      // Listen for incoming messages and errors
      _socket.listen((data) {
        onMessage(data);
      }, onError: onError, onDone: onClose);
    } catch (e) {
      ('WebSocket connection failed: $e');
    }
  }

  void onMessage(dynamic message) {
    // Log received message
    ('Received message: $message');
  }

  void sendMessage(String message) {
    if (_socket.readyState == WebSocket.open) {
      _socket.add(message);
      ('Sent message: $message');
    } else {
      ('WebSocket is not open. Message not sent.');
    }
  }

  void onClose() {
    ('WebSocket connection closed.');
  }

  void onError(error) {
    ('WebSocket error: $error');
  }

  void close() {
    _socket.close();
    ('WebSocket connection closed manually.');
  }
}
