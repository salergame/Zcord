import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _twoFactorEnabled = false;
  bool _showOnlineStatus = true;
  bool _allowDirectMessages = true;
  bool _allowFriendRequests = true;
  bool _privateProfile = false;
  bool _showLastSeen = true;
  String _whoCanAddMe = 'all'; // 'all', 'friends', 'nobody'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Конфиденциальность',
          style: TextStyle(color: Colors.red[500]),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Безопасность'),
              _buildSwitchTile(
                'Двухфакторная аутентификация',
                'Дополнительный уровень безопасности для вашего аккаунта',
                _twoFactorEnabled,
                (value) => setState(() => _twoFactorEnabled = value),
              ),
              _buildPasswordButton(),
              
              _buildSectionHeader('Приватность'),
              _buildSwitchTile(
                'Закрытый профиль',
                'Только друзья смогут видеть ваш профиль',
                _privateProfile,
                (value) => setState(() => _privateProfile = value),
              ),
              _buildSwitchTile(
                'Показывать статус онлайн',
                'Другие пользователи смогут видеть, когда вы онлайн',
                _showOnlineStatus,
                (value) => setState(() => _showOnlineStatus = value),
              ),
              _buildSwitchTile(
                'Показывать последнее посещение',
                'Другие пользователи смогут видеть, когда вы были в сети последний раз',
                _showLastSeen,
                (value) => setState(() => _showLastSeen = value),
              ),

              _buildSectionHeader('Сообщения и контакты'),
              _buildSwitchTile(
                'Личные сообщения',
                'Разрешить отправку личных сообщений',
                _allowDirectMessages,
                (value) => setState(() => _allowDirectMessages = value),
              ),
              _buildSwitchTile(
                'Заявки в друзья',
                'Разрешить отправку заявок в друзья',
                _allowFriendRequests,
                (value) => setState(() => _allowFriendRequests = value),
              ),
              
              _buildSectionHeader('Кто может добавить меня в друзья'),
              _buildRadioTile(
                'Все',
                'all',
              ),
              _buildRadioTile(
                'Друзья друзей',
                'friends',
              ),
              _buildRadioTile(
                'Никто',
                'nobody',
              ),

              _buildSectionHeader('Заблокированные пользователи'),
              _buildBlockedUsersList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPasswordButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Добавить логику изменения пароля
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF4A5568),
              title: const Text(
                'Изменить пароль',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Текущий пароль',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Новый пароль',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    // Добавить логику сохранения пароля
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Сохранить',
                    style: TextStyle(color: Colors.red[500]),
                  ),
                ),
              ],
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Изменить пароль',
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.red[500], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          Radio(
            value: value,
            groupValue: _whoCanAddMe,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _whoCanAddMe = newValue);
              }
            },
            activeColor: Colors.red[500],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUsersList() {
    // Здесь можно добавить список заблокированных пользователей
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'У вас нет заблокированных пользователей',
            style: TextStyle(color: Colors.grey),
          ),
          TextButton(
            onPressed: () {
              // Добавить логику просмотра заблокированных пользователей
            },
            child: Text(
              'Управление заблокированными пользователями',
              style: TextStyle(color: Colors.red[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.red[500],
          ),
        ],
      ),
    );
  }
} 