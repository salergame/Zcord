import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'dart:convert';

void main() async {
  final handler = webSocketHandler((webSocket) {
    webSocket.listen((message) {
      // Parse the incoming message
      final data = json.decode(message);
      
      // Broadcast the message to all connected clients
      // In a production environment, you'd want to maintain a list of connections
      // and only send to relevant clients based on the chatId
      webSocket.add(json.encode(data));
    });
  });

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('WebSocket server running on port ${server.port}');
} 