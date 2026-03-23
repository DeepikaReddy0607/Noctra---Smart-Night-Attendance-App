import 'dart:math';
import 'package:flutter/material.dart';

class StarField extends StatefulWidget {
  const StarField({super.key});

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  final List<Star> stars = [];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < 80; i++) {
      stars.add(Star.random());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: StarPainter(stars, controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class Star {
  double x;
  double y;
  double size;

  Star(this.x, this.y, this.size);

  factory Star.random() {
    final rand = Random();
    return Star(
      rand.nextDouble(),
      rand.nextDouble(),
      rand.nextDouble() * 2,
    );
  }
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;

  StarPainter(this.stars, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      final dx = star.x * size.width;
      final dy = (star.y + animation * 0.02) % 1 * size.height;

      canvas.drawCircle(
        Offset(dx, dy),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}