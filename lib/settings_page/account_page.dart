import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    try {
      User? user = _auth.currentUser; // Get the current user
      if (user != null) {
        setState(() {
          userEmail = user.email; // Set user's email
          userName = user.displayName ?? ""; // Set user's display name (if available)
        });
      }
    } catch (e) {
      print("Error fetching user email: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path); // Set selected image
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _saveChanges() async {
    try {
      // Logic to save changes (e.g., update Firebase user profile or Firestore)
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(userName); // Update the user's display name
        if (_profileImage != null) {
          // Upload the profile image to Firebase Storage (placeholder)
          // Example: Upload file to Firebase Storage and update user's profile photo URL
        }
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Изменения были сохранены.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error saving changes: $e");
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить изменения.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red[500]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Аккаунт',
          style: TextStyle(color: Colors.red[500]),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Trigger image picker
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) // Display selected image
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.red[500],
                      radius: 15,
                      child: Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Почтовый адрес',
              hint: userEmail ?? 'Загрузка...', // Display user's email or a loading state
              icon: Icons.email,
              onChanged: (value) {
                // Email is read-only in this example
              },
              readOnly: true,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Имя пользователя',
              hint: userName ?? 'Ваше имя пользователя',
              icon: Icons.person,
              onChanged: (value) {
                setState(() {
                  userName = value; // Update userName on change
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges, // Save changes action
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[500],
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF4A5568),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(icon, color: Colors.red[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
