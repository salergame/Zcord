import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NotificationItem(
            avatarUrl: 'https://placehold.co/50x50',
            title: 'Черный [90]',
            subtitle: 'упоминает вас в STALKER NEW STORY [CLEAR SKY]',
            time: '45 мин.',
            message: "Хлопцы, я тут на деревню заглянул привез немного своего хабара...",
          ),
          NotificationItem(
            avatarUrl: 'https://placehold.co/50x50',
            title: 'Stitch',
            subtitle: 'упоминает вас в Elysium',
            time: '14 ч.',
            message: "- Фрагменты будут из различных аниме. Заявки будут приниматься...",
          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String avatarUrl;
  final String title;
  final String subtitle;
  final String time;
  final String message;

  const NotificationItem({
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            radius: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white60),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
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
