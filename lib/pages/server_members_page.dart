import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServerMembersPage extends StatelessWidget {
  final String serverId;

  const ServerMembersPage({super.key, required this.serverId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3748),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a202c),
        title: const Text('Members'),
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

          final serverData = serverSnapshot.data!.data() as Map<String, dynamic>;
          final members = List<String>.from(serverData['members'] ?? []);
          final ownerId = serverData['ownerId'] as String;

          if (members.isEmpty) {
            return const Center(
              child: Text(
                'No members in this server',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('uid', whereIn: members)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = users[index].data() as Map<String, dynamic>;
                  final userId = userData['uid'] as String;
                  final isOwner = userId == ownerId;
                  final isCurrentUser = userId == FirebaseAuth.instance.currentUser?.uid;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1a202c),
                      backgroundImage: userData['photoUrl'] != null
                          ? NetworkImage(userData['photoUrl'])
                          : null,
                      child: userData['photoUrl'] == null
                          ? Text(
                              userData['nickname']?[0].toUpperCase() ?? 'U',
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(
                          userData['nickname'] ?? 'Unknown User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'OWNER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      userData['status'] ?? 'Online',
                      style: TextStyle(
                        color: userData['status'] == 'Online' 
                            ? Colors.green 
                            : Colors.grey,
                      ),
                    ),
                    trailing: !isCurrentUser && !isOwner
                        ? PopupMenuButton(
                            color: const Color(0xFF1a202c),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'kick',
                                child: Text(
                                  'Kick Member',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'ban',
                                child: Text(
                                  'Ban Member',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'kick') {
                                _kickMember(userId);
                              } else if (value == 'ban') {
                                _banMember(userId);
                              }
                            },
                          )
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _kickMember(String userId) async {
    await FirebaseFirestore.instance
        .collection('servers')
        .doc(serverId)
        .update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> _banMember(String userId) async {
    await FirebaseFirestore.instance
        .collection('servers')
        .doc(serverId)
        .update({
      'members': FieldValue.arrayRemove([userId]),
      'bannedMembers': FieldValue.arrayUnion([userId]),
    });
  }
} 