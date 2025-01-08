import 'package:flutter/material.dart';

void main() {
  runApp(const DiscordLoadingAnimationApp());
}

class DiscordLoadingAnimationApp extends StatelessWidget {
  const DiscordLoadingAnimationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FirstPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Первая страница')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Show loading animation
            await Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
              const SecondPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return Stack(
                  children: [
                    FadeTransition(opacity: animation, child: child),
                    if (animation.status != AnimationStatus.completed)
                      const Center(child: DiscordLoadingAnimation()),  // const constructor used
                  ],
                );
              },
            ));
          },
          child: const Text('Перейти на вторую страницу'),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вторая страница')),
      body: const Center(
        child: Text('Добро пожаловать на вторую страницу!'),
      ),
    );
  }
}

class DiscordLoadingAnimation extends StatefulWidget {
  const DiscordLoadingAnimation({super.key});  // Added key parameter

  @override
  DiscordLoadingAnimationState createState() => DiscordLoadingAnimationState();
}

class DiscordLoadingAnimationState extends State<DiscordLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return Transform.scale(
              scale: 1.0 + 0.2 * _animation.value * ((index % 2) == 0 ? 1 : -1),
              child: Opacity(
                opacity: 0.5 + 0.5 * (1 - _animation.value),
                child: const CircleAvatar(
                  radius: 8.0,
                  backgroundColor: Colors.blue,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
