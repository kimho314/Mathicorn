import 'package:flutter/material.dart';
import 'package:Mathicorn/screens/home_screen.dart';
import 'package:Mathicorn/screens/game_setup_screen.dart';
import 'package:Mathicorn/screens/wrong_note_screen.dart';
import 'package:Mathicorn/screens/profile_screen.dart';
import 'package:Mathicorn/widgets/login_required_dialog.dart';
import 'package:Mathicorn/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  static const List<Widget> _screens = [
    HomeScreen(),
    GameSetupScreen(),
    WrongNoteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) async {
          if ((idx == 2 || idx == 3) && !auth.isLoggedIn) {
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
            label: 'Game',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Wrong Note',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: Color(0xFFF3E5F5),
        indicatorColor: Color(0xFFB388FF).withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
} 