import 'package:flutter/material.dart';

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

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Уведомления',
          style: TextStyle(color: Colors.red[500]),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
           NotificationItem(
            avatarUrl: 'https://placehold.co/50x50',
            title: 'Черный [90]',
            subtitle: 'упоминает вас в STALKER NEW STORY [CLEAR SKY]',
            time: '45 мин.',
            message: "Хлопцы, я тут на деревню заглянул привез немного своего хабара, ну там патроны, расходники. Подкатывайте посмотрите может кому, что надо. Можем и поторговать. Ааа чуть не забыл, если чет есть продать можем и договорится. Куплю камишки всякие интересные и снарягу, если конечно м...",
          ),
           NotificationItem(
            avatarUrl: 'https://placehold.co/50x50',
            title: 'Stitch',
            subtitle: 'упоминает вас в Elysium',
            time: '14 ч.',
            message: "- Фрагменты будут из различных аниме. Заявки будут приниматься прямо на трибуне. Вы сможете прописать voice acting в специально отведенном канале - заявки.",
          ),
           NotificationItem(
            avatarUrl: 'https://placehold.co/50x50',
            title: 'Черный [90]',
            subtitle: 'упоминает вас в STALKER NEW STORY [CLEAR SKY]',
            time: '16 ч.',
            message: "Хлопцы, я тут на бар заглянул привез немного своего хабара, ну там патроны, расходники. Подкатывайте посмотрите может кому, что надо. Можем и поторговать. Ааа чуть не забыл, если чет есть продать можем и договорится. Куплю камишки всякие интересные и снарягу, если конечно м...",
          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String avatarUrl;
  final String title;
  final String subtitle;
  final String time;
  final String message;

  const NotificationItem({
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            radius: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white60),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red[500]),
          onPressed: () {
            // Handle navigation
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.red[500]),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF4A5568),
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.red[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.red[500]),
            ),
            const SizedBox(height: 20),
            // Account Settings Section
            const SectionHeader(title: 'Account Settings'),
            SettingsItem(
              icon: Icons.person,
              title: 'Account',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.shield,
              title: 'Privacy & Safety',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.group,
              title: 'Family Center',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.key,
              title: 'Authorized Apps',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.devices,
              title: 'Devices',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.movie,
              title: 'Clips',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.person_add,
              title: 'Friend Requests',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.qr_code,
              title: 'Scan QR Code',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            // Billing Settings Section
            const SectionHeader(title: 'Billing Settings'),
            SettingsItem(
              icon: Icons.rocket,
              title: 'Manage Nitro',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.atm,
              title: 'Server Boost',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsItem({super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF4A5568),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red[500]),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
