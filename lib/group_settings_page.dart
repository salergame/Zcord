import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class GroupSettingsPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupSettingsPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  bool _isOwner = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    setState(() => _isLoading = true);
    try {
      // Get group data
      final groupDoc = await _firestore.collection('groups').doc(widget.groupId).get();
      final groupData = groupDoc.data();
      
      if (groupData != null) {
        _nameController.text = groupData['name'] ?? '';
        _descriptionController.text = groupData['description'] ?? '';
        _isOwner = groupData['ownerId'] == _currentUserId;
        
        // Get members data
        final memberIds = List<String>.from(groupData['members'] ?? []);
        final membersData = await Future.wait(
          memberIds.map((id) => _firestore.collection('users').doc(id).get())
        );
        
        setState(() {
          _members = membersData.map((doc) {
            final data = doc.data() ?? {};
            return {
              'id': doc.id,
              'nickname': data['nickname'] ?? 'Unknown User',
              'profileImage': data['profileImage'] ?? data['avatarUrl'] ?? data['photoUrl'],
              'isOwner': doc.id == groupData['ownerId'],
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading group data: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMemberAvatar(Map<String, dynamic> member) {
    final avatarUrl = member['profileImage'] as String?;
    final nickname = member['nickname'] as String;
    
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

  Future<void> _updateGroupInfo() async {
    try {
      await _firestore.collection('groups').doc(widget.groupId).update({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating group: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update group')),
        );
      }
    }
  }

  Future<void> _removeMember(String memberId) async {
    try {
      await _firestore.collection('groups').doc(widget.groupId).update({
        'members': FieldValue.arrayRemove([memberId]),
      });
      await _loadGroupData();
    } catch (e) {
      print('Error removing member: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove member')),
        );
      }
    }
  }

  Future<void> _leaveGroup() async {
    try {
      if (_currentUserId != null) {
        await _firestore.collection('groups').doc(widget.groupId).update({
          'members': FieldValue.arrayRemove([_currentUserId]),
        });
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // Pop twice to go back to chat list
        }
      }
    } catch (e) {
      print('Error leaving group: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to leave group')),
        );
      }
    }
  }

  Future<void> _deleteGroup() async {
    try {
      await _firestore.collection('groups').doc(widget.groupId).delete();
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // Pop twice to go back to chat list
      }
    } catch (e) {
      print('Error deleting group: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete group')),
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
        title: const Text('Group Settings'),
        actions: [
          if (_isOwner)
            TextButton(
              onPressed: _updateGroupInfo,
              child: const Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (_isOwner) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_descriptionController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _descriptionController.text,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Members',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ..._members.map((member) => ListTile(
                  leading: _buildMemberAvatar(member),
                  title: Text(
                    member['nickname'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: member['isOwner']
                      ? const Text(
                          'Owner',
                          style: TextStyle(color: Colors.grey),
                        )
                      : null,
                  trailing: _isOwner && !member['isOwner']
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeMember(member['id']),
                        )
                      : null,
                )),
                const Divider(color: Colors.grey),
                if (!_isOwner)
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text(
                      'Leave Group',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF2F3136),
                          title: const Text(
                            'Leave Group',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to leave this group?',
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _leaveGroup();
                              },
                              child: const Text(
                                'Leave',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                if (_isOwner)
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text(
                      'Delete Group',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF2F3136),
                          title: const Text(
                            'Delete Group',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to delete this group? This action cannot be undone.',
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteGroup();
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
} 