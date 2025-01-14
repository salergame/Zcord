import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'settings_page/account_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Настройки',
          style: TextStyle(color: Colors.red[500]),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), // Logout Icon
            onPressed: () async {
              // Firebase logout
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Zcord()),
                    (route) => false, // Clear navigation stack
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF4A5568),
                hintText: 'Поиск',
                hintStyle: TextStyle(color: Colors.red[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.red[500]),
            ),
            const SizedBox(height: 20),
            // Account Settings Section
            const SectionHeader(title: 'Настройки аккаунта'),
            SettingsItem(
              icon: Icons.person,
              title: 'Аккаунт',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountPage()),
                );
              },
            ),
            SettingsItem(
              icon: Icons.shield,
              title: 'Конфиденциальность и безопасность',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.key,
              title: 'Авторизованные приложения',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.devices,
              title: 'Устройства',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.person_add,
              title: 'Заявки в друзья',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.qr_code,
              title: 'Сканирование QR Кода',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            // Billing Settings Section
            const SectionHeader(title: 'Настройки выставления счетов'),
            SettingsItem(
              icon: Icons.rocket,
              title: 'Управление подпиской Nitro',
              onTap: () {},
            ),
            SettingsItem(
              icon: Icons.atm,
              title: 'Сервер Boost',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF4A5568),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red[500]),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}