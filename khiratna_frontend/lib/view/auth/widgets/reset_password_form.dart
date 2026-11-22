import 'package:flutter/material.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../viewmodel/auth/auth_viewmodel.dart';

class ResetPasswordForm extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordForm({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
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

  String? _validate() {
    final password = vm.passwordController.text;
    final confirm = vm.confirmPasswordController.text;

    if (password.isEmpty || confirm.isEmpty) {
      return 'Please fill in both fields.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (password != confirm) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _onReset() async {
    final error = _validate();
    if (error != null) {
      _showMessage(error);
      return;
    }

    final success = await vm.resetPassword(
      email: widget.email,
      token: widget.token,
    );
    if (!mounted) return;

    if (success) {
      _showMessage('Password reset successfully. Please sign in.',
          error: false);
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      _showMessage(vm.errorMessage ?? 'Failed to reset password.');
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
              'New Password',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a strong password for your account.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              hintText: 'New Password',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: vm.passwordController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: vm.confirmPasswordController,
            ),
            const SizedBox(height: 25),
            CustomButton(
              text: vm.isLoading ? 'Resetting...' : 'Reset Password',
              onPressed: vm.isLoading ? () {} : _onReset,
            ),
          ],
        );
      },
    );
  }
}