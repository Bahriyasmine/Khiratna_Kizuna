import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordDesktopView extends StatelessWidget {
  const ForgotPasswordDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

          Expanded(
            child: Container(
              color: AppColors.primaryGreen,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Image.asset(
                    AppAssets.logo,
                    width: 260,
                  ),

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
                    padding: EdgeInsets.symmetric(
                      horizontal: 60,
                    ),
                    child: Text(
                      'Recover your account and continue building a smarter farm.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
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
                child: SizedBox(
                  width: 450,
                  child: ForgotPasswordForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}