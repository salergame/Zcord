import 'dart:io';

class WebSocketConnection {
  late WebSocket _socket;

  Future<void> connect(String url) async {
    try {
      _socket = await WebSocket.connect(url);
      print('WebSocket connected to: $url');

      // Listen for incoming messages and errors
      _socket.listen((data) {
        onMessage(data);
      }, onError: onError, onDone: onClose);
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void onMessage(dynamic message) {
    // Log received message
    print('Received message: $message');
  }

  void sendMessage(String message) {
    if (_socket.readyState == WebSocket.open) {
      _socket.add(message);
      print('Sent message: $message');
    } else {
      print('WebSocket is not open. Message not sent.');
    }
  }

  void onClose() {
    print('WebSocket connection closed.');
  }

  void onError(error) {
    print('WebSocket error: $error');
  }

  void close() {
    _socket.close();
    print('WebSocket connection closed manually.');
  }
}
