import 'package:flutter/material.dart';

class AuthorizedAppsPage extends StatefulWidget {
  const AuthorizedAppsPage({super.key});

  @override
  State<AuthorizedAppsPage> createState() => _AuthorizedAppsPageState();
}

class _AuthorizedAppsPageState extends State<AuthorizedAppsPage> {
  final List<Map<String, dynamic>> _authorizedApps = [
    {
      'name': 'Spotify',
      'icon': 'assets/spotify_icon.png',
      'permissions': ['Просмотр профиля', 'Подключение к статусу'],
      'authorizedDate': '15.03.2024',
    },
    {
      'name': 'GitHub',
      'icon': 'assets/github_icon.png',
      'permissions': ['Просмотр профиля', 'Доступ к репозиториям'],
      'authorizedDate': '10.03.2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Авторизованные приложения',
          style: TextStyle(color: Colors.red[500]),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              ..._authorizedApps.map(_buildAppCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Эти приложения имеют доступ к вашей базовой информации',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildAppCard(Map<String, dynamic> app) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                app['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () => _showRevokeDialog(app),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Авторизовано: ${app['authorizedDate']}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Разрешения:',
            style: TextStyle(color: Colors.white),
          ),
          ...List<Widget>.from(
            app['permissions'].map(
              (permission) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  '• $permission',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRevokeDialog(Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4A5568),
        title: Text(
          'Отозвать доступ ${app['name']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Вы уверены, что хотите отозвать доступ для ${app['name']}? '
          'Приложение больше не сможет получать доступ к вашей информации.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _authorizedApps.remove(app);
              });
              Navigator.pop(context);
            },
            child: Text(
              'Отозвать',
              style: TextStyle(color: Colors.red[500]),
            ),
          ),
        ],
      ),
    );
  }
} 