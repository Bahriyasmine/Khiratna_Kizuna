import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/auth/forgot_password_screen.dart';
import 'package:khiratna_frontend/view/main/main_screen.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../viewmodel/auth/auth_viewmodel.dart';
import '../signup_screen.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final AuthViewModel vm = AuthViewModel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back 👋',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        const Text(
          'Sign in to continue using Khiratna',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),

        const SizedBox(height: 30),

        CustomTextField(
          hintText: 'Enter your email',
          icon: Icons.email_outlined,
          controller: vm.emailController,
        ),

        const SizedBox(height: 20),

        CustomTextField(
          hintText: 'Enter your password',
          icon: Icons.lock_outline,
          obscureText: true,
          controller: vm.passwordController,
        ),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            child: const Text('Forgot Password?'),
          ),
        ),

        const SizedBox(height: 10),

        CustomButton(
          text: 'Sign In',
          onPressed: () async {
            final success = await vm.login();

            if (!context.mounted) return;

            if (success && context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(vm.errorMessage ?? 'Login failed')),
              );
            }
          },
        ),

        const SizedBox(height: 25),

        const Center(child: Text('or', style: TextStyle(color: Colors.grey))),

        const SizedBox(height: 20),

        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Continue with Google'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
          ),
        ),

        const SizedBox(height: 25),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ],
    );
  }
}
