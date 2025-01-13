import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifications_page.dart';
import 'settings_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData.dark(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MessagesListPage(),
    const NotificationsPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2D3748),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Уведомления',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Вы',
          ),
        ],
      ),
    );
  }
}

class MessagesListPage extends StatelessWidget {
  const MessagesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 60,
            color: const Color(0xFF1a202c),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/Z.png'),
                  radius: 20,
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < 7; i++)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://storage.googleapis.com/a1aa/image/DEQoePJ5qpXxJiMN9lRz3WzNyBUOMj0fSNYdsPwVA9PGqx5TA.jpg',
                      ),
                      radius: 20,
                    ),
                  ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Colors.grey[700],
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  color: const Color(0xFF2d3748),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Messages',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF4a5568),
                            hintText: 'Search...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Messages List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final isGroup = index % 2 == 0;
                      final title = isGroup ? 'Group ${index + 1}' : 'User ${index + 1}';
                      final chatId = isGroup ? 'group_${index + 1}' : 'user_${index + 1}';

                      return Card(
                        color: const Color(0xFF2d3748),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessagesPage(chatId: chatId, title: title),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              isGroup
                                  ? 'https://storage.googleapis.com/a1aa/image/EYKK0hAYWErCGltuUVoYkhoYjfQDslTNLKpS8yO9Yu8D148JA.jpg'
                                  : 'https://storage.googleapis.com/a1aa/image/DEQoePJ5qpXxJiMN9lRz3WzNyBUOMj0fSNYdsPwVA9PGqx5TA.jpg',
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            isGroup ? 'Last message from group' : 'Last message from user',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

class MessagesPage extends StatefulWidget {
  final String chatId; // Identifier for the group/user
  final String title;  // Display title

  const MessagesPage({
    super.key,
    required this.chatId,
    required this.title,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message to Firestore
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _firestore.collection('messages/${widget.chatId}/chats').add({
        'text': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'sender': 'User', // Replace with actual user identification
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3748),
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages/${widget.chatId}/chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[700],
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        message['sender'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(message['text']),
                      trailing: Text(
                        message['timestamp'] != null
                            ? (message['timestamp'] as Timestamp)
                            .toDate()
                            .toLocal()
                            .toString()
                            .split('.')[0]
                            : 'Now',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF2D3748),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF4A5568),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

