import 'package:flutter/material.dart';

class ServerPage extends StatelessWidget {
  final String serverId;
  final String serverName;

  const ServerPage({super.key, required this.serverId, required this.serverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serverName),
        backgroundColor: const Color(0xFF2D3748),
      ),
      body: Center(
        child: Text(
          'Welcome to $serverName!',
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
