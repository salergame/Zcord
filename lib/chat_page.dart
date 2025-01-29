import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'server_options_menu.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart'; // using any other image handlers crashes the app on launch
import 'package:path_provider/path_provider.dart';
import 'dart:io'; 

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData.dark(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MessagesListPage(),
    const NotificationsPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2D3748),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Уведомления',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Вы',
          ),
        ],
      ),
    );
  }
}

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({super.key});

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  List<Map<String, dynamic>> _servers = [];
  List<Map<String, dynamic>> _groups = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadServersAndGroups();
  }

  void _loadServersAndGroups() {
    // Listen to servers
    _firestore
        .collection('servers')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _servers = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc['name'],
          'image': doc['image'],
          'description': doc['description'],
          'ownerId': doc['ownerId'],
        }).toList();
      });
    });

    // Listen to groups
    _firestore
        .collection('groups')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _groups = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc['name'],
          'image': doc['image'],
          'description': doc['description'],
          'ownerId': doc['ownerId'],
        }).toList();
      });
    });
  }

  void _createEntity() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2D3748),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.people, color: Colors.white),
                  ),
                  title: const Text(
                    'Create a Server',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Your own community with channels',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateServerDialog();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.group, color: Colors.white),
                  ),
                  title: const Text(
                    'Create a Group DM',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Private group with friends',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateGroupDialog();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person_add, color: Colors.white),
                  ),
                  title: const Text(
                    'Direct Message',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Chat with other users',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showUsersList();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateServerDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Create a Server',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Server Name',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  await _firestore.collection('servers').add({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'image': imageController.text,
                    'ownerId': currentUser.uid,
                    'members': [currentUser.uid],
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),  
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    // Similar to _showCreateServerDialog but for groups
    // Add user selection functionality for group members
  }

  void _showUsersList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsersListPage(),
      ),
    );
  }

  void _onServerSelected(String serverId, String serverName, String ownerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(
          chatId: serverId,
          title: Row(
            children: [
              Text(serverName),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServerOptionsMenu(
                        serverId: serverId,
                        serverName: serverName,
                        ownerId: ownerId,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onGroupSelected(String groupId, String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(
          chatId: groupId,
          title: Text(groupName),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 60,
            color: const Color(0xFF1a202c),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/zcord_logo.png'),
                  radius: 20,
                ),
                const SizedBox(height: 16),
                // List of Servers
                for (var server in _servers)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () => _onServerSelected(
                        server['id']!, 
                        server['name']!,
                        server['ownerId']!,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(server['image']!),
                        radius: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: _createEntity,
                    backgroundColor: Colors.grey[700],
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  color: const Color(0xFF2d3748),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Сообщения',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF4a5568),
                            hintText: 'Поиск',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Messages List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: _groups.map((group) {
                      return Card(
                        color: const Color(0xFF2d3748),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          onTap: () => _onGroupSelected(group['id']!, group['name']!),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(group['image']!),
                          ),
                          title: Text(
                            group['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            group['description']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
  final FocusNode _focusNode = FocusNode();
  String? _currentUserNickname;
  final ImagePicker _picker = ImagePicker();
  String? _selectedMessageId;
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserNickname();
    _ensureChatExists();
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
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _currentUserNickname = userData?['nickname'] ?? currentUser.displayName ?? 'Unknown';
          });
        } else {
          // Create user document if it doesn't exist
          final defaultNickname = currentUser.displayName ?? 'User${currentUser.uid.substring(0, 4)}';
          await _firestore.collection('users').doc(currentUser.uid).set({
            'nickname': defaultNickname,
            'email': currentUser.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
          setState(() {
            _currentUserNickname = defaultNickname;
          });
        }
      }
    } catch (e) {
      print('Error loading user nickname: $e');
      // Set a fallback nickname
      setState(() {
        _currentUserNickname = 'Unknown User';
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Get user data including avatar
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();
          
          final userData = userDoc.data() as Map<String, dynamic>?;
          
          await _firestore
              .collection('chats')
              .doc(widget.chatId)
              .collection('messages')
              .add({
            'senderId': currentUser.uid,
            'senderNickname': _currentUserNickname,
            'senderAvatar': userData?['avatarUrl'],
            'default_avatar': userData?['avatarUrl'] == null ? true : null, // Track if using default
            'text': _messageController.text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Update last message in chat document
          await _firestore.collection('chats').doc(widget.chatId).update({
            'lastMessage': _messageController.text.trim(),
            'lastMessageTime': FieldValue.serverTimestamp(),
          });

          _messageController.clear();
        }
      } catch (e) {
        print('Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error sending message. Please try again.'),
          ),
        );
      }
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
        
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await _firestore
              .collection('chats')
              .doc(widget.chatId)
              .collection('messages')
              .add({
            'senderId': currentUser.uid,
            'senderNickname': _currentUserNickname,
            'imageBase64': base64Image,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'image',
          });

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
            leading: const Icon(Icons.save_alt, color: Colors.white),
            title: const Text('Save/Share Image', style: TextStyle(color: Colors.white)),
            onTap: () async {
              Navigator.pop(context);
              try {
                final bytes = base64Decode(base64Image);
                final tempDir = await getTemporaryDirectory();
                final file = File('${tempDir.path}/zcord_${DateTime.now().millisecondsSinceEpoch}.jpg');
                await file.writeAsBytes(bytes);
                
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: 'Image from Zcord',
                ).then((_) async {
                  // Clean up temp file after sharing
                  if (await file.exists()) {
                    await file.delete();
                  }
                });
              } catch (e) {
                print('Error handling image: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to handle image')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F), // Discord's dark background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2F3136), // Discord's darker header
        title: widget.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              // Implement video call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Implement voice call functionality
            },
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
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final messageId = messages[index].id;
                    final isCurrentUser = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                    final isSelected = messageId == _selectedMessageId;

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
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          image: DecorationImage(
                                            image: message['senderAvatar'] != null
                                                ? NetworkImage(message['senderAvatar'])
                                                : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isCurrentUser ? Colors.blue : Colors.green,
                                  backgroundImage: message['senderAvatar'] != null
                                      ? NetworkImage(message['senderAvatar'])
                                      : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                  child: (message['senderAvatar'] == null && message['default_avatar'] == null)
                                      ? Text(
                                          (message['senderNickname'] ?? 'U')[0].toUpperCase(),
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
                                          message['senderNickname'] ?? 'Unknown User',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isCurrentUser ? Colors.blue : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatTimestamp(message['timestamp']),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (message['type'] == 'image')
                                      GestureDetector(
                                        onTap: () {
                                          // Show full-size image in dialog with options
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  Image.memory(
                                                    base64Decode(message['imageBase64']),
                                                    fit: BoxFit.contain,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.more_vert,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _showImageOptions(message['imageBase64']);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
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
                                    else
                                      Text(
                                        message['text'] ?? '',
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

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatTimestamp(Timestamp? timestamp) {
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
}

Stream<QuerySnapshot> getUsers() {
  return FirebaseFirestore.instance.collection('users').snapshots();
}

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Messages'),
        backgroundColor: const Color(0xFF2D3748),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['photoUrl'] != null
                      ? NetworkImage(user['photoUrl'])
                      : null,
                  child: user['photoUrl'] == null
                      ? Text(user['nickname']?[0] ?? 'U')
                      : null,
                ),
                title: Text(user['nickname'] ?? 'Unknown User'),
                subtitle: Text(user['status'] ?? 'Online'),
                onTap: () => _startChat(context, users[index].id, user['nickname']),
              );
            },
          );
        },
      ),
    );
  }

  void _startChat(BuildContext context, String userId, String userName) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final chatId = _getChatId(currentUser.uid, userId);
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

  String _getChatId(String uid1, String uid2) {
    // Ensure consistent chat ID regardless of who initiates
    return uid1.compareTo(uid2) < 0 ? '$uid1-$uid2' : '$uid2-$uid1';
  }
}

Future<void> createChatRoom(String chatId, String participantId) async {
  final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
  final chatSnapshot = await chatRef.get();

  if (!chatSnapshot.exists) {
    await chatRef.set({
      'participants': [FirebaseAuth.instance.currentUser!.uid, participantId],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class CreateEntityPage extends StatefulWidget {
  final String entityType; // "server" or "group"

  const CreateEntityPage({
    super.key,
    required this.entityType,
  });

  @override
  State<CreateEntityPage> createState() => _CreateEntityPageState();
}

class _CreateEntityPageState extends State<CreateEntityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveEntity() async {
    final name = _nameController.text.trim();
    final image = _imageController.text.trim();

    if (name.isEmpty || image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both a name and an image URL.')),
      );
      return;
    }

    final newEntity = {
      'name': name,
      'image': image,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection(widget.entityType).add(newEntity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.entityType.capitalize()} created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create ${widget.entityType}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.entityType.capitalize()}'),
        backgroundColor: const Color(0xFF2D3748),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${widget.entityType.capitalize()} Name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveEntity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}