import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat/messages_page.dart';
import 'dart:convert';

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
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
        title: Text(
          'Личные сообщения',
          style: TextStyle(color: Colors.red[500]),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, isNotEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          final users = snapshot.data!.docs
              .where((doc) => doc.exists && doc.id != currentUser.uid)
              .toList();

          if (users.isEmpty) {
            return const Center(
              child: Text(
                'Нет доступных пользователей',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;

              Widget avatarWidget;
              try {
                if (userData['profileImage'] != null) {
                  final imageBytes = base64Decode(userData['profileImage']);
                  avatarWidget = CircleAvatar(
                    backgroundImage: MemoryImage(imageBytes),
                    backgroundColor: Colors.red[500],
                  );
                } else {
                  avatarWidget = CircleAvatar(
                    backgroundColor: Colors.red[500],
                    child: Text(
                      (userData['nickname'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
              } catch (e) {
                avatarWidget = CircleAvatar(
                  backgroundColor: Colors.red[500],
                  child: Text(
                    (userData['nickname'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A5568),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: avatarWidget,
                  title: Text(
                    userData['nickname'] ?? 'Unknown User',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    userData['status'] ?? 'В сети',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () => _startChat(context, userId, userData['nickname'] ?? 'Unknown User'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _startChat(BuildContext context, String userId, String userName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final chatId = _getChatId(currentUser.uid, userId);
      
      // Create chat room if it doesn't exist
      await _createChatRoom(chatId, userId);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagesPage(
              chatId: chatId,
              title: Text(userName),
            ),
          ),
        );
      }
    }
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '$uid1-$uid2' : '$uid2-$uid1';
  }

  Future<void> _createChatRoom(String chatId, String participantId) async {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists) {
      await chatRef.set({
        'participants': [FirebaseAuth.instance.currentUser!.uid, participantId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
  }
} 