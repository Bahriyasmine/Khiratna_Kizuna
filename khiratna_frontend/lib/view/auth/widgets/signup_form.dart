import 'package:flutter/material.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../viewmodel/auth/auth_viewmodel.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
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
    final name = vm.fullNameController.text.trim();
    final email = vm.emailController.text.trim();
    final password = vm.passwordController.text;
    final confirm = vm.confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      return 'Please fill in all fields.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (password != confirm) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _onRegister() async {
    final error = _validate();
    if (error != null) {
      _showMessage(error);
      return;
    }

    final success = await vm.register();
    if (!mounted) return;

    if (success) {
      _showMessage('Account created! Please sign in.', error: false);
      Navigator.pop(context);
    } else {
      _showMessage(vm.errorMessage ?? 'Registration failed.');
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
              'Create Account',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join Khiratna and start farming smarter.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              hintText: 'Full Name',
              icon: Icons.person_outline,
              controller: vm.fullNameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Email Address',
              icon: Icons.email_outlined,
              controller: vm.emailController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Password',
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
              text: vm.isLoading ? 'Creating...' : 'Create Account',
              onPressed: vm.isLoading ? () {} : _onRegister,
            ),
            const SizedBox(height: 25),
            const Center(
              child: Text('or', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Continue with Google'),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}