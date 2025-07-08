import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import 'package:Mathicorn/screens/home_screen.dart';
import 'package:Mathicorn/screens/game_setup_screen.dart';
import '../utils/unicorn_theme.dart';
import 'package:Mathicorn/models/math_problem.dart';
import 'package:Mathicorn/screens/main_shell.dart';
import 'package:Mathicorn/screens/game_screen.dart';
import 'package:Mathicorn/providers/auth_provider.dart';
import 'package:Mathicorn/models/user_profile.dart';

class ResultScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalProblems;
  final Duration? duration;
  final GameLevel? selectedLevel;
  final VoidCallback? onClose;
  const ResultScreen({
    required this.correctAnswers,
    required this.totalProblems,
    this.duration,
    this.selectedLevel,
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _catAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _catBounceAnimation;
  late Animation<double> _catRotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _catAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    // 고양이 애니메이션
    _catBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _catAnimationController, curve: Curves.bounceInOut),
    );
    _catRotateAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _catAnimationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    _catAnimationController.repeat(reverse: true);

    // 게임 결과를 UserProfile에 반영하고 Supabase에 저장 (로딩/에러 피드백 추가)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffold = ScaffoldMessenger.of(context);
      try {
        scaffold.showSnackBar(const SnackBar(content: Text('프로필 저장 중...'), duration: Duration(seconds: 1)));
        final auth = context.read<AuthProvider>();
        final profile = await auth.fetchUserProfile() ?? UserProfile(name: auth.nickname);
        final updated = profile.copyWith(
          totalScore: profile.totalScore + widget.correctAnswers,
          totalProblems: profile.totalProblems + widget.totalProblems,
        );
        await auth.saveUserProfile(updated);
        scaffold.showSnackBar(const SnackBar(content: Text('프로필이 저장되었습니다!'), duration: Duration(seconds: 1)));
      } catch (e) {
        scaffold.showSnackBar(const SnackBar(content: Text('프로필 저장에 실패했습니다.'), duration: Duration(seconds: 2)));
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _catAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        leading: widget.onClose != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              )
            : null,
      ),
      body: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
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
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Builder(
                builder: (context) {
                  final correctAnswers = widget.correctAnswers;
                  final totalProblems = widget.totalProblems;
                  final score = (correctAnswers / totalProblems * 100).round();
                  final duration = widget.duration;
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Game Result',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (score >= 90) _buildDancingCat(),
                              if (score < 90) _buildResultEmoji(score),
                              if (score >= 90) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Perfect!',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              _buildScoreDisplay(score, correctAnswers, totalProblems),
                              const SizedBox(height: 32),
                              if (duration != null) ...[
                                _buildTimeDisplay(duration),
                                const SizedBox(height: 32),
                              ],
                              _buildRewardDisplay(score),
                              const SizedBox(height: 40),
                              _buildActionButtons(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultEmoji(int score) {
    String emoji;
    String message;
    
    if (score >= 90) {
      emoji = '🐱';
      message = 'Perfect!';
    } else if (score >= 70) {
      emoji = '👏';
      message = 'Great job!';
    } else if (score >= 50) {
      emoji = '👍';
      message = 'Good!';
    } else {
      emoji = '💪';
      message = 'Try again!';
    }

    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay(int score, int correctAnswers, int totalProblems) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$score points',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5CF6),
              shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$correctAnswers / $totalProblems problems correct',
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(255,255,255,0.7),
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: correctAnswers / totalProblems,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 8),
          Text(
            'Time taken: ${minutes}m ${seconds}s',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardDisplay(int score) {
    List<String> rewards = [];
    
    if (score >= 90) {
      rewards = ['🏆', '⭐', '🎖️'];
    } else if (score >= 70) {
      rewards = ['⭐', '🎖️'];
    } else if (score >= 50) {
      rewards = ['🎖️'];
    }

    if (rewards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Rewards Earned!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5CF6),
              shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (score >= 90) ...[
                const Text('🏆', style: TextStyle(fontSize: 32, color: Color(0xFFFDE047))),
                SizedBox(width: 8),
              ],
              if (score >= 70) ...[
                const Text('⭐', style: TextStyle(fontSize: 32, color: Color(0xFFFDE047))),
                SizedBox(width: 8),
              ],
              if (score >= 90) ...[
                const Text('🏅', style: TextStyle(fontSize: 32, color: Color(0xFF8B5CF6))),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentLevel = widget.selectedLevel;
    print('ResultScreen: currentLevel = ' + (currentLevel?.toString() ?? 'null'));
    print('ResultScreen: GameLevel.values = ' + GameLevel.values.toString());
    final nextLevel = currentLevel != null && currentLevel.index < GameLevel.values.length - 1
        ? GameLevel.values[currentLevel.index + 1]
        : null;
    print('ResultScreen: nextLevel = ' + (nextLevel?.toString() ?? 'null'));
    return Column(
      children: [
        if (nextLevel != null)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                print('ResultScreen: nextLevel = ' + (nextLevel?.toString() ?? 'null'));
                gameProvider.setGameSettings(
                  totalProblems: gameProvider.totalProblems,
                  operations: LevelManager.getLevelConfig(nextLevel).operations,
                  level: nextLevel,
                );
                gameProvider.startGame();
                Navigator.of(context).popUntil((route) => route.isFirst);
                if (MainShell.setTabIndex != null) {
                  MainShell.setTabIndex!(2);
                }
                if (widget.onClose != null) {
                  widget.onClose!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                'Next Level! (Lv${nextLevel.index + 1})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (nextLevel != null) const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              if (MainShell.setTabIndex != null) {
                MainShell.setTabIndex!(0);
              }
              if (widget.onClose != null) {
                widget.onClose!();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDancingCat() {
    return AnimatedBuilder(
      animation: _catAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * _catBounceAnimation.value),
          child: Transform.rotate(
            angle: _catRotateAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // 축하 메시지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.yellow[400]!, width: 2),
                    ),
                    child: Text(
                      'Perfect!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 고양이
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 고양이 귀 (왼쪽)
                      Transform.rotate(
                        angle: _catRotateAnimation.value * 0.5,
                        child: Container(
                          width: 0,
                          height: 0,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.orange, width: 12),
                              right: BorderSide(color: Colors.transparent, width: 12),
                              bottom: BorderSide(color: Colors.transparent, width: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 고양이 얼굴
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.orange[200],
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.orange[400]!, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange[300]!.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // 고양이 눈
                            Positioned(
                              top: 20,
                              left: 15,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 15,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            // 고양이 코
                            Positioned(
                              top: 35,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.pink[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            // 고양이 입
                            Positioned(
                              bottom: 15,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            // 고양이 볼
                            Positioned(
                              top: 30,
                              left: 8,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.pink[200],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 30,
                              right: 8,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.pink[200],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 고양이 귀 (오른쪽)
                      Transform.rotate(
                        angle: -_catRotateAnimation.value * 0.5,
                        child: Container(
                          width: 0,
                          height: 0,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.orange, width: 12),
                              right: BorderSide(color: Colors.transparent, width: 12),
                              bottom: BorderSide(color: Colors.transparent, width: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 고양이 꼬리
                  Transform.rotate(
                    angle: _catRotateAnimation.value * 2,
                    child: Container(
                      width: 40,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.orange[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 