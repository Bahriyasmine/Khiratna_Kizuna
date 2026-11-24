import 'package:flutter/material.dart';

import 'mobile/signup_mobile_view.dart';
import 'web/signup_desktop_view.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 900) {
      return const SignupDesktopView();
    }

    return const SignupMobileView();
  }
}