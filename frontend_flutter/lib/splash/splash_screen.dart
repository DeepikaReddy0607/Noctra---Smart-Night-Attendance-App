import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../widgets/star_field.dart';
import '../widgets/shimmer_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    /// fade animations
    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _textController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    /// pulse animation
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          /// background
          Image.asset(
            "assets/images/noctra_background.png",
            fit: BoxFit.cover,
          ),

          /// moving stars
          const StarField(),

          /// overlay
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          /// logo + title
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// pulsing shield logo
                ScaleTransition(
                  scale: _pulse,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: Image.asset(
                      "assets/images/noctra_logo.png",
                      height: 120,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}