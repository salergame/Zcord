import 'dart:io';
import 'dart:convert';

class WebSocketConnection {
  late WebSocket _socket;
  Function(Map<String, dynamic>)? onMessageCallback;
  bool isConnected = false;
  
  // Add debug mode
  final bool debugMode;
  
  WebSocketConnection({this.debugMode = false});

  Future<void> connect(String url) async {
    try {
      if (debugMode) print('Attempting to connect to: $url');
      
      _socket = await WebSocket.connect(url);
      isConnected = true;
      
      if (debugMode) print('WebSocket connected successfully to: $url');

      _socket.listen(
        (data) {
          if (debugMode) print('Received raw data: $data');
          _handleMessage(data);
        },
        onError: (error) {
          if (debugMode) print('WebSocket error: $error');
          _handleError(error);
        },
        onDone: () {
          if (debugMode) print('WebSocket connection closed');
          _handleClose();
        },
      );
    } catch (e) {
      if (debugMode) print('WebSocket connection failed: $e');
      isConnected = false;
      rethrow;
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final message = json.decode(data.toString());
      if (debugMode) print('Parsed message: $message');
      onMessageCallback?.call(message);
    } catch (e) {
      if (debugMode) print('Error parsing message: $e');
    }
  }

  void _handleError(error) {
    print('WebSocket error: $error');
    isConnected = false;
  }

  void _handleClose() {
    print('WebSocket connection closed');
    isConnected = false;
  }

  void sendMessage({
    required String chatId,
    required String senderId,
    required String senderNickname,
    required String text,
  }) {
    if (!isConnected) {
      if (debugMode) print('Cannot send message: WebSocket is not connected');
      return;
    }

    final message = {
      'type': 'chat_message',
      'chatId': chatId,
      'senderId': senderId,
      'senderNickname': senderNickname,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (debugMode) print('Sending message: $message');
    _socket.add(json.encode(message));
  }

  // Add test method
  Future<void> testConnection() async {
    if (!isConnected) {
      throw Exception('WebSocket is not connected');
    }

    final testMessage = {
      'type': 'test_message',
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (debugMode) print('Sending test message: $testMessage');
    _socket.add(json.encode(testMessage));
  }

  void close() {
    if (debugMode) print('Closing WebSocket connection');
    _socket.close();
    isConnected = false;
  }
}
