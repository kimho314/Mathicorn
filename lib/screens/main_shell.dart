import 'package:flutter/material.dart';
import 'package:Mathicorn/screens/home_screen.dart';
import 'package:Mathicorn/screens/game_setup_screen.dart';
import 'package:Mathicorn/screens/game_screen.dart';
import 'package:Mathicorn/screens/wrong_note_screen.dart';
import 'package:Mathicorn/screens/profile_screen.dart';
import 'package:Mathicorn/screens/statistics_screen.dart';
import 'package:Mathicorn/screens/settings_screen.dart';
import 'package:Mathicorn/screens/auth_screen.dart';
import 'package:Mathicorn/screens/result_screen.dart';
import 'package:Mathicorn/widgets/login_required_dialog.dart';
import 'package:Mathicorn/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../utils/unicorn_theme.dart';
import '../providers/game_provider.dart';
import 'package:Mathicorn/models/math_problem.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  // 외부에서 탭 인덱스 변경을 위한 static 콜백
  static void Function(int)? setTabIndex;

  static void Function(int, int, Duration?, GameLevel?)? showResultScreen;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _resultScreenData;

  static _MainShellState? _instance;

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
    _instance = this;
    MainShell.setTabIndex = (int idx) {
      if (mounted) setState(() => _selectedIndex = idx);
    };
    MainShell.showResultScreen = (int correctAnswers, int totalProblems, Duration? duration, GameLevel? level) {
      if (_instance != null && _instance!.mounted) {
        _instance!.setState(() {
          _instance!._resultScreenData = {
            'correctAnswers': correctAnswers,
            'totalProblems': totalProblems,
            'duration': duration,
            'selectedLevel': level,
          };
        });
      }
    };
  }

  @override
  void dispose() {
    MainShell.setTabIndex = null;
    MainShell.showResultScreen = null;
    _instance = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    // 전체 탭 인덱스와 destinations
    final List<NavigationDestination> allDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.play_arrow_outlined),
        selectedIcon: Icon(Icons.play_arrow),
        label: 'Game Setup',
      ),
      const NavigationDestination(
        icon: Icon(Icons.videogame_asset_outlined),
        selectedIcon: Icon(Icons.videogame_asset),
        label: 'Game',
      ),
      const NavigationDestination(
        icon: Icon(Icons.book_outlined),
        selectedIcon: Icon(Icons.book),
        label: 'Wrong Note',
      ),
      const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: 'Statistics',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
      const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
      const NavigationDestination(
        icon: Icon(Icons.login),
        selectedIcon: Icon(Icons.login),
        label: 'Auth',
      ),
    ];
    // 실제로 보여줄 탭 인덱스만 (Game(2), Settings(6), Auth(7) 숨김)
    final List<int> visibleTabIndices = [0, 1, 3, 4, 5];
    // 현재 _selectedIndex(전체 기준)를 visibleIndex로 변환
    int visibleSelectedIndex = visibleTabIndices.indexOf(_selectedIndex);
    if (visibleSelectedIndex == -1) visibleSelectedIndex = 0;
    // visibleIndex를 전체 인덱스로 변환
    void onDestinationSelected(int visibleIndex) {
      setState(() {
        _selectedIndex = visibleTabIndices[visibleIndex];
      });
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        color: Colors.transparent,
        child: _resultScreenData != null
            ? ResultScreen(
                correctAnswers: _resultScreenData!['correctAnswers'],
                totalProblems: _resultScreenData!['totalProblems'],
                duration: _resultScreenData!['duration'],
                selectedLevel: _resultScreenData!['selectedLevel'],
                onClose: () {
                  setState(() => _resultScreenData = null);
                },
              )
            : _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: visibleSelectedIndex,
        backgroundColor: UnicornColors.white.withOpacity(0.7),
        indicatorColor: UnicornColors.purple.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (idx) async {
          // Only allow navigation to AuthScreen if not logged in
          if ((visibleTabIndices[idx] == 3 || visibleTabIndices[idx] == 4 || visibleTabIndices[idx] == 5) && !auth.isLoggedIn) {
            await showLoginRequiredDialog(context);
            return;
          }
          onDestinationSelected(idx);
        },
        destinations: [for (final i in visibleTabIndices) allDestinations[i]],
      ),
    );
  }
} 