import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../viewmodel/auth/auth_viewmodel.dart';
import '../reset_password_screen.dart';

class VerifyCodeForm extends StatefulWidget {
  final String email;

  const VerifyCodeForm({super.key, required this.email});

  @override
  State<VerifyCodeForm> createState() => _VerifyCodeFormState();
}

class _VerifyCodeFormState extends State<VerifyCodeForm> {
  final AuthViewModel vm = AuthViewModel();

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    vm.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _showMessage(String message, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  void _onChanged(String value, int index) {
    // Handle paste of the full code into any box
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final next = digits.length >= 6 ? 5 : digits.length;
      _focusNodes[next].requestFocus();
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _onVerify() async {
    final code = _code;

    if (code.length != 6) {
      _showMessage('Please enter the 6-digit code.');
      return;
    }

    final success = await vm.verifyCode(
      email: widget.email,
      token: code,
    );
    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
            token: code,
          ),
        ),
      );
    } else {
      _showMessage(vm.errorMessage ?? 'Invalid or expired code.');
    }
  }

  Future<void> _onResend() async {
    vm.emailController.text = widget.email;
    final success = await vm.forgotPassword();
    if (!mounted) return;

    if (success) {
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      _showMessage('A new code has been sent.', error: false);
    } else {
      _showMessage(vm.errorMessage ?? 'Could not resend code.');
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
              'Verify Code',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to ${widget.email}.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // allow paste into the first box; others cut to 6
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF49583B),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onChanged(value, index),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            CustomButton(
              text: vm.isLoading ? 'Verifying...' : 'Verify',
              onPressed: vm.isLoading ? () {} : _onVerify,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: vm.isLoading ? null : _onResend,
                child: const Text('Resend code'),
              ),
            ),
          ],
        );
      },
    );
  }
}