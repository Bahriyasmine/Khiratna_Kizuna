import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.137.1:3000',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<Response> forgotPassword(
    String email,
  ) async {
    return await _dio.post(
      '/auth/forgot-password',
      data: {
        'email': email,
      },
    );
  }

  Future<Response> verifyCode({
    required String email,
    required String token,
  }) async {
    return await _dio.post(
      '/auth/verify-reset-code',
      data: {
        'email': email,
        'token': token,
      },
    );
  }

  Future<Response> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    return await _dio.post(
      '/auth/reset-password',
      data: {
        'email': email,
        'token': token,
        'newPassword': password,
        'confirmPassword': confirmPassword,
      },
    );
  }
}