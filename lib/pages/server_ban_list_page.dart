import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServerBanListPage extends StatelessWidget {
  final String serverId;

  const ServerBanListPage({super.key, required this.serverId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3748),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a202c),
        title: const Text('Banned Users'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('servers')
            .doc(serverId)
            .snapshots(),
        builder: (context, serverSnapshot) {
          if (!serverSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bannedMembers = List<String>.from(
              serverSnapshot.data!['bannedMembers'] ?? []);

          if (bannedMembers.isEmpty) {
            return const Center(
              child: Text(
                'No banned users',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('uid', whereIn: bannedMembers)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data!.docs[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['photoUrl'] != null
                          ? NetworkImage(user['photoUrl'])
                          : null,
                      child: user['photoUrl'] == null
                          ? Text(user['nickname']?[0] ?? 'U')
                          : null,
                    ),
                    title: Text(
                      user['nickname'] ?? 'Unknown User',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: TextButton(
                      onPressed: () => _unbanUser(user['uid']),
                      child: const Text('Unban'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _unbanUser(String userId) async {
    await FirebaseFirestore.instance
        .collection('servers')
        .doc(serverId)
        .update({
      'bannedMembers': FieldValue.arrayRemove([userId]),
    });
  }
} 