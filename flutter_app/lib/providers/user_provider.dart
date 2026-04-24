import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  String uid = '';
  String email = '';
  String plan = 'free';
  int dailyUsage = 0;
  bool loading = false;

  bool get isPro => plan == 'pro';
  int get remaining => isPro ? 999 : (5 - dailyUsage).clamp(0, 5);

  Future<void> loadProfile() async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService().getMe();
      uid = data['uid'] ?? '';
      email = data['email'] ?? '';
      plan = data['plan'] ?? 'free';
      dailyUsage = data['daily_usage'] ?? 0;
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  void setPro() {
    plan = 'pro';
    notifyListeners();
  }
}
