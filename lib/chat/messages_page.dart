import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MessagesPage extends StatefulWidget {
  final String chatId;
  final Widget title;

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
  final TextEditingController _editController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FocusNode _focusNode = FocusNode();
  String? _currentUserNickname;
  String? _currentUserAvatar;
  final ImagePicker _picker = ImagePicker();
  String? _selectedMessageId;
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserNickname();
    _ensureChatExists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3136),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: widget.title,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF2F3136),
            onSelected: (value) {
              switch (value) {
                case 'video':
                  // Handle video call
                  break;
                case 'voice':
                  // Handle voice call
                  break;
                case 'info':
                  // Handle user info
                  break;
                case 'block':
                  // Handle block user
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'video',
                child: ListTile(
                  leading: const Icon(Icons.video_call, color: Colors.white),
                  title: const Text(
                    'Start Video Call',
                    style: TextStyle(color: Colors.white),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'voice',
                child: ListTile(
                  leading: const Icon(Icons.call, color: Colors.white),
                  title: const Text(
                    'Start Voice Call',
                    style: TextStyle(color: Colors.white),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'info',
                child: ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.white),
                  title: const Text(
                    'View Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'block',
                child: ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: const Text(
                    'Block User',
                    style: TextStyle(color: Colors.red),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final messageId = messages[index].id;
                    
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _selectedMessageId = messageId;
                        });
                        _showMessageOptions(message, messageId);
                      },
                      child: _buildMessageItem(message, messageId),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF40444B),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _showImageSourceOptions,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF40444B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showEmoji ? Icons.keyboard : Icons.emoji_emotions,
                    color: Colors.white
                  ),
                  onPressed: () {
                    setState(() {
                      _showEmoji = !_showEmoji;
                    });
                    if (_showEmoji) {
                      _focusNode.unfocus();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
          Offstage(
            offstage: !_showEmoji,
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                textEditingController: _messageController,
                config: Config(
                  height: 256,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    backgroundColor: const Color(0xFF2D3748),
                    columns: 7,
                  ),
                  skinToneConfig: const SkinToneConfig(),
                  categoryViewConfig: const CategoryViewConfig(),
                  bottomActionBarConfig: const BottomActionBarConfig(),
                  searchViewConfig: const SearchViewConfig(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message, String messageId) {
    final isCurrentUser = message['senderId'] == _auth.currentUser?.uid;
    final isSelected = messageId == _selectedMessageId;
    final messageText = message['text'] as String? ?? '';
    final senderName = message['senderNickname'] as String? ?? 'Unknown';
    final messageType = message['type'] as String? ?? 'text';
    final timestamp = message['timestamp'] as Timestamp?;
    final avatarUrl = message['senderAvatar'] as String?;
    
    // Check if it's a URL or base64
    final isUrl = avatarUrl != null && 
                 (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));
    final isBase64 = avatarUrl != null && !isUrl;
    final hasCustomAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    
    ImageProvider? getAvatarImage() {
      if (!hasCustomAvatar) return null;
      if (isUrl) return NetworkImage(avatarUrl);
      if (isBase64) {
        try {
          return MemoryImage(base64Decode(avatarUrl));
        } catch (e) {
          print('Error decoding base64 image: $e');
          return null;
        }
      }
      return null;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            _selectedMessageId = messageId;
          });
          _showMessageOptions(message, messageId);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: hasCustomAvatar ? () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          image: DecorationImage(
                            image: getAvatarImage()!,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  );
                } : null,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: isCurrentUser ? Colors.blue : Colors.green,
                  backgroundImage: getAvatarImage(),
                  child: !hasCustomAvatar
                      ? Text(
                          senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          senderName,
                          style: TextStyle(
                            fontSize: 16,
                            color: isCurrentUser ? Colors.blue : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    messageType == 'image' && message['imageBase64'] != null
                        ? GestureDetector(
                            onTap: () => _showImageOptions(message['imageBase64']),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(message['imageBase64']),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Text(
                            messageText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                    if (message['isEdited'] == true)
                      Text(
                        '(edited)',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D3748),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white),
            title: const Text('Take a Photo', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _handleImageSelection(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white),
            title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _handleImageSelection(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    
    if (image != null) {
      try {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          // Get fresh user data including avatar
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();
          
          final userData = userDoc.data() as Map<String, dynamic>?;
          final userAvatar = userData?['profileImage']; // Use profileImage field
          
          print('Sending image with avatar: $userAvatar'); // Debug print
          
          final messageData = {
            'senderId': currentUser.uid,
            'senderNickname': _currentUserNickname,
            'senderAvatar': userAvatar,
            'imageBase64': base64Image,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'image',
          };

          await _firestore
              .collection('chats')
              .doc(widget.chatId)
              .collection('messages')
              .add(messageData);

          await _firestore.collection('chats').doc(widget.chatId).update({
            'lastMessage': '📷 Image',
            'lastMessageTime': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('Error sending image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send image. Please try again.')),
        );
      }
    }
  }

  void _showImageOptions(String base64Image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.memory(
                  base64Decode(base64Image),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => _shareImage(base64Image),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareImage(String base64Image) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/shared_image.jpg').create();
      await file.writeAsBytes(base64Decode(base64Image));
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sent from Zcord',
      );
    } catch (e) {
      print('Error sharing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share image')),
        );
      }
    }
  }

  Future<void> _ensureChatExists() async {
    final chatRef = _firestore.collection('chats').doc(widget.chatId);
    final chatDoc = await chatRef.get();
    
    if (!chatDoc.exists) {
      await chatRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _loadCurrentUserNickname() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          print('User document data: $userData'); // Debug print
          
          final avatarUrl = userData?['profileImage']; // Changed to profileImage
          final isValidUrl = avatarUrl != null && 
                           avatarUrl.isNotEmpty && 
                           (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));
          
          setState(() {
            _currentUserNickname = userData?['nickname'] ?? currentUser.displayName ?? 'Unknown';
            _currentUserAvatar = isValidUrl ? avatarUrl : null;
          });
          
          print('Loaded avatar URL: $_currentUserAvatar'); // Debug print
        }
      }
    } catch (e) {
      print('Error loading user nickname: $e');
      setState(() {
        _currentUserNickname = 'Unknown User';
        _currentUserAvatar = null;
      });
    }
  }

  void _showMessageOptions(Map<String, dynamic> message, String messageId) {
    if (message['senderId'] == FirebaseAuth.instance.currentUser?.uid) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF2D3748),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text('Edit Message', 
                    style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(message, messageId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Message', 
                    style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(messageId);
                  },
                ),
              ],
            ),
          );
        },
      ).whenComplete(() {
        setState(() {
          _selectedMessageId = null;
        });
      });
    }
  }

  void _showDeleteConfirmation(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Delete Message',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this message?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              _deleteMessage(messageId);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> message, String messageId) {
    _editController.text = message['text'];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D3748),
          title: const Text('Edit Message', 
            style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
              hintText: 'Edit your message...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.white),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editMessage(messageId, _editController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editMessage(String messageId, String newText) async {
    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'text': newText,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error editing message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to edit message')),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete message')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _editController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String  _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    
    if (now.difference(date).inDays == 0) {
      // Today, show time
      return DateFormat('HH:mm').format(date);
    } else if (now.difference(date).inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MM/dd/yyyy').format(date);
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _sendTextMessage(_messageController.text.trim());
      _messageController.clear();
    }
  }

  Future<void> _sendTextMessage(String text) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Get fresh user data
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        final userData = userDoc.data() as Map<String, dynamic>?;
        final userAvatar = userData?['profileImage']; // Changed to profileImage
        
        print('Current user data: $userData'); // Debug print
        print('Avatar URL being sent: $userAvatar'); // Debug print
        
        final messageData = {
          'senderId': currentUser.uid,
          'senderNickname': _currentUserNickname,
          'senderAvatar': userAvatar,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'text',
        };
        
        print('Message data being sent: $messageData'); // Debug print

        await _firestore
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .add(messageData);

        await _firestore.collection('chats').doc(widget.chatId).update({
          'lastMessage': text,
          'lastMessageTime': FieldValue.serverTimestamp(),
        });

        _messageController.clear();
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }
}