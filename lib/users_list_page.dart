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
                  onTap: () => _createOrNavigateToChat(context, userId, userData['nickname'] ?? 'Unknown User'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _createOrNavigateToChat(BuildContext context, String userId, String nickname) async {
    try {
      // Create a unique chat ID
      final chatId = [FirebaseAuth.instance.currentUser!.uid, userId]..sort();
      final chatDocId = chatId.join('_');

      // Check if chat already exists
      final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatDocId).get();

      if (!chatDoc.exists) {
        // Create new chat document
        await FirebaseFirestore.instance.collection('chats').doc(chatDocId).set({
          'participants': chatId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }

      // Navigate to chat
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagesPage(
            chatId: chatDocId,
            title: Text(nickname, style: const TextStyle(color: Colors.white)),
          ),
        ),
      );
    } catch (e) {
      print('Error creating/navigating to chat: $e');
    }
  }
} 