import 'package:flutter/foundation.dart';
import 'package:Mathicorn/models/user_settings.dart';
import 'package:Mathicorn/providers/auth_provider.dart';

class SettingsProvider extends ChangeNotifier {
  UserSettings? _settings;
  bool _loading = false;
  String? _error;

  UserSettings? get settings => _settings;
  bool get loading => _loading;
  String? get error => _error;

  bool get soundEnabled => _settings?.soundEnabled ?? false;
  String get selectedLanguage => _settings?.language ?? 'en';

  Future<void> loadSettings(AuthProvider authProvider) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final s = await authProvider.fetchUserSettings();
      _settings = s;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void loadSettingsFromSupabase(UserSettings userSettings) {
    _settings = userSettings;
    _loading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled, AuthProvider authProvider) async {
    if (_settings == null) return;
    _settings = _settings!.copyWith(soundEnabled: enabled);
    notifyListeners();
    try {
      await authProvider.saveUserSettings(_settings!);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setLanguage(String language, AuthProvider authProvider) async {
    if (_settings == null) return;
    _settings = _settings!.copyWith(language: language);
    notifyListeners();
    try {
      await authProvider.saveUserSettings(_settings!);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 