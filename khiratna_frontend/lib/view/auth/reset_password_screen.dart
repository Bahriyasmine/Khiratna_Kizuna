import 'package:flutter/material.dart';

import 'mobile/reset_password_mobile_view.dart';
import 'web/reset_password_desktop_view.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 900) {
      return ResetPasswordDesktopView(email: email, token: token);
    }

    return ResetPasswordMobileView(email: email, token: token);
  }
}