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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<SettingsProvider>().loadSettings(auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Container(
      decoration: UnicornDecorations.appBackground,
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (settingsProvider.error != null) {
            return Center(
              child: Text(
                'Error: \\${settingsProvider.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView(
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
      subtitle: const Text('English'),
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
            ],
          ),
        );
      },
    );
  }

  String _getLanguageText(String code) {
    return 'English';
  }
} 