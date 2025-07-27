import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/settings_provider.dart';
import '../utils/unicorn_theme.dart';
import 'main_shell.dart';
import 'package:Mathicorn/providers/auth_provider.dart';
import 'dart:ui';

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
          return SafeArea(
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(255, 255, 255, 0.25),
            Color.fromRGBO(255, 255, 255, 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0), // 하단 패딩을 8로 줄임
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              ...children,
              const SizedBox(height: 16), // 카드 하단에 여백 추가
            ],
          ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4), // 상하 마진을 4로 줄임
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFF8B5CF6).withOpacity(0.3),
            inactiveThumbColor: Colors.white.withOpacity(0.7),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(SettingsProvider settingsProvider, AuthProvider auth) {
    return GestureDetector(
      onTap: () => _showLanguageDialog(context, settingsProvider, auth),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4), // 상하 마진을 4로 줄임
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLanguageText(settingsProvider.selectedLanguage),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settingsProvider, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Select Language',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: RadioListTile<String>(
                  title: const Text(
                    'English',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: 'en',
                  groupValue: settingsProvider.selectedLanguage,
                  activeColor: const Color(0xFF8B5CF6),
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setLanguage(value, auth);
                    }
                    Navigator.of(context).pop();
                  },
                ),
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