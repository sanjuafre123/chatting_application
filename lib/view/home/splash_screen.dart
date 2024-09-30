import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInExpo,
    );

    _animationController.forward();

    Timer(
      const Duration(seconds: 4),
          () {
        Navigator.of(context).pushNamed('/Auth');
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff19277f),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: SizedBox(
            height: 290,
            width: 290,
            child: Image.asset(
              'assets/logo.png',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}