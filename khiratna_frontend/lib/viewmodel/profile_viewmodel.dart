import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewModel extends ChangeNotifier {
  String name = '';
  String email = '';
  bool isLoading = true;

  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('userName') ?? '';
    email = prefs.getString('userEmail') ?? '';
    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
  }
}