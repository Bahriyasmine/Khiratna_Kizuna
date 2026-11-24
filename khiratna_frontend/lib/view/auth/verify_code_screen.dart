import 'package:flutter/material.dart';

import 'mobile/verify_code_mobile_view.dart';
import 'web/verify_code_desktop_view.dart';

class VerifyCodeScreen extends StatelessWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 900) {
      return VerifyCodeDesktopView(email: email);
    }

    return VerifyCodeMobileView(email: email);
  }
}