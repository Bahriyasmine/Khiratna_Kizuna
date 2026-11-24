import 'package:flutter/material.dart';

class AuthResponse {
  final String accessToken;

  final UserData user;

  AuthResponse({required this.accessToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('AUTH RESPONSE JSON: $json');

    return AuthResponse(
      accessToken: json['accessToken'],
      user: UserData.fromJson(json['user']),
    );
  }
}

class UserData {
  final String id;

  final String name;

  final String email;

  UserData({required this.id, required this.name, required this.email});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(id: json['id'], name: json['name'], email: json['email']);
  }
}
