import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const DiscordLoadingAnimation());
}

class DiscordLoadingAnimation extends StatelessWidget {
  const DiscordLoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: LoadingAnimation(),
        ),
      ),
    );
  }
}

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key});

  @override
  LoadingAnimationState createState() => LoadingAnimationState();
}

class LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _setRandomDuration();
  }

  void _setRandomDuration() {
    final randomDuration = Duration(milliseconds: _random.nextInt(2000) + 6000); // Random duration between 1-3 seconds
    _controller = AnimationController(
      vsync: this,
      duration: randomDuration,
    )..repeat();

    // Change duration at the end of each animation cycle
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.stop();
        _setRandomDuration();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(64, 48),
          painter: PolylinePainter(_controller.value),
        );
      },
    );
  }
}

class PolylinePainter extends CustomPainter {
  final double progress;

  PolylinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paintBack = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintFront = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.157, size.height / 2)
      ..lineTo(size.width * 0.218, size.height / 2)
      ..lineTo(size.width * 0.34, size.height)
      ..lineTo(size.width * 0.67, 0)
      ..lineTo(size.width * 0.78, size.height / 2)
      ..lineTo(size.width, size.height / 2);

    // Draw back path
    canvas.drawPath(path, paintBack);

    // Draw front path with dash effect
    final dashArray = [48.0, 144.0];
    final totalLength = dashArray.reduce((a, b) => a + b);
    final dashOffset = progress * totalLength;

    _drawDashedPath(canvas, path, paintFront, dashArray, dashOffset);
  }

  void _drawDashedPath(
      Canvas canvas,
      Path path,
      Paint paint,
      List<double> dashArray,
      double dashOffset,
      ) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = -dashOffset;
      while (distance < metric.length) {
        final start = distance.clamp(0.0, metric.length.toDouble()).toDouble();
        final end =
        (distance + dashArray[0]).clamp(0.0, metric.length.toDouble()).toDouble();
        if (start < end) {
          final extractPath = metric.extractPath(start, end);
          canvas.drawPath(extractPath, paint);
        }
        distance += dashArray.reduce((a, b) => a + b);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
