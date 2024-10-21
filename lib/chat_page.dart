import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Z-cord'),
        backgroundColor: const Color(0xFF2C2F33), // Discord-like dark color
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ChannelList(),
          ),
          Expanded(
            flex: 5,
            child: ChatBox(),
          ),
          Expanded(
            flex: 2,
            child: UserList(),
          ),
        ],
      ),
    );
  }
}

class ChannelList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF23272A),
      child: ListView(
        children: const [
          ListTile(
            title: Text(
              '# general',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: Text(
              '# random',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: Text(
              '# coding',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF36393F),
            child: ListView(
              children: const [
                ListTile(
                  title: Text(
                    'User1: Hello World!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  title: Text(
                    'User2: Hi there!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF40444B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: 'Type a message...',
              hintStyle: const TextStyle(color: Colors.white54),
            ),
          ),
        ),
      ],
    );
  }
}

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2C2F33),
      child: ListView(
        children: const [
          ListTile(
            title: Text(
              'User1',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: Text(
              'User2',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: Text(
              'User3',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
