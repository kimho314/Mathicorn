import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _voiceEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'en';

  bool get soundEnabled => _soundEnabled;
  bool get voiceEnabled => _voiceEnabled;
  bool get darkMode => _darkMode;
  String get selectedLanguage => _selectedLanguage;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _voiceEnabled = prefs.getBool('voiceEnabled') ?? true;
    _darkMode = prefs.getBool('darkMode') ?? false;
    _selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    _voiceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voiceEnabled', enabled);
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', enabled);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _soundEnabled = true;
    _voiceEnabled = true;
    _darkMode = false;
    _selectedLanguage = 'en';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', true);
    await prefs.setBool('voiceEnabled', true);
    await prefs.setBool('darkMode', false);
    await prefs.setString('selectedLanguage', 'en');
    
    notifyListeners();
  }
} 