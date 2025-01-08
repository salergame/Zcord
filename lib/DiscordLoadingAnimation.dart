import 'package:flutter/material.dart';

void main() {
  runApp(Discordloadinganimation());
}

class Discordloadinganimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Первая страница')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Показать анимацию загрузки
            await Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SecondPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return Stack(
                  children: [
                    FadeTransition(opacity: animation, child: child),
                    if (animation.status != AnimationStatus.completed)
                      Center(child: DiscordLoadingAnimation()),
                  ],
                );
              },
            ));
          },
          child: Text('Перейти на вторую страницу'),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вторая страница')),
      body: Center(
        child: Text('Добро пожаловать на вторую страницу!'),
      ),
    );
  }
}

class DiscordLoadingAnimation extends StatefulWidget {
  @override
  _DiscordLoadingAnimationState createState() =>
      _DiscordLoadingAnimationState();
}

class _DiscordLoadingAnimationState extends State<DiscordLoadingAnimation>
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
                child: CircleAvatar(
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
