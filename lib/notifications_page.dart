import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'avatarUrl': 'https://placehold.co/50x50',
      'title': 'Черный [90]',
      'subtitle': 'упоминает вас в STALKER NEW STORY [CLEAR SKY]',
      'time': '45 мин.',
      'message': "Хлопцы, я тут на деревню заглянул привез немного своего хабара...",
      'isRead': false,
      'type': 'mention',
    },
    {
      'avatarUrl': 'https://placehold.co/50x50',
      'title': 'Stitch',
      'subtitle': 'упоминает вас в Elysium',
      'time': '14 ч.',
      'message': "- Фрагменты будут из различных аниме. Заявки будут приниматься...",
      'isRead': true,
      'type': 'mention',
    },
    {
      'avatarUrl': 'https://placehold.co/50x50',
      'title': 'Система',
      'subtitle': 'Обновление безопасности',
      'time': '1 д.',
      'message': "Ваш аккаунт был успешно защищен с помощью двухфакторной аутентификации",
      'isRead': true,
      'type': 'system',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Уведомления',
          style: TextStyle(color: Colors.red[500]),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showNotificationSettings,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _refreshNotifications,
              color: Colors.red[500],
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) => _buildNotificationItem(_notifications[index]),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Нет уведомлений',
            style: TextStyle(color: Colors.grey[400], fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.red[700],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Уведомление удалено'),
            action: SnackBarAction(
              label: 'Отменить',
              onPressed: () {
                setState(() {
                  _notifications.add(notification);
                });
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _markAsRead(notification),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: notification['isRead'] 
                ? const Color(0xFF4A5568)
                : const Color(0xFF4A5568).withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: notification['isRead']
                ? null
                : Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(notification),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          notification['time'],
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['subtitle'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['message'],
                      style: const TextStyle(color: Colors.white60),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!notification['isRead'])
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[500]?.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Новое',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
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

  Widget _buildAvatar(Map<String, dynamic> notification) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(notification['avatarUrl']),
          radius: 24,
        ),
        if (notification['type'] == 'system')
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red[500],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _refreshNotifications() async {
    // Имитация загрузки новых уведомлений
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Здесь можно добавить логику обновления уведомлений
    });
  }

  void _markAsRead(Map<String, dynamic> notification) {
    if (!notification['isRead']) {
      setState(() {
        notification['isRead'] = true;
      });
    }
    // Здесь можно добавить навигацию к соответствующему контенту
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4A5568),
        title: const Text(
          'Фильтр уведомлений',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('Все уведомления'),
            _buildFilterOption('Непрочитанные'),
            _buildFilterOption('Упоминания'),
            _buildFilterOption('Системные'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        // Добавить логику фильтрации
      },
    );
  }

  void _showNotificationSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _NotificationSettingsPage(),
      ),
    );
  }
}

class _NotificationSettingsPage extends StatefulWidget {
  @override
  State<_NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<_NotificationSettingsPage> {
  bool _pushEnabled = true;
  bool _soundEnabled = true;
  bool _mentionsEnabled = true;
  bool _friendRequestsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Настройки уведомлений',
          style: TextStyle(color: Colors.red[500]),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection('Общие настройки', [
            _buildSwitchTile(
              'Push-уведомления',
              'Получать уведомления на устройство',
              _pushEnabled,
              (value) => setState(() => _pushEnabled = value),
            ),
            _buildSwitchTile(
              'Звук',
              'Воспроизводить звук при уведомлениях',
              _soundEnabled,
              (value) => setState(() => _soundEnabled = value),
            ),
          ]),
          _buildSettingsSection('Типы уведомлений', [
            _buildSwitchTile(
              'Упоминания',
              'Уведомления при упоминании вас',
              _mentionsEnabled,
              (value) => setState(() => _mentionsEnabled = value),
            ),
            _buildSwitchTile(
              'Заявки в друзья',
              'Уведомления о новых заявках в друзья',
              _friendRequestsEnabled,
              (value) => setState(() => _friendRequestsEnabled = value),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
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
