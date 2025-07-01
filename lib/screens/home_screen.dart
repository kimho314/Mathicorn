import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import 'package:Mathicorn/screens/game_setup_screen.dart';
import 'package:Mathicorn/screens/profile_screen.dart';
import 'package:Mathicorn/screens/settings_screen.dart';
import 'package:Mathicorn/screens/gallery_screen.dart';
import 'package:Mathicorn/screens/wrong_note_screen.dart';
import 'package:Mathicorn/models/user_profile.dart';
import 'package:Mathicorn/models/math_problem.dart';
import 'package:Mathicorn/providers/wrong_note_provider.dart';
import 'package:Mathicorn/providers/auth_provider.dart';
import 'package:Mathicorn/widgets/login_required_dialog.dart';
import 'package:Mathicorn/screens/main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.repeat(reverse: true);
    
    // 사용자 프로필 로드 및 WrongNoteProvider 연동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadUserProfile();
      final wrongNoteProvider = context.read<WrongNoteProvider>();
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && auth.user != null) {
        wrongNoteProvider.userId = auth.user!.id;
      } else {
        wrongNoteProvider.userId = null;
      }
      context.read<GameProvider>().wrongNoteProvider = wrongNoteProvider;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/mathicorn.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Mathicorn',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!auth.isLoggedIn)
                        Container(
                          color: Colors.yellow[100],
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline),
                              const SizedBox(width: 8),
                              const Expanded(child: Text('Guest님, 로그인하고 학습 기록을 저장해보세요!')),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/auth'),
                                child: const Text('Login / Sign Up'),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      _buildAppBar(),
                      const SizedBox(height: 24),
                      _buildMainMenu(auth),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              final isGuest = !auth.isLoggedIn;
              final displayName = isGuest ? 'Guest' : auth.nickname;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(
                      displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
                icon: const Icon(Icons.settings, color: Colors.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu(AuthProvider auth) {
    return Column(
      children: [
        _buildMenuButton(
          icon: Icons.play_arrow,
          title: 'Start Game',
          subtitle: 'Solve math problems!',
          color: Colors.green,
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            MainShell.setTabIndex?.call(1);
          },
        ),
        const SizedBox(height: 16),
        _buildMenuButton(
          icon: Icons.book,
          title: 'Wrong Note',
          subtitle: 'Review your mistakes',
          color: Colors.red,
          onTap: () async {
            if (!auth.isLoggedIn) {
              await showLoginRequiredDialog(context);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              MainShell.setTabIndex?.call(2);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildMenuButton(
          icon: Icons.emoji_events,
          title: 'Statistics',
          subtitle: 'Total points earned!',
          color: Colors.orange,
          onTap: () async {
            if (!auth.isLoggedIn) {
              await showLoginRequiredDialog(context);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              MainShell.setTabIndex?.call(3);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        // Glassmorphism effect: blur
        // (Flutter does not support backdropFilter in BoxDecoration directly, so use ClipRRect+BackdropFilter in widget tree if needed)
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFF8FAFC),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 