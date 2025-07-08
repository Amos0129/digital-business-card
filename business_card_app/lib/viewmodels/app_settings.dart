import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  String _languageCode;

  AppSettings({required String languageCode}) : _languageCode = languageCode;

  String get languageCode => _languageCode;

  Locale get locale => Locale(_languageCode, _languageCode == 'zh' ? 'TW' : 'US');

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
  }
}