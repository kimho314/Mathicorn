import 'package:flutter/material.dart';
import 'dart:ui';
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
import 'package:Mathicorn/models/user_profile.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  // 외부에서 탭 인덱스 변경을 위한 static 콜백
  static void Function(int)? setTabIndex;

  static void Function(int, int, Duration?, GameLevel?)? showResultScreen;
  
  // 이메일 확인 다이얼로그 표시를 위한 static 콜백
  static void Function()? showEmailConfirmation;
  // Auth 화면 열기 (네비게이션 바 유지)
  static void Function(bool showSignUp, VoidCallback? onAuthenticated)? openAuth;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _resultScreenData;
  bool _authShowSignUp = false;
  VoidCallback? _postAuthCallback;

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
    MainShell.showResultScreen = (int correctAnswers, int totalProblems, Duration? duration, GameLevel? level) async {
      if (_instance != null && _instance!.mounted) {
        // ResultScreen을 즉시 표시 (데이터 저장은 ResultScreen에서 처리)
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
    
    // 이메일 확인 다이얼로그 표시를 위한 메서드 추가
    MainShell.showEmailConfirmation = () {
      if (_instance != null && _instance!.mounted) {
        // 홈 화면으로 이동
        _instance!.setState(() => _instance!._selectedIndex = 0);
        // 이메일 확인 다이얼로그 표시
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _instance!._showEmailConfirmationDialog();
        });
      }
    };

    // Auth 화면으로 이동하기 위한 메서드 (네비게이션 바 유지)
    MainShell.openAuth = (bool showSignUp, VoidCallback? onAuthenticated) {
      if (_instance != null && _instance!.mounted) {
        _instance!.setState(() {
          // 결과 화면을 닫아야 AuthScreen이 보임
          _instance!._resultScreenData = null;
          _instance!._authShowSignUp = showSignUp;
          _instance!._selectedIndex = 7;
          _instance!._postAuthCallback = onAuthenticated;
        });
      }
    };
  }

  @override
  void dispose() {
    MainShell.setTabIndex = null;
    MainShell.showResultScreen = null;
    MainShell.showEmailConfirmation = null;
    MainShell.openAuth = null;
    _instance = null;
    super.dispose();
  }

  void _showEmailConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 이메일 아이콘
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: UnicornColors.purple,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // 제목
                      Text(
                        'Email Confirmation Required',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // 내용
                      Text(
                        'A confirmation email has been sent to your address.\n\nPlease check your email and click the confirmation link to complete your registration.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.26),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // OK 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.25),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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
        label: 'Note',
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
            : (_selectedIndex == 7
                ? AuthScreen(
                    showSignUp: _authShowSignUp,
                    // 인증 완료 후 콜백: 결과 화면 복귀 및 리워드 재평가
                    onAuthenticated: () {
                      if (mounted) {
                        setState(() {
                          _selectedIndex = 0; // 홈으로 일단 이동
                        });
                        // 콜백이 있으면 실행 (결과 화면 복귀 등)
                        _postAuthCallback?.call();
                        _postAuthCallback = null;
                      }
                    },
                  )
                : _screens[_selectedIndex]),
      ),
      bottomNavigationBar: NavigationBar(
        height: 80,
        selectedIndex: visibleSelectedIndex,
        backgroundColor: UnicornColors.white.withOpacity(0.7),
        indicatorColor: UnicornColors.purple.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
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

  String? _getStickerNameForLevel(GameLevel level) {
    switch (level) {
      case GameLevel.level1:
        return 'lv1_sticker';
      case GameLevel.level2:
        return 'lv2_sticker';
      case GameLevel.level3:
        return 'lv3_sticker';
      case GameLevel.level4:
        return 'lv4_sticker';
      case GameLevel.level5:
        return 'lv5_sticker';
      case GameLevel.level6:
        return 'lv6_sticker';
      case GameLevel.level7:
        return 'lv7_sticker';
      case GameLevel.level8:
        return 'lv8_sticker';
      case GameLevel.level9:
        return 'lv9_sticker';
      case GameLevel.level10:
        return 'lv10_sticker';
      case GameLevel.level11:
        return 'lv11_sticker';
      case GameLevel.level12:
        return 'lv12_sticker';
      default:
        return null;
    }
  }
} 