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
import '../utils/unicorn_theme.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

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
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        color: Colors.transparent,
        child: Container(
          decoration: UnicornDecorations.appBackground,
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
                        Text(
                          'Mathicorn',
                          style: UnicornTextStyles.header.copyWith(fontSize: 36),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!auth.isLoggedIn)
                      UnicornLoginNotice(
                        onLoginTap: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          MainShell.setTabIndex?.call(7);
                        },
                      ),
                    const SizedBox(height: 24),
                    _buildAppBar(auth),
                    const SizedBox(height: 24),
                    _buildMainMenu(auth),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Flexible(
            child: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                final isGuest = !auth.isLoggedIn;
                if (isGuest) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Text(
                          'G',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                
                // 로그인된 사용자는 FutureBuilder로 실제 닉네임 가져오기
                return FutureBuilder<UserProfile?>(
                  future: auth.fetchUserProfile(),
                  builder: (context, snapshot) {
                    final displayName = snapshot.data?.name ?? auth.nickname;
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
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              MainShell.setTabIndex?.call(6);
            },
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
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
          title: 'Note',
          subtitle: 'Review your mistakes',
          color: Colors.red,
          onTap: () async {
            if (!auth.isLoggedIn) {
              await showLoginRequiredDialog(context);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              MainShell.setTabIndex?.call(3);
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
              MainShell.setTabIndex?.call(4);
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
      decoration: UnicornDecorations.cardGlass,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
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
                        style: UnicornTextStyles.button.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: UnicornTextStyles.body.copyWith(
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

class UnicornLoginNotice extends StatefulWidget {
  final VoidCallback onLoginTap;

  const UnicornLoginNotice({required this.onLoginTap, super.key});

  @override
  State<UnicornLoginNotice> createState() => _UnicornLoginNoticeState();
}

class _UnicornLoginNoticeState extends State<UnicornLoginNotice>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.22),
                  Colors.white.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Check your progress!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTapDown: (_) {
                    setState(() => _isPressed = true);
                    _animationController.forward();
                    // 햅틱 피드백 추가
                    HapticFeedback.lightImpact();
                  },
                  onTapUp: (_) {
                    setState(() => _isPressed = false);
                    _animationController.reverse();
                    // 햅틱 피드백 추가
                    HapticFeedback.selectionClick();
                    widget.onLoginTap();
                  },
                  onTapCancel: () {
                    setState(() => _isPressed = false);
                    _animationController.reverse();
                  },
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isPressed 
                                ? Color(0xFF7C4DFF) // 눌렀을 때 더 어두운 색상
                                : Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(_isPressed ? 0.25 : 0.15),
                                blurRadius: _isPressed ? 2 : 6,
                                offset: Offset(0, _isPressed ? 2 : 3),
                                spreadRadius: _isPressed ? 1 : 0,
                              ),
                            ],
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 