import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for local storage

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<String> messages = [];
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMessages(); // Load messages when the app starts
  }

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      messages = prefs.getStringList('messages') ?? []; // Load saved messages or initialize empty list
    });
  }

  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('messages', messages); // Save messages to local storage
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        messages.add('User1: ${messageController.text}');
        messageController.clear(); // Clear the input field
      });
      saveMessages(); // Save the updated message list
    }
  }

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
            child: ChatBox(
              messages: messages,
              messageController: messageController,
              onSend: sendMessage, // Pass the sendMessage function to handle message sending
            ),
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
  final List<String> messages;
  final TextEditingController messageController;
  final VoidCallback onSend;

  ChatBox({
    required this.messages,
    required this.messageController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF36393F),
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    messages[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
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
                  onSubmitted: (value) => onSend(), // Send message when "Enter" is pressed
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: onSend, // Send message when the button is clicked
              ),
            ],
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
