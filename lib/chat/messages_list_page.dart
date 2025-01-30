import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zcord/chat/messages_page.dart';
import 'package:zcord/create_group_page.dart';
import 'package:zcord/users_list_page.dart';

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({super.key});

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _navigateToChat(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    final isGroup = data['type'] == 'group';
    final chatName = isGroup 
        ? data['name'] ?? 'Unnamed Group'
        : data['members'].firstWhere(
            (memberId) => memberId != _auth.currentUser?.uid,
            orElse: () => 'Unknown User',
          );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(
          chatId: document.id,
          chatName: chatName,
          isGroup: isGroup,
          title: Text(chatName),
        ),
      ),
    );
  }

  void _createServer() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2F3136),
        title: const Text(
          'Create Server',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
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
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final currentUser = _auth.currentUser;
                if (currentUser != null) {
                  await _firestore.collection('servers').add({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'ownerId': currentUser.uid,
                    'members': [currentUser.uid],
                    'createdAt': FieldValue.serverTimestamp(),
                    'type': 'server',
                  });
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3136),
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateGroupPage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UsersListPage(),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chats')
            .where('members', arrayContains: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No messages yet',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              final isGroup = data['type'] == 'group';
              final chatName = isGroup 
                  ? data['name'] ?? 'Unnamed Group'
                  : data['members'].firstWhere(
                      (memberId) => memberId != _auth.currentUser?.uid,
                      orElse: () => 'Unknown User',
                    );

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isGroup ? Colors.green : Colors.blue,
                  child: Text(
                    chatName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  chatName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  data['lastMessage'] ?? 'No messages yet',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () => _navigateToChat(document),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createServer,
        child: const Icon(Icons.add),
      ),
    );
  }
} 