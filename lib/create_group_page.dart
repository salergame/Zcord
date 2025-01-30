import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> _selectedUsers = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Widget _buildUserAvatar(Map<String, dynamic> user) {
    final avatarUrl = user['profileImage'] as String?;
    final nickname = user['nickname'] as String;
    
    // Check if it's a URL or base64
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

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final querySnapshot = await _firestore.collection('users').get();
        setState(() {
          _users = querySnapshot.docs
              .where((doc) => doc.id != currentUser.uid)
              .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'nickname': data['nickname'] ?? 'Unknown User',
              'profileImage': data['profileImage'] ?? data['avatarUrl'] ?? data['photoUrl'], // Check multiple possible fields
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty || _selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name and select users')),
      );
      return;
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Add current user to members list
        final members = [..._selectedUsers, currentUser.uid];
        
        await _firestore.collection('groups').add({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'members': members,
          'ownerId': currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error creating group: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create group')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3136),
        title: const Text('Create Group'),
        actions: [
          TextButton(
            onPressed: _createGroup,
            child: const Text('Create'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Users',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final isSelected = _selectedUsers.contains(user['id']);
                      
                      return ListTile(
                        leading: _buildUserAvatar(user),
                        title: Text(
                          user['nickname'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? Colors.green : Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedUsers.remove(user['id']);
                            } else {
                              _selectedUsers.add(user['id']);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 