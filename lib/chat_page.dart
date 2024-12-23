import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1C1E), // Сделали цвет еще темнее
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/zcord_logo.png', // Ваш логотип
                height: 40, // Размер логотипа
                width: 40, // Размер логотипа
                fit: BoxFit.cover, // Обрезка под круг
              ),
            ),
            const SizedBox(width: 10), // Отступ между логотипом и текстом
            const Text(
              'ZCord', // Логотип приложения
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ChannelList(),
          ),
          Expanded(
            flex: 5,
            child: ChatBox(),
          ),
          Expanded(
            flex: 2,
            child: UserList(),
          ),
        ],
      ),
    );
  }
}

class ChannelList extends StatelessWidget {
  const ChannelList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101214), // Сделали фон еще темнее
        border: Border.all(
          color: Colors.redAccent, // Ярко-красная обводка
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.8), // Красная тень для неонового эффекта
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Channels',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(color: Colors.red),
          ListTile(
            title: Text(
              '# general',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ListTile(
            title: Text(
              '# random',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ListTile(
            title: Text(
              '# coding',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBox extends StatelessWidget {
  const ChatBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF191A1C), // Более темный фон для чата
              border: Border.all(
                color: Colors.redAccent, // Ярко-красная обводка
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: const [
                ListTile(
                  title: Text(
                    'User1: Hello World!',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ListTile(
                  title: Text(
                    'User2: Hi there!',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            style: const TextStyle(color: Colors.red),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F1011), // Очень темный фон для ввода
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.redAccent, // Красная обводка вокруг поля ввода
                  width: 2,
                ),
              ),
              hintText: 'Type a message...',
              hintStyle: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101214), // Темный фон для списка пользователей
        border: Border.all(
          color: Colors.redAccent, // Ярко-красная обводка
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.8), // Неоновое свечение
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Users',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(color: Colors.red),
          ListTile(
            title: Text(
              'User1',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ListTile(
            title: Text(
              'User2',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ListTile(
            title: Text(
              'User3',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
