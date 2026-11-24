import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _scale = 0.8;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _scale = 1;
        _opacity = 1;
      });
    });

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1200),
          opacity: _opacity,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutExpo,
            scale: _scale,
            child: Image.asset(
              AppAssets.logo,
              width: 230,
            ),
          ),
        ),
      ),
    );
  }
}