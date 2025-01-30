import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifications_page.dart';
import 'users_list_page.dart';
import 'settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'server_options_menu.dart';
import 'chat/messages_page.dart';  // Update this import path if needed

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

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({super.key});

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  List<Map<String, dynamic>> _servers = [];
  List<Map<String, dynamic>> _groups = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadServersAndGroups();
  }

  void _loadServersAndGroups() {
    // Listen to servers
    _firestore
        .collection('servers')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _servers = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'image': data['image'] ?? '',
            'description': data['description'] ?? '',
            'ownerId': data['ownerId'] ?? '',
          };
        }).toList();
      });
    });

    // Listen to groups
    _firestore
        .collection('groups')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _groups = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'image': data['image'] ?? '',
            'description': data['description'] ?? '',
            'ownerId': data['ownerId'] ?? '',
          };
        }).toList();
      });
    });
  }

  void _createEntity() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2D3748),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.people, color: Colors.white),
                  ),
                  title: const Text(
                    'Create a Server',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Your own community with channels',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateServerDialog();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.group, color: Colors.white),
                  ),
                  title: const Text(
                    'Create a Group DM',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Private group with friends',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateGroupDialog();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person_add, color: Colors.white),
                  ),
                  title: const Text(
                    'Direct Message',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Chat with other users',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showUsersList();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateServerDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Create a Server',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Server Name',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  await _firestore.collection('servers').add({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'image': imageController.text,
                    'ownerId': currentUser.uid,
                    'members': [currentUser.uid],
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),  
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    // Similar to _showCreateServerDialog but for groups
    // Add user selection functionality for group members
  }

  void _showUsersList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsersListPage(),
      ),
    );
  }

  void _onServerSelected(String serverId, String serverName, String ownerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(
          chatId: serverId,
          title: Row(
            children: [
              Text(serverName),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServerOptionsMenu(
                        serverId: serverId,
                        serverName: serverName,
                        ownerId: ownerId,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onGroupSelected(String groupId, String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(
          chatId: groupId,
          title: Text(groupName),
        ),
      ),
    );
  }

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
                  backgroundImage: AssetImage('assets/zcord_logo.png'),
                  radius: 20,
                ),
                const SizedBox(height: 16),
                // List of Servers
                for (var server in _servers)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () => _onServerSelected(
                        server['id']!, 
                        server['name']!,
                        server['ownerId']!,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(server['image']!),
                        radius: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: _createEntity,
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
                          'Сообщения',
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
                            hintText: 'Поиск',
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
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: _groups.map((group) {
                      return Card(
                        color: const Color(0xFF2d3748),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          onTap: () => _onGroupSelected(group['id']!, group['name']!),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(group['image']!),
                          ),
                          title: Text(
                            group['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            group['description']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
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

class CreateEntityPage extends StatefulWidget {
  final String entityType; // "server" or "group"

  const CreateEntityPage({
    super.key,
    required this.entityType,
  });

  @override
  State<CreateEntityPage> createState() => _CreateEntityPageState();
}

class _CreateEntityPageState extends State<CreateEntityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveEntity() async {
    final name = _nameController.text.trim();
    final image = _imageController.text.trim();

    if (name.isEmpty || image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both a name and an image URL.')),
      );
      return;
    }

    final newEntity = {
      'name': name,
      'image': image,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection(widget.entityType).add(newEntity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.entityType.capitalize()} created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create ${widget.entityType}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.entityType.capitalize()}'),
        backgroundColor: const Color(0xFF2D3748),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${widget.entityType.capitalize()} Name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveEntity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}