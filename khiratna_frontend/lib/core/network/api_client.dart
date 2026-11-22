import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// One Dio for the whole app. Web calls localhost, mobile calls the hotspot IP.
class ApiClient {
  static const String _mobileBaseUrl = 'http://192.168.137.1:3000';
  static const String _webBaseUrl = 'http://localhost:3000';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: kIsWeb ? _webBaseUrl : _mobileBaseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
}