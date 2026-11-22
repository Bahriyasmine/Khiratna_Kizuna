import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/auth/widgets/login_form.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class LoginDesktopView extends StatelessWidget {
  const LoginDesktopView({super.key});

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
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                    child: Text(
                      'Empowering Tunisian farmers with smarter decisions for crops, water and solar energy.',
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
                  child: SizedBox(width: 450, child: LoginForm()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
