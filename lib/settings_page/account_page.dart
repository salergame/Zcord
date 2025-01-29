import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? userEmail;
  String? userName; // To store the user's nickname
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailPasswordController = TextEditingController();
  ImageProvider? _cachedProfileImage;
  late Future<void> _initDataFuture;

  @override
  void initState() {
    super.initState();
    _initDataFuture = _getUserData();
    _loadCachedImage();
  }

  Future<void> _loadCachedImage() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final userData = await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists) {
          final data = userData.data();
          if (data != null && data['profileImage'] != null) {
            final bytes = base64Decode(data['profileImage']);
            setState(() {
              _cachedProfileImage = MemoryImage(bytes);
            });
          }
        }
      }
    } catch (e) {
      print("Error loading cached image: $e");
    }
  }

  Future<void> _getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Fetch user data from Firestore
        final userData = await _firestore.collection('users').doc(user.uid).get();
        
        setState(() {
          userEmail = user.email;
          if (userData.exists) {
            final data = userData.data();
            if (data != null && data['nickname'] != null) {
              userName = data['nickname'];
              _nicknameController.text = data['nickname'];
            }
          }
        });

        // Handle profile image
        if (userData.exists) {
          final data = userData.data();
          if (data != null && data['profileImage'] != null) {
            final bytes = base64Decode(data['profileImage']);
            final tempDir = Directory.systemTemp;
            final tempFile = File('${tempDir.path}/profile_image.png');
            await tempFile.writeAsBytes(bytes);
            
            setState(() {
              _profileImage = tempFile;
              _cachedProfileImage = MemoryImage(bytes);
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        
        setState(() {
          _profileImage = imageFile;
          _cachedProfileImage = MemoryImage(bytes);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _saveChanges() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(userName);
        
        if (_profileImage != null) {
          // Convert image file to base64 string
          final bytes = await _profileImage!.readAsBytes();
          final base64Image = base64Encode(bytes);
          
          // Save to Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'profileImage': base64Image,
            'nickname': userName,
          }, SetOptions(merge: true));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Изменения были сохранены.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error saving changes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить изменения.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Новые пароли не совпадают'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Reauthenticate user first
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);

        // Clear the text fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        Navigator.pop(context); // Close the dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пароль успешно изменен'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Произошла ошибка при смене пароля';
      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          errorMessage = 'Текущий пароль неверен';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _changeEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Reauthenticate user first
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _emailPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updateEmail(_emailController.text);

        // Update state and clear controllers
        setState(() {
          userEmail = _emailController.text;
        });
        _emailController.clear();
        _emailPasswordController.clear();

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Электронная почта успешно изменена'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Произошла ошибка при смене почты';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            errorMessage = 'Неверный пароль';
            break;
          case 'email-already-in-use':
            errorMessage = 'Эта почта уже используется';
            break;
          case 'invalid-email':
            errorMessage = 'Неверный формат электронной почты';
            break;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Изменить пароль', 
          style: TextStyle(color: Colors.red[500])
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF4A5568),
                hintText: 'Текущий пароль',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF4A5568),
                hintText: 'Новый пароль',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF4A5568),
                hintText: 'Подтвердите новый пароль',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', 
              style: TextStyle(color: Colors.red[500])
            ),
          ),
          ElevatedButton(
            onPressed: _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[500],
            ),
            child: const Text('Изменить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Изменить почту', 
          style: TextStyle(color: Colors.red[500])
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF4A5568),
                hintText: 'Новая электронная почта',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF4A5568),
                hintText: 'Введите пароль для подтверждения',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', 
              style: TextStyle(color: Colors.red[500])
            ),
          ),
          ElevatedButton(
            onPressed: _changeEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[500],
            ),
            child: const Text('Изменить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Show confirmation dialog
        bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: Text('Удаление аккаунта',
                style: TextStyle(color: Colors.red[500])),
            content: const Text(
              'Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Отмена',
                    style: TextStyle(color: Colors.red[500])),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[500],
                ),
                child: const Text('Удалить',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ?? false;

        if (confirm) {
          await user.delete();
          // Navigate to login screen or home
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login'); // Adjust according to your route
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка при удалении аккаунта'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _disableAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Деактивация аккаунта',
            style: TextStyle(color: Colors.red[500])),
        content: const Text(
          'Вы уверены, что хотите деактивировать свой аккаунт?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена',
                style: TextStyle(color: Colors.red[500])),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement account disabling logic here
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[500],
            ),
            child: const Text('Деактивировать',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red[500]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Аккаунт',
          style: TextStyle(color: Colors.red[500]),
        ),
      ),
      body: FutureBuilder(
        future: _initDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _cachedProfileImage ??
                            (_profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage('assets/default_avatar.png') as ImageProvider),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.red[500],
                            radius: 15,
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Информация об аккаунте section
                  _buildSectionTitle('Информация об аккаунте'),
                  _buildInfoTile(
                    'Никнейм',
                    userName ?? 'Не указано',
                    Icons.person,
                    onTap: () => _showNicknameDialog(),
                  ),
                  _buildInfoTile(
                    'Электронная почта',
                    userEmail ?? 'Не указано',
                    Icons.email,
                    onTap: _showChangeEmailDialog,
                  ),
                  _buildInfoTile(
                    'Телефон',
                    '+XXXXXXXXXX',
                    Icons.phone,
                    onTap: () {
                      // Handle phone edit
                    },
                  ),
                  _buildActionTile(
                    'Изменить пароль',
                    'Изменить пароль учетной записи',
                    Icons.lock,
                    _showChangePasswordDialog,
                  ),

                  const SizedBox(height: 30),

                  // Управление аккаунтом section
                  _buildSectionTitle('Управление аккаунтом'),
                  _buildActionTile(
                    'Деактивировать аккаунт',
                    'Временно отключить доступ к аккаунту',
                    Icons.pause_circle_outline,
                    _disableAccount,
                  ),
                  _buildActionTile(
                    'Удалить аккаунт',
                    'Навсегда удалить ваш аккаунт',
                    Icons.delete_forever,
                    _deleteAccount,
                    isDestructive: true,
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[500],
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Сохранить изменения',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _emailPasswordController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.red[500],
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.red[500]),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.red[500], size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.red[500],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.red[500],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showNicknameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Изменить никнейм', 
          style: TextStyle(color: Colors.red[500])
        ),
        content: TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF4A5568),
            hintText: 'Введите новый никнейм',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', 
              style: TextStyle(color: Colors.red[500])
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                userName = _nicknameController.text;
              });
              await _saveChanges();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[500],
            ),
            child: const Text('Сохранить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
