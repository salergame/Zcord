import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'chat_page.dart'; // Import chat page
import 'ForgPas.dart';
import 'reg.dart'; // Import registration page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ru')],
    path: 'assets/lang', // Path to translation files
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
      home: const ZCordLoginPage(),
    );
  }
}

class ZCordLoginPage extends StatelessWidget {
  const ZCordLoginPage({super.key});

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('error')),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(tr('ok')),
            ),
          ],
        );
      },
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
                  decoration: InputDecoration(
                    hintText: tr('email_or_phone'),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 5),
                TextField(
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
                    onPressed: () {
                      // Simulate login logic
                      bool isValid = false; // Replace with actual validation logic
                      if (!isValid) {
                        _showErrorDialog(
                          context,
                          tr('invalid_credentials'),
                        );
                      } else {
                        // Navigate to Chat Page if valid
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChatPage()),
                        );
                      }
                    },
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
                    // Navigate to Forgot Password page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgPas()),
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
                    // Navigate to Registration page
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
                const SizedBox(height: 15), // Reduced space
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Chat Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text(
                    tr('go_to_chat'),
                    style: const TextStyle(fontSize: 16),
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
