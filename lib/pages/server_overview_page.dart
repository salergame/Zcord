import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServerOverviewPage extends StatefulWidget {
  final String serverId;

  const ServerOverviewPage({super.key, required this.serverId});

  @override
  State<ServerOverviewPage> createState() => _ServerOverviewPageState();
}

class _ServerOverviewPageState extends State<ServerOverviewPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServerData();
  }

  Future<void> _loadServerData() async {
    final doc = await FirebaseFirestore.instance
        .collection('servers')
        .doc(widget.serverId)
        .get();
    
    if (doc.exists) {
      setState(() {
        _nameController.text = doc['name'] ?? '';
        _descriptionController.text = doc['description'] ?? '';
        _imageController.text = doc['image'] ?? '';
      });
    }
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance
          .collection('servers')
          .doc(widget.serverId)
          .update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'image': _imageController.text,
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3748),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a202c),
        title: const Text('Server Overview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Server Name',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Server Image URL',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
} 