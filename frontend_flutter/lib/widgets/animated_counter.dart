import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final int value;
  final Color color;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.color,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<int> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    animation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(controller);

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {

        return Text(
          animation.value.toString(),
          style: TextStyle(
            color: widget.color,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}