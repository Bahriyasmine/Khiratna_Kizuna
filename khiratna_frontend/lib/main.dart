import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/splashScreen/splash_screen.dart';

void main() {
  runApp(const KhiratnaApp());
}

class KhiratnaApp extends StatelessWidget {
  const KhiratnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}