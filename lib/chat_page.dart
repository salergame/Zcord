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
        backgroundColor: const Color(0xFF1B1C1E), // Made background darker
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/zcord_logo.png', // Logo
                height: 40, // Logo size
                width: 40, // Logo size
                fit: BoxFit.cover, // Circle cropping
              ),
            ),
            const SizedBox(width: 10), // Spacing between logo and text
            const Text(
              'ZCord', // App name
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        color: const Color(0xFF101214), // Made background darker
        border: Border.all(
          color: Colors.redAccent, // Bright red border
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.8), // Neon red glow
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Channels',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(color: Colors.red),
          ListTile(
            title: Text(
              '# general',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ListTile(
            title: Text(
              '# random',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ListTile(
            title: Text(
              '# coding',
              style: TextStyle(color: Colors.red),
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
            decoration: BoxDecoration(
              color: const Color(0xFF191A1C), // Dark background for chat
              border: Border.all(
                color: Colors.redAccent, // Bright red border
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    messages[index],
                    style: const TextStyle(color: Colors.red),
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
                  style: const TextStyle(color: Colors.red),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0F1011), // Very dark background for input
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.redAccent, // Red border around input field
                        width: 2,
                      ),
                    ),
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: Colors.red),
                  ),
                  onSubmitted: (value) => onSend(), // Send message when "Enter" is pressed
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.red),
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
      decoration: BoxDecoration(
        color: const Color(0xFF101214), // Dark background for user list
        border: Border.all(
          color: Colors.redAccent, // Bright red border
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.8), // Neon red glow
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Users',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(color: Colors.red),
          ListTile(
            title: Text(
              'User1',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ListTile(
            title: Text(
              'User2',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ListTile(
            title: Text(
              'User3',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
