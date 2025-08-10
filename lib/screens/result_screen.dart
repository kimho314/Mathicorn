import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import 'package:Mathicorn/screens/home_screen.dart';
import 'package:Mathicorn/screens/game_setup_screen.dart';
import '../utils/unicorn_theme.dart';
import 'package:Mathicorn/models/math_problem.dart';
import 'package:Mathicorn/screens/main_shell.dart';
import 'package:Mathicorn/screens/game_screen.dart';
import 'package:Mathicorn/screens/auth_screen.dart';
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
  late AnimationController _stickerAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _catBounceAnimation;
  late Animation<double> _catRotateAnimation;
  late Animation<double> _stickerScaleAnimation;
  late Animation<double> _stickerRotateAnimation;
  
  // 로딩 상태 관리
  bool _isLoading = true;
  late AnimationController _skeletonAnimationController;
  late Animation<double> _skeletonShimmerAnimation;

  // 해당 레벨 스티커 이미 보유 여부
  bool _alreadyHadStickerForLevel = false;
  // 레벨 관련 로그 1회만 출력하기 위한 플래그
  bool _levelLoggedOnce = false;

  @override
  void initState() {
    super.initState();
    
    // 스켈레톤 애니메이션 컨트롤러
    _skeletonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _skeletonShimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _skeletonAnimationController, curve: Curves.easeInOut),
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // 1000ms → 600ms
      vsync: this,
    );
    _catAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200), // 2000ms → 1200ms
      vsync: this,
    );
    _stickerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800), // 1500ms → 800ms
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate( // 0.5 → 0.8로 시작값 조정
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut), // elasticOut → easeOut
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    // 고양이 애니메이션
    _catBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _catAnimationController, curve: Curves.easeInOut), // bounceInOut → easeInOut
    );
    _catRotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate( // -0.1, 0.1 → -0.05, 0.05
      CurvedAnimation(parent: _catAnimationController, curve: Curves.easeInOut),
    );

    // 스티커 애니메이션
    _stickerScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stickerAnimationController, curve: Curves.easeOut), // elasticOut → easeOut
    );
    _stickerRotateAnimation = Tween<double>(begin: -0.2, end: 0.2).animate( // -0.5, 0.5 → -0.2, 0.2
      CurvedAnimation(parent: _stickerAnimationController, curve: Curves.easeInOut),
    );
    
    // 스켈레톤 애니메이션 시작
    _skeletonAnimationController.repeat();
    
    // 데이터 저장 및 로딩 완료 처리
    _saveDataAndCompleteLoading();
  }

  // 데이터 저장 및 로딩 완료 처리
  void _saveDataAndCompleteLoading() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      // 사용자 프로필 업데이트
      final profile = await auth.fetchUserProfile() ?? UserProfile(name: auth.nickname);
      final updated = profile.copyWith(
        totalScore: profile.totalScore + widget.correctAnswers,
        totalProblems: profile.totalProblems + widget.totalProblems,
      );
      await auth.saveUserProfile(updated);
      
      // 100점 달성 시 스티커 수집
      final score = (widget.correctAnswers / widget.totalProblems * 100).round();
      if (score == 100 && widget.selectedLevel != null) {
        final stickerName = _getStickerNameForLevel(widget.selectedLevel!);
        if (stickerName != null) {
          // 이미 보유 여부 확인 (저장 이전의 상태 기준)
          final collected = await auth.getCollectedStickers();
          _alreadyHadStickerForLevel = collected.contains(stickerName);
          await auth.addStickerToCollection(stickerName);
        }
      }
      
      print('[ResultScreen] Profile and sticker data saved successfully');
      
      // 데이터 저장 완료 후 로딩 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _skeletonAnimationController.stop();
        _animationController.forward();
        _catAnimationController.repeat(reverse: true);

        // 100점 달성 시 스티커 애니메이션 시작 (신규 획득인 경우에만)
        if (score == 100 && widget.selectedLevel != null && !_alreadyHadStickerForLevel) {
          _stickerAnimationController.forward();
        }

        // 레벨 관련 로그는 로직 완료 시점에 1회만 출력
        if (!_levelLoggedOnce) {
          final currentLevel = widget.selectedLevel;
          final nextLevel = currentLevel != null && currentLevel.index < GameLevel.values.length - 1
              ? GameLevel.values[currentLevel.index + 1]
              : null;
          _levelLoggedOnce = true;
          print('[ResultScreen] level: ${currentLevel?.toString() ?? 'null'}, nextLevel: ${nextLevel?.toString() ?? 'null'}');
        }
      }
    } catch (e) {
      print('[ResultScreen] Failed to save data: $e');
      // 에러가 발생해도 로딩 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _skeletonAnimationController.stop();
        _animationController.forward();
        _catAnimationController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _catAnimationController.dispose();
    _stickerAnimationController.dispose();
    _skeletonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 계산을 미리 수행하여 반복 계산 방지
    final correctAnswers = widget.correctAnswers;
    final totalProblems = widget.totalProblems;
    final score = (correctAnswers / totalProblems * 100).round();
    final duration = widget.duration;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Result'),
        leading: widget.onClose != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              )
            : null,
      ),
      body: _isLoading ? _buildSkeletonScreen() : _buildResultContent(score, correctAnswers, totalProblems, duration),
    );
  }

  // 스켈레톤 화면 위젯
  Widget _buildSkeletonScreen() {
    return Material(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 제목 스켈레톤
                _buildSkeletonText(200, 24),
                const SizedBox(height: 24),
                // 메시지 스켈레톤
                _buildSkeletonText(300, 32),
                const SizedBox(height: 24),
                // 점수 표시 스켈레톤
                _buildSkeletonContainer(200, 120),
                const SizedBox(height: 32),
                // 시간 표시 스켈레톤
                _buildSkeletonContainer(180, 60),
                const SizedBox(height: 32),
                // 보상 표시 스켈레톤
                _buildSkeletonContainer(200, 200),
                const SizedBox(height: 40),
                // 버튼 스켈레톤
                _buildSkeletonButton(),
                const SizedBox(height: 16),
                _buildSkeletonButton(),
                const SizedBox(height: 20), // 하단 여백 추가
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 스켈레톤 텍스트 위젯
  Widget _buildSkeletonText(double width, double height) {
    return AnimatedBuilder(
      animation: _skeletonAnimationController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
              stops: [
                0.0,
                (_skeletonShimmerAnimation.value + 1.0) / 3.0,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  // 스켈레톤 컨테이너 위젯
  Widget _buildSkeletonContainer(double width, double height) {
    return AnimatedBuilder(
      animation: _skeletonAnimationController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.05),
              ],
              stops: [
                0.0,
                (_skeletonShimmerAnimation.value + 1.0) / 3.0,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  // 스켈레톤 버튼 위젯
  Widget _buildSkeletonButton() {
    return AnimatedBuilder(
      animation: _skeletonAnimationController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
              stops: [
                0.0,
                (_skeletonShimmerAnimation.value + 1.0) / 3.0,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  // 결과 콘텐츠 위젯
  Widget _buildResultContent(int score, int correctAnswers, int totalProblems, Duration? duration) {
    return Material(
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
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // start → center로 변경
                      children: [
                        if (score == 100) _buildPerfectScoreMessage(),
                        if (score >= 90 && score < 100) _buildExcellentMessage(),
                        if (score < 90) _buildResultEmoji(score),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultEmoji(int score) {
    String message;
    
    if (score >= 90) {
      message = 'Perfect!';
    } else if (score >= 70) {
      message = 'Great job!';
    } else if (score >= 50) {
      message = 'Good!';
    } else {
      message = 'Try again!';
    }

    return Column(
      children: [
        Text(
          message,
          style: const TextStyle(
            fontSize: 32, // 24 → 32로 크기 증가
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)], // 그림자 추가
          ),
          textAlign: TextAlign.center,
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
          Flexible(
            child: Text(
              'Time taken: ${minutes}m ${seconds}s',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardDisplay(int score) {
    // 100점 미달성 시 below100scores.png 표시
    if (score < 100) {
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
              'Keep trying!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
                shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
              ),
            ),
            const SizedBox(height: 12),
            Image.asset(
              'assets/images/below100scores.png',
              height: 200, // 60 → 200
              width: 200,  // 60 → 200
              fit: BoxFit.contain,
              cacheWidth: 400, // 120 → 400 (2x for high DPI displays)
              cacheHeight: 400, // 120 → 400 (2x for high DPI displays)
            ),
          ],
        ),
      );
    }

    // 100점 달성 시
    final currentLevel = widget.selectedLevel;
    if (currentLevel == null) return const SizedBox.shrink();

    // 비로그인 사용자는 스티커 저장 유도 카드 표시
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: UnicornDecorations.cardGlass,
        child: Column(
          children: [
            const Text(
              'Save your sticker!',
              style: UnicornTextStyles.header,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a free account to keep this sticker and track your progress.',
              style: UnicornTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: UnicornButtonStyles.primary,
                onPressed: () {
                  // Auth로 이동하되, 인증 성공 시 결과 화면으로 복귀하여 보상 재평가
                  MainShell.openAuth?.call(true, () {
                    // 인증 후 결과 화면 복귀
                    MainShell.showResultScreen?.call(
                      widget.correctAnswers,
                      widget.totalProblems,
                      widget.duration,
                      widget.selectedLevel,
                    );
                  });
                },
                child: const Text('Sign up & save sticker'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                MainShell.openAuth?.call(false, () {
                  MainShell.showResultScreen?.call(
                    widget.correctAnswers,
                    widget.totalProblems,
                    widget.duration,
                    widget.selectedLevel,
                  );
                });
              },
              child: const Text(
                'I already have an account',
                style: TextStyle(color: Colors.white),
              ),
            ),
            // Removed "Maybe later" to encourage conversion
          ],
        ),
      );
    }

    // 이미 해당 레벨 스티커를 보유하고 있으면 nailed.png 표시
    if (_alreadyHadStickerForLevel) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/images/nailed.png',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
                cacheWidth: 400,
                cacheHeight: 400,
              ),
            ),
          ],
        ),
      );
    }

    // 새로 획득한 경우 기존 스티커 애니메이션 표시
    final stickerImage = _getStickerForLevel(currentLevel);
    if (stickerImage == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _stickerAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _stickerScaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              children: [
                Text(
                  '🎉 Congratulations! You earned a sticker! 🎉',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                    shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Image.asset(
                    stickerImage,
                    height: 160,
                    width: 160,
                    fit: BoxFit.contain,
                    cacheWidth: 320,
                    cacheHeight: 320,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _getStickerForLevel(GameLevel level) {
    switch (level) {
      case GameLevel.level1:
        return 'assets/images/lv1.png';
      case GameLevel.level2:
        return 'assets/images/lv2.png';
      case GameLevel.level3:
        return 'assets/images/lv3.png';
      case GameLevel.level4:
        return 'assets/images/lv4.png';
      case GameLevel.level5:
        return 'assets/images/lv5.png';
      case GameLevel.level6:
        return 'assets/images/lv6.png';
      case GameLevel.level7:
        return 'assets/images/lv7.png';
      case GameLevel.level8:
        return 'assets/images/lv8.png';
      case GameLevel.level9:
        return 'assets/images/lv9.png';
      case GameLevel.level10:
        return 'assets/images/lv10.png';
      case GameLevel.level11:
        return 'assets/images/lv11.png';
      case GameLevel.level12:
        return 'assets/images/lv12.png';
      default:
        return null;
    }
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

  Widget _buildActionButtons() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentLevel = widget.selectedLevel;
    final nextLevel = currentLevel != null && currentLevel.index < GameLevel.values.length - 1
        ? GameLevel.values[currentLevel.index + 1]
        : null;
    
    // Check if current level is lv12 (the last level)
    final isLv12Completed = currentLevel == GameLevel.level12;
    
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
        if (isLv12Completed)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                print('ResultScreen: Starting lv1 game after lv12 completion');
                gameProvider.setGameSettings(
                  totalProblems: gameProvider.totalProblems,
                  operations: LevelManager.getLevelConfig(GameLevel.level1).operations,
                  level: GameLevel.level1,
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
              child: const Text(
                'Retry',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (isLv12Completed) const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              if (MainShell.setTabIndex != null) {
                MainShell.setTabIndex!(0);
              }
              if (widget.onClose != null) {
                widget.onClose!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
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
          offset: Offset(0, -10 * _catBounceAnimation.value), // -20 → -10
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
                  // 단순화된 고양이
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
                          blurRadius: 8, // 10 → 8
                          offset: const Offset(0, 4), // 0, 5 → 0, 4
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 고양이 눈 (단순화)
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
                      ],
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

  Widget _buildPerfectScoreMessage() {
    return Column(
      children: [
        Text(
          "You're a super-duper math star!",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.yellow[400]!, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow[300]!.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            '🌟 Perfect Score! 🌟',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildExcellentMessage() {
    return Column(
      children: [
        Text(
          "You counted like a clever kitty—meowgical job!",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 