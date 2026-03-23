import 'dart:ui';
import 'package:flutter/material.dart';
import 'animated_counter.dart';

class GlassStatCard extends StatelessWidget {

  final String title;
  final int value;
  final Color color;

  const GlassStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              AnimatedCounter(
                value: value,
                color: color,
              ),

              const SizedBox(height: 6),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}