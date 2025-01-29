import 'package:flutter/material.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final List<Map<String, dynamic>> _devices = [
    {
      'name': 'Текущее устройство',
      'type': 'Android',
      'model': 'Samsung Galaxy S21',
      'location': 'Москва, Россия',
      'lastActive': 'Сейчас',
      'icon': Icons.phone_android,
      'isCurrent': true,
    },
    {
      'name': 'Chrome',
      'type': 'Browser',
      'model': 'Windows 10',
      'location': 'Санкт-Петербург, Россия',
      'lastActive': '2 часа назад',
      'icon': Icons.computer,
      'isCurrent': false,
    },
    {
      'name': 'iPad',
      'type': 'Tablet',
      'model': 'iPad Pro 2021',
      'location': 'Москва, Россия',
      'lastActive': '1 день назад',
      'icon': Icons.tablet_mac,
      'isCurrent': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Устройства',
          style: TextStyle(color: Colors.red[500]),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.red[500]),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentSessionHeader(),
              ..._devices.map((device) => _buildDeviceItem(device)),
              _buildSecurityTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSessionHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Текущий сеанс',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDeviceItem(Map<String, dynamic> device) {
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
            children: [
              Icon(device['icon'] as IconData, color: Colors.red[500]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${device['type']} • ${device['model']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!device['isCurrent'])
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => _showLogoutDialog(device),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDeviceInfo('Местоположение', device['location']),
          _buildDeviceInfo('Последняя активность', device['lastActive']),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTips() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Советы по безопасности',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Регулярно проверяйте список устройств\n'
            '• Выходите из аккаунта на неиспользуемых устройствах\n'
            '• Включите двухфакторную аутентификацию',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4A5568),
        title: Text(
          'Выйти с устройства ${device['name']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Вы уверены, что хотите выйти с этого устройства?\n'
          'Местоположение: ${device['location']}\n'
          'Последняя активность: ${device['lastActive']}',
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
                _devices.remove(device);
              });
              Navigator.pop(context);
            },
            child: Text(
              'Выйти',
              style: TextStyle(color: Colors.red[500]),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4A5568),
        title: const Text(
          'Управление устройствами',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Здесь вы можете управлять всеми устройствами, на которых выполнен вход '
          'в ваш аккаунт. Вы можете отслеживать активность и при необходимости '
          'выходить из аккаунта на неиспользуемых устройствах.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Понятно',
              style: TextStyle(color: Colors.red[500]),
            ),
          ),
        ],
      ),
    );
  }
} 