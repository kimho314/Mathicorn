import 'package:flutter/material.dart';
import 'package:Mathicorn/screens/home_screen.dart';
import 'package:Mathicorn/screens/game_setup_screen.dart';
import 'package:Mathicorn/screens/game_screen.dart';
import 'package:Mathicorn/screens/wrong_note_screen.dart';
import 'package:Mathicorn/screens/profile_screen.dart';
import 'package:Mathicorn/screens/statistics_screen.dart';
import 'package:Mathicorn/screens/settings_screen.dart';
import 'package:Mathicorn/screens/auth_screen.dart';
import 'package:Mathicorn/widgets/login_required_dialog.dart';
import 'package:Mathicorn/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../utils/unicorn_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  // 외부에서 탭 인덱스 변경을 위한 static 콜백
  static void Function(int)? setTabIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  static final List<Widget> _screens = [
    HomeScreen(),         // 0
    GameSetupScreen(),    // 1
    GameScreen(),         // 2
    WrongNoteScreen(),    // 3
    StatisticsScreen(),   // 4
    ProfileScreen(),      // 5
    SettingsScreen(),     // 6
    AuthScreen(),         // 7
  ];

  @override
  void initState() {
    super.initState();
    MainShell.setTabIndex = (int idx) {
      if (mounted) setState(() => _selectedIndex = idx);
    };
  }

  @override
  void dispose() {
    MainShell.setTabIndex = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        color: Colors.transparent,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _selectedIndex,
        backgroundColor: UnicornColors.white.withOpacity(0.7),
        indicatorColor: UnicornColors.purple.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (idx) async {
          // Only allow navigation to AuthScreen if not logged in
          if ((idx == 3 || idx == 4 || idx == 5) && !auth.isLoggedIn) {
            await showLoginRequiredDialog(context);
            return;
          }
          setState(() => _selectedIndex = idx);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_arrow_outlined),
            selectedIcon: Icon(Icons.play_arrow),
            label: 'Game Setup',
          ),
          NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset),
            label: 'Game',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Wrong Note',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.login),
            selectedIcon: Icon(Icons.login),
            label: 'Auth',
          ),
        ],
      ),
    );
  }
} 