import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'discord_loading_animation.dart'; // импорт загрузки дискорда
import 'chat_page.dart'; // Импорт страницы чата
import 'forgot_password.dart'; // Импорт страницы восстановления пароля
import 'reg.dart'; // Импорт страницы регистрации

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ru')],
    path: 'assets/lang', // Путь к файлам перевода
    fallbackLocale: const Locale('en'),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZCord',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red[800],
        scaffoldBackgroundColor: const Color(0xFF000000),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.red.withOpacity(0.8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.red.withOpacity(0.6)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
          ),
        ),
      ),
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      home: const ZCordLoginPage(), // Страница авторизации
    );
  }
}

class ZCordLoginPage extends StatefulWidget {
  const ZCordLoginPage({super.key});

  @override
  ZCordLoginPageState createState() => ZCordLoginPageState();
}

class ZCordLoginPageState extends State<ZCordLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signIn() async {
    // Show the loading animation while signing in
    showDialog(
      context: context,
      builder: (context) => const Center(child: DiscordLoadingAnimation()),
    );

    try {
      // Try to sign in the user with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Close the loading animation dialog after successful login
      if (!mounted) return; // Check if the widget is still mounted
      Navigator.pop(context);

      // Check if the user is authenticated
      if (userCredential.user != null) {
        // Navigate to the chat page after successful login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
              (route) => false, // Remove all the previous routes
        );
      }
    } on FirebaseAuthException catch (e) {
      // Close the loading animation dialog in case of error
      if (!mounted) return; // Check if the widget is still mounted
      Navigator.pop(context);
// TODO: настроить уведомления которые соотвествуют ошибкам
      if (e.code == 'invalid_credentials') {
        _showErrorDialog(tr('invalid_credentials'));
      } else if (e.code == 'wrong-password') {
        _showErrorDialog(tr('wrong_password'));
      } else if (e.code == 'invalid-email') {
        _showErrorDialog(tr('invalid_email'));
      } else if (e.code == 'network-request-failed') {
        _showErrorDialog(tr('network_error'));
      } else {
        _showErrorDialog(tr('unexpected_error'));
      }
    } catch (e) {
      // Handle unexpected errors
      Navigator.pop(context);
      _showErrorDialog(tr('unexpected_error'));
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('error')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog when "OK" is pressed
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZCord'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String languageCode) {
              context.setLocale(Locale(languageCode));
            },
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem(value: 'en', child: Text('English')),
                PopupMenuItem(value: 'ru', child: Text('Русский')),
              ];
            },
          ),
        ],
      ),
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
                Text(
                  tr('welcome_back'),
                  style: const TextStyle(
                    fontFamily: 'YesevaOne',
                    color: Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tr('excited_to_see_you'),
                  style: const TextStyle(
                    fontFamily: 'YesevaOne',
                    color: Colors.redAccent,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: tr('email_or_phone'),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: tr('password'),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signIn, // Вызов аутентификации
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      tr('login'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    // Переход на страницу восстановления пароля
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPassword()),
                    );
                  },
                  child: Text(
                    tr('forgot_password'),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    // Переход на страницу регистрации
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationPage()),
                    );
                  },
                  child: Text(
                    tr('register'),
                    style: const TextStyle(
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
