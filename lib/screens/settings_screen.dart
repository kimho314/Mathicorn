import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/settings_provider.dart';
import '../utils/unicorn_theme.dart';
import 'main_shell.dart';
import 'package:Mathicorn/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      
      // Supabase에서 user_settings 정보 조회
      try {
        final userSettings = await auth.fetchUserSettings();
        settingsProvider.loadSettingsFromSupabase(userSettings);
      } catch (e) {
        print('Failed to load user settings: $e');
        // 기본 설정으로 로드
        settingsProvider.loadSettings(auth);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Container(
      decoration: UnicornDecorations.appBackground,
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // Sound Settings
                  _buildSettingCard(
                    title: '🔊 Sound Settings',
                    children: [
                      _buildSwitchTile(
                        title: 'Sound Effects',
                        subtitle: 'Play sound effects for correct/wrong answers',
                        value: settingsProvider.soundEnabled,
                        onChanged: (value) {
                          settingsProvider.setSoundEnabled(value, auth);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Language Settings
                  _buildSettingCard(
                    title: '🌍 Language Settings',
                    children: [
                      _buildLanguageSelector(settingsProvider, auth),
                    ],
                  ),
                  if (settingsProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Center(
                        child: Text(
                          'Error: \\${settingsProvider.error}',
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              if (settingsProvider.loading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 3),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required List<Widget> children,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildLanguageSelector(SettingsProvider settingsProvider, AuthProvider auth) {
    return ListTile(
      title: const Text('Language'),
      subtitle: Text(_getLanguageText(settingsProvider.selectedLanguage)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _showLanguageDialog(context, settingsProvider, auth),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settingsProvider, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: settingsProvider.selectedLanguage,
                onChanged: (value) {
                  if (value != null) {
                    settingsProvider.setLanguage(value, auth);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text('한국어'),
                value: 'ko',
                groupValue: settingsProvider.selectedLanguage,
                onChanged: (value) {
                  if (value != null) {
                    settingsProvider.setLanguage(value, auth);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageText(String code) {
    switch (code) {
      case 'ko':
        return '한국어';
      case 'en':
      default:
        return 'English';
    }
  }
} 