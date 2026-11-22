import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/auth_response.dart';
import '../../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final fullNameController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      debugPrint('LOGIN RESPONSE: ${response.data}');

      if (response.data == null) {
        throw Exception('Server returned empty response');
      }

      final authResponse = AuthResponse.fromJson(response.data);

      debugPrint('TOKEN: ${authResponse.accessToken}');

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', authResponse.accessToken);

      await prefs.setString('userId', authResponse.user.id);

      await prefs.setString('userEmail', authResponse.user.email);

      await prefs.setString('userName', authResponse.user.name);

      return true;
    } catch (e) {
      errorMessage = _parseError(e);

      debugPrint('LOGIN ERROR: $e');

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.register(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        errorMessage = msg is List ? msg.join('\n') : msg.toString();
      } else {
        errorMessage = 'Could not reach the server. Check your connection.';
      }
      debugPrint('Register Error: $e');
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      debugPrint('Register Error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> forgotPassword() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.forgotPassword(emailController.text.trim());

      return true;
    } catch (e) {
      errorMessage = _parseError(e);
      debugPrint('Forgot Password Error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyCode({
    required String email,
    required String token,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.verifyCode(email: email, token: token);

      return true;
    } catch (e) {
      errorMessage = _parseError(e);
      debugPrint('Verify Code Error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(
        email: email,
        token: token,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      return true;
    } catch (e) {
      errorMessage = _parseError(e);
      debugPrint('Reset Password Error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();

    passwordController.dispose();

    fullNameController.dispose();

    confirmPasswordController.dispose();

    super.dispose();
  }
}

String _parseError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      return msg is List ? msg.join('\n') : msg.toString();
    }
    return 'Could not reach the server. Check your connection.';
  }
  return 'Something went wrong. Please try again.';
}
