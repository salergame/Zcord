import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../users_list_page.dart';
import 'messages_page.dart';

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({super.key});

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _servers = [];
  List<Map<String, dynamic>> _groups = [];

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      _loadServersAndGroups();
    }
  }

  void _loadServersAndGroups() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Listen to servers
    _firestore
        .collection('servers')
        .where('members', arrayContains: currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _servers = snapshot.docs.map((doc) => {
            'id': doc.id,
            'name': doc['name'] ?? 'Unnamed Server',
            'description': doc['description'] ?? 'No description',
            'ownerId': doc['ownerId'] ?? '',
          }).toList();
        });
      }
    });

    // Listen to groups
    _firestore
        .collection('groups')
        .where('members', arrayContains: currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _groups = snapshot.docs.map((doc) => {
            'id': doc.id,
            'name': doc['name'] ?? 'Unnamed Group',
            'description': doc['description'] ?? 'No description',
            'ownerId': doc['ownerId'] ?? '',
          }).toList();
        });
      }
    });
  }

  Future<void> _createServer(String name, String description) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('servers').add({
          'name': name,
          'description': description,
          'ownerId': currentUser.uid,
          'members': [currentUser.uid],
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Сервер успешно создан'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error creating server: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при создании сервера'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: Text(
          'Создать',
          style: TextStyle(color: Colors.red[500]),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.group, color: Colors.red[500]),
              title: const Text(
                'Сервер',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showServerCreationDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add, color: Colors.red[500]),
              title: const Text(
                'Личные сообщения',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showUsersList();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showServerCreationDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: Text(
          'Создать сервер',
          style: TextStyle(color: Colors.red[500]),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Название сервера',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Описание',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _createServer(
                nameController.text.trim(),
                descriptionController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Создать',
              style: TextStyle(color: Colors.red[500]),
            ),
          ),
        ],
      ),
    );
  }

  void _showUsersList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsersListPage(),
      ),
    );
  }

  void _navigateToChat(String chatId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(
          chatId: chatId,
          title: Text(title, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Пожалуйста, войдите в систему',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text(
              'ZCord',
              style: TextStyle(color: Colors.red[500]),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.add, color: Colors.red[500]),
              onPressed: () => _showCreateDialog(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  fillColor: const Color(0xFF4a5568),
                  filled: true,
                  hintText: 'Поиск',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
            if (_servers.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Серверы',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._servers.map((server) => _buildServerTile(server)),
            ],
            if (_groups.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Группы',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._groups.map((group) => _buildGroupTile(group)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServerTile(Map<String, dynamic> server) {
    return Card(
      color: const Color(0xFF2d3748),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          server['name'] ?? 'Unnamed Server',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          server['description'] ?? 'No description',
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () => _navigateToChat(
          server['id'],
          server['name'],
        ),
      ),
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> group) {
    return Card(
      color: const Color(0xFF2d3748),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          group['name'] ?? 'Unnamed Group',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          group['description'] ?? 'No description',
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () => _navigateToChat(
          group['id'],
          group['name'],
        ),
      ),
    );
  }
} 