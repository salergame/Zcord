import 'package:flutter/material.dart';
import 'chat_page.dart'; // Импортируем новый файл с чатами

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZCord Login',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red[800],
        scaffoldBackgroundColor: const Color(0xFF000000), // Фон в стиле логотипа
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.red.withOpacity(0.8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A), // Фон для полей ввода
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.red.withOpacity(0.6)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800], // Кнопка того же цвета
          ),
        ),
      ),
      home: const ZCordLoginPage(),
    );
  }
}

class ZCordLoginPage extends StatefulWidget {
  const ZCordLoginPage({super.key});

  @override
  State<ZCordLoginPage> createState() => _ZCordLoginPageState();
}

class _ZCordLoginPageState extends State<ZCordLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500), // Ширина блока
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // Темный фон для блока авторизации
              borderRadius: BorderRadius.circular(12), // Скругление углов
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5), // Цвет тени
                  spreadRadius: 5, // Распространение тени
                  blurRadius: 15, // Размытие тени
                  offset: const Offset(0, 4), // Смещение тени
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30), // Уменьшенные отступы внутри контейнера
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/zcord_logo.png', // Вставка логотипа
                    height: 100,
                    width: 100, // Задаем ширину для кругового изображения
                    fit: BoxFit.cover, // Заполнение круга
                  ),
                ),
                const SizedBox(height: 15), // Уменьшенный отступ
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontFamily: 'YesevaOne', // Использование шрифта Yeseva One
                    color: Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5), // Уменьшенный отступ
                const Text(
                  'We are so excited to see you again!',
                  style: TextStyle(
                    fontFamily: 'YesevaOne', // Использование шрифта Yeseva One
                    color: Colors.redAccent,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15), // Уменьшенный отступ
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email or Phone Number',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 5), // Уменьшенный отступ
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 15), // Уменьшенный отступ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Логика входа
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 15), // Уменьшенный отступ
                TextButton(
                  onPressed: () {
                    // Логика восстановления пароля
                  },
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: Colors.redAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 5), // Уменьшенный отступ
                TextButton(
                  onPressed: () {
                    // Логика регистрации
                  },
                  child: const Text(
                    'Need an account? Register',
                    style: TextStyle(
                      color: Colors.redAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 15), // Уменьшенный отступ
                ElevatedButton(
                  onPressed: () {
                    // Переход на страницу с чатами
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    'Go to Chat Page',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
