import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/verify_code_form.dart';

class VerifyCodeDesktopView extends StatelessWidget {
  final String email;

  const VerifyCodeDesktopView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: AppColors.primaryGreen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.logo, width: 260),
                  const SizedBox(height: 30),
                  const Text(
                    'Khiratna',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                    child: Text(
                      'Check your email and enter the verification code to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 450,
                    child: VerifyCodeForm(email: email),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}