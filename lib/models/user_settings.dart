import 'package:flutter/foundation.dart';

class UserSettings {
  final bool soundEnabled;
  final String language;

  UserSettings({
    required this.soundEnabled,
    required this.language,
  });

  UserSettings copyWith({
    bool? soundEnabled,
    String? language,
  }) {
    return UserSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sound_enabled': soundEnabled,
      'language': language,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      soundEnabled: json['sound_enabled'] ?? true,
      language: json['language'] ?? 'en',
    );
  }
} 