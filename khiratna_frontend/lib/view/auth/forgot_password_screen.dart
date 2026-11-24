import 'package:flutter/material.dart';

import 'mobile/forgot_password_mobile_view.dart';
import 'web/forgot_password_desktop_view.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    if (width > 900) {
      return const ForgotPasswordDesktopView();
    }

    return const ForgotPasswordMobileView();
  }
}