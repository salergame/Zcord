import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateChatPage extends StatefulWidget {
  const CreateChatPage({super.key});

  @override
  State<CreateChatPage> createState() => _CreateChatPageState();
}

class _CreateChatPageState extends State<CreateChatPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isGroup = false;

  void _createChat() async {
    final chatName = _nameController.text.trim();
    if (chatName.isNotEmpty) {
      if (_isGroup) {
        // Handle group creation
        await FirebaseFirestore.instance.collection('groups').add({
          'name': chatName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Handle server creation
        await FirebaseFirestore.instance.collection('servers').add({
          'name': chatName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Chat'),
        backgroundColor: const Color(0xFF2D3748),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Group'),
                  selected: _isGroup,
                  onSelected: (selected) => setState(() => _isGroup = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Server'),
                  selected: !_isGroup,
                  onSelected: (selected) => setState(() => _isGroup = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _isGroup ? 'Group Name' : 'Server Name',
                filled: true,
                fillColor: const Color(0xFF4A5568),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _createChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(_isGroup ? 'Create Group' : 'Create Server'),
            ),
          ],
        ),
      ),
    );
  }
}
