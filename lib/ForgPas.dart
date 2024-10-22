import 'package:flutter/material.dart';

class ForgPas extends StatefulWidget {
  const ForgPas({super.key});

  @override
  State<ForgPas> createState() => _ForgPasState();
}

class _ForgPasState extends State<ForgPas> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;

  void _sendResetLink() {
    // Проверка, что поле не пустое
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email cannot be empty.';
      });
      return;
    }

    // Здесь можно добавить логику для отправки ссылки на сброс пароля
    // Например, отправить запрос на сервер

    setState(() {
      _errorMessage = null; // Очистить сообщение об ошибке
    });

    // Вывод сообщения об успешной отправке ссылки
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reset link sent to ${_emailController.text}')),
    );

    // Очистка поля
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/zcord_logo.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontFamily: 'YesevaOne',
                    color: Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Enter your email to reset your password.',
                  style: TextStyle(
                    fontFamily: 'YesevaOne',
                    color: Colors.redAccent,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),

                // Поле для ввода email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 15),

                // Отображение сообщения об ошибке
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Send Reset Link',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    // Переход на страницу входа
                    Navigator.pop(context); // Возвращаемся назад
                  },
                  child: const Text(
                    'Remembered your password? Login',
                    style: TextStyle(
                      color: Colors.redAccent,
                      decoration: TextDecoration.underline,
                    ),
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
