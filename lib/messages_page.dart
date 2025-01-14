import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesPage extends StatefulWidget {
  final String chatId; // Identifier for the group/user
  final String title;  // Display title

  const MessagesPage({
    super.key,
    required this.chatId,
    required this.title,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message to Firestore
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _firestore.collection('messages/${widget.chatId}/chats').add({
        'text': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'sender': 'User', // Replace with actual user identification
      });
      _messageController.clear();
    }
  }

  // Edit a message in Firestore
  void _editMessage(String messageId, String newText) {
    _firestore
        .collection('messages/${widget.chatId}/chats')
        .doc(messageId)
        .update({'text': newText});
  }

  // Delete a message from Firestore
  void _deleteMessage(String messageId) {
    _firestore
        .collection('messages/${widget.chatId}/chats')
        .doc(messageId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3748),
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages/${widget.chatId}/chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return GestureDetector(
                      onLongPress: () async {
                        final result = await showMenu(
                          context: context,
                          position: const RelativeRect.fromLTRB(100, 200, 100, 200),
                          items: [
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                              ),
                            ),
                          ],
                        );

                        if (result == 'edit') {
                          final newText = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              final editController = TextEditingController(
                                  text: message['text']);
                              return AlertDialog(
                                title: const Text('Edit Message'),
                                content: TextField(
                                  controller: editController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter new message',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, null),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                        context, editController.text.trim()),
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (newText != null && newText.isNotEmpty) {
                            _editMessage(message.id, newText);
                          }
                        } else if (result == 'delete') {
                          _deleteMessage(message.id);
                        }
                      },
                      child: Container(
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[700],
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            message['sender'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(message['text']),
                          trailing: Text(
                            message['timestamp'] != null
                                ? (message['timestamp'] as Timestamp)
                                .toDate()
                                .toLocal()
                                .toString()
                                .split('.')[0]
                                : 'Now',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF2D3748),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF4A5568),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
