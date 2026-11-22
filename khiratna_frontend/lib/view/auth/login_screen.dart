import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/auth/web/login_desktop_view.dart';
import 'package:khiratna_frontend/view/auth/mobile/login_mobile_view.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 900) {
      return const LoginDesktopView();
    }

    return const LoginMobileView();
  }
}