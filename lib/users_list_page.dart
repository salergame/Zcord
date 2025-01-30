import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:zcord/chat/messages_page.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _buildUserAvatar(String? avatarUrl, String nickname) {
    final isUrl = avatarUrl != null && 
                 (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));
    final isBase64 = avatarUrl != null && !isUrl;
    
    ImageProvider? getAvatarImage() {
      if (avatarUrl == null || avatarUrl.isEmpty) return null;
      if (isUrl) return NetworkImage(avatarUrl);
      if (isBase64) {
        try {
          return MemoryImage(base64Decode(avatarUrl));
        } catch (e) {
          print('Error decoding base64 avatar: $e');
          return null;
        }
      }
      return null;
    }

    return CircleAvatar(
      backgroundColor: Colors.blue,
      backgroundImage: getAvatarImage(),
      child: getAvatarImage() == null
          ? Text(
              nickname.isNotEmpty ? nickname[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Future<void> _createOrNavigateToChat(BuildContext context, String userId, String nickname) async {
    try {
      // Create a unique chat ID
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final chatId = [currentUser.uid, userId]..sort();
      final chatDocId = chatId.join('_');

      // Check if chat already exists
      final chatDoc = await _firestore.collection('chats').doc(chatDocId).get();

      if (!chatDoc.exists) {
        // Create new chat document
        await _firestore.collection('chats').doc(chatDocId).set({
          'members': chatId,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'type': 'direct', // Add this to distinguish from group chats
        });
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagesPage(
            chatId: chatDocId,
            chatName: nickname,
            isGroup: false,
            title: Text(nickname),
          ),
        ),
      );
    } catch (e) {
      print('Error creating/navigating to chat: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open chat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3136),
        title: const Text('Direct Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = _auth.currentUser;
          if (currentUser == null) {
            return const Center(child: Text('Not logged in'));
          }

          final users = snapshot.data!.docs
              .where((doc) => doc.id != currentUser.uid)
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index];
              final userId = snapshot.data!.docs
                  .where((doc) => doc.id != currentUser.uid)
                  .elementAt(index)
                  .id;
              
              final avatarWidget = _buildUserAvatar(
                userData['profileImage'] ?? userData['avatarUrl'] ?? userData['photoUrl'],
                userData['nickname'] ?? 'Unknown User',
              );

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F3136),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: avatarWidget,
                  title: Text(
                    userData['nickname'] ?? 'Unknown User',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    userData['status'] ?? 'Online',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () => _createOrNavigateToChat(
                    context,
                    userId,
                    userData['nickname'] ?? 'Unknown User',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 