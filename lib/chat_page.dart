import 'package:flutter/material.dart';
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
    const MessagesPage(),
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

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
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
                      return Card(
                        color: const Color(0xFF2d3748),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              index % 2 == 0
                                  ? 'https://storage.googleapis.com/a1aa/image/EYKK0hAYWErCGltuUVoYkhoYjfQDslTNLKpS8yO9Yu8D148JA.jpg'
                                  : 'https://storage.googleapis.com/a1aa/image/DEQoePJ5qpXxJiMN9lRz3WzNyBUOMj0fSNYdsPwVA9PGqx5TA.jpg',
                            ),
                          ),
                          title: Text(
                            index % 2 == 0 ? 'Group ${index + 1}' : 'User ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            index % 2 == 0
                                ? 'Last message from group'
                                : 'Last message from user',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
