import 'package:flutter/material.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../viewmodel/auth/auth_viewmodel.dart';
import '../verify_code_screen.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final AuthViewModel vm = AuthViewModel();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _onSendCode() async {
    final email = vm.emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    final success = await vm.forgotPassword();
    if (!mounted) return;

    if (success) {
      _showMessage('Verification code sent to your email.', error: false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(email: email),
        ),
      );
    } else {
      _showMessage(vm.errorMessage ?? 'Failed to send code.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot Password',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your email and we will send you a verification code.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              hintText: 'Email Address',
              icon: Icons.email_outlined,
              controller: vm.emailController,
            ),
            const SizedBox(height: 25),
            CustomButton(
              text: vm.isLoading ? 'Sending...' : 'Send Code',
              onPressed: vm.isLoading ? () {} : _onSendCode,
            ),
          ],
        );
      },
    );
  }
}