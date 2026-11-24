import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/reset_password_form.dart';

class ResetPasswordMobileView extends StatelessWidget {
  final String email;
  final String token;

  const ResetPasswordMobileView({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset(AppAssets.logo, width: 120),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: ResetPasswordForm(email: email, token: token),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}