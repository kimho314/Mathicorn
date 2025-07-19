import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import 'package:Mathicorn/providers/settings_provider.dart';
import 'package:Mathicorn/screens/result_screen.dart';
import 'package:Mathicorn/models/math_problem.dart';
import 'package:Mathicorn/screens/home_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/statistics_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/unicorn_theme.dart';
import 'package:Mathicorn/screens/main_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _questionAnimationController;
  late AnimationController _feedbackAnimationController;
  late Animation<double> _questionScaleAnimation;
  late Animation<double> _feedbackScaleAnimation;
  
  bool _showingFeedback = false;
  bool _isCorrect = false;
  int? _selectedAnswer;
  MathProblem? _previousProblem; // 이전 문제를 추적
  bool _showingWrongAnswerDialog = false; // 오답 다이얼로그 표시 상태
  bool _showingCorrectAnswer = false; // 정답 확인 모드 상태
  bool _showingCongratulations = false; // 축하 메시지 표시 상태
  DateTime? _problemStartTime;

  // 오디오 플레이어를 클래스 변수로 선언
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // 통계 객체가 없으면 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      if (auth.isLoggedIn && auth.user != null && statisticsProvider.statistics == null) {
        statisticsProvider.initializeStatistics(auth.user!.id);
      }
      
      // 설정이 로드되지 않았으면 로드
      if (auth.isLoggedIn && (settingsProvider.loading || settingsProvider.settings == null)) {
        settingsProvider.loadSettings(auth);
      }
    });
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _questionScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _questionAnimationController, curve: Curves.elasticOut),
    );
    _feedbackScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackAnimationController, curve: Curves.bounceOut),
    );
    
    _questionAnimationController.forward();
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    _feedbackAnimationController.dispose();
    _audioPlayer.dispose(); // 오디오 플레이어 해제
    super.dispose();
  }

  // 문제가 바뀌었는지 확인하고 상태 초기화
  void _checkAndResetState(MathProblem? currentProblem) {
    if (!mounted) return;
    
    // 축하 메시지가 표시 중일 때는 상태 초기화하지 않음
    if (_showingCongratulations) return;
    
    if (currentProblem != null && _previousProblem != currentProblem) {
      // 문제가 바뀌었을 때 모든 상태 완전 초기화
      setState(() {
        _showingFeedback = false;
        _selectedAnswer = null;
        _isCorrect = false;
        _showingWrongAnswerDialog = false;
        _showingCorrectAnswer = false; // 정답 확인 모드도 초기화
        _showingCongratulations = false; // 축하 메시지도 초기화
      });
      _previousProblem = currentProblem;
      _problemStartTime = DateTime.now(); // 문제 시작 시각 기록
      
      // 애니메이션 컨트롤러 완전 리셋
      _feedbackAnimationController.reset();
      _questionAnimationController.reset();
      _questionAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: UnicornDecorations.appBackground,
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              final isResultScreen = ModalRoute.of(context)?.settings.name == 'ResultScreen';
              final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
              if (!gameProvider.isGameActive && !isResultScreen && isCurrent) {
                // 게임이 끝났을 때는 홈으로 이동하지 않고 ResultScreen을 기다림
                return const Center(child: CircularProgressIndicator());
              }

              final currentProblem = gameProvider.currentProblem;
              if (currentProblem == null && !isResultScreen && isCurrent) {
                // 문제가 없으면 홈으로 돌아가기 (빌드 완료 후 실행)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('게임을 시작할 수 없습니다. 다시 시도해주세요.')),
                    );
                    MainShell.setTabIndex?.call(0); // 홈으로 이동
                  }
                });
                return const Center(child: CircularProgressIndicator());
              }

              // 문제가 바뀌었는지 확인하고 상태 초기화 (빌드 완료 후 실행)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  // 축하 메시지가 표시 중일 때는 상태 초기화하지 않음
                  if (!_showingCongratulations) {
                    _checkAndResetState(currentProblem);
                  }
                }
              });

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: UnicornDecorations.cardGlass,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProgressBar(gameProvider),
                        if (_showingCongratulations)
                          _buildCongratulationsMessage(),
                        if (currentProblem != null) ...[
                          _buildQuestionDisplay(currentProblem),
                          const SizedBox(height: 40),
                          _buildAnswerChoices(currentProblem, gameProvider),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(GameProvider gameProvider) {
    final progress = (gameProvider.currentProblemIndex + 1) / gameProvider.totalProblems;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Problem ${gameProvider.currentProblemIndex + 1}/${gameProvider.totalProblems}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Correct: ${gameProvider.correctAnswers}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionDisplay(MathProblem problem) {
    return AnimatedBuilder(
      animation: _questionScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _questionScaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  problem.questionText,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerChoices(MathProblem problem, GameProvider gameProvider) {
    return Column(
      children: [
        for (int i = 0; i < problem.choices.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildAnswerButton(
                    problem.choices[i],
                    problem,
                    gameProvider,
                  ),
                ),
                if (i + 1 < problem.choices.length) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAnswerButton(
                      problem.choices[i + 1],
                      problem,
                      gameProvider,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAnswerButton(
    int answer,
    MathProblem problem,
    GameProvider gameProvider,
  ) {
    final isSelected = _selectedAnswer == answer;
    final isCorrectAnswer = answer == problem.correctAnswer;
    
    // 기본값: 모든 버튼은 흰색
    Color buttonColor = Colors.white;
    Color textColor = Colors.black87;
    Color borderColor = Colors.grey.withOpacity(0.3);
    double borderWidth = 1;
    
    // 피드백 표시 중일 때 색상 변경
    if (_showingFeedback) {
      if ((_isCorrect && isCorrectAnswer) || (_showingCorrectAnswer && isCorrectAnswer)) {
        // 정답이거나 정답 확인 모드에서 정답은 초록색으로 표시
        buttonColor = Colors.green;
        textColor = Colors.white;
        borderColor = Colors.green;
        borderWidth = 3;
      } else if (isSelected && !isCorrectAnswer) {
        // 선택한 답이 틀렸으면 빨간색으로 표시
        buttonColor = Colors.red;
        textColor = Colors.white;
        borderColor = Colors.red;
        borderWidth = 3;
      } else if (!_showingCorrectAnswer) {
        // 정답 확인 모드가 아닐 때는 선택하지 않은 답을 회색으로 표시
        buttonColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        borderColor = Colors.grey.withOpacity(0.3);
        borderWidth = 1;
      }
    } else if (_selectedAnswer != null && isSelected) {
      // 피드백 표시 전에 선택된 답만 파란색으로 표시
      buttonColor = Colors.blue;
      textColor = Colors.white;
      borderColor = Colors.blue;
      borderWidth = 2;
    }
    // 그 외의 경우는 모두 기본 흰색 유지

    return AnimatedBuilder(
      animation: _feedbackAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _showingFeedback && (isSelected || (_isCorrect && isCorrectAnswer) || (_showingCorrectAnswer && isCorrectAnswer))
              ? _feedbackScaleAnimation.value 
              : 1.0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showingFeedback ? null : () => _selectAnswer(answer, problem, gameProvider),
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        answer.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if ((_isCorrect && isCorrectAnswer) || (_showingCorrectAnswer && isCorrectAnswer))
                        const Text(
                          'Correct!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_showingFeedback && isSelected && !isCorrectAnswer)
                        const Text(
                          'Wrong',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

  void _selectAnswer(int answer, MathProblem problem, GameProvider gameProvider) {
    if (!mounted) return;
    setState(() {
      _selectedAnswer = answer;
    });
    final isCorrect = gameProvider.answerQuestion(answer);

    // 통계 자동 갱신
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoggedIn && auth.user != null) {
      final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
      final now = DateTime.now();
      final dateStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final timeTaken = _problemStartTime != null ? now.difference(_problemStartTime!).inMilliseconds / 1000.0 : 5.0;
      statisticsProvider.updateStatisticsOnSubmit(
        isCorrect: isCorrect,
        operation: problem.operationText,
        timeTaken: timeTaken,
        date: dateStr,
        level: problem.level != null ? problem.level!.index + 1 : null,
      );
    }

    if (mounted) {
      setState(() {
        _showingFeedback = true;
        _isCorrect = isCorrect;
        _showingCorrectAnswer = false;
        _showingCongratulations = false; // 기존 축하 메시지 사용 안함
      });
    }
    _feedbackAnimationController.forward();
    if (isCorrect) {
      // 정답일 때: 다이얼로그 표시
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showCongratulationsDialog(problem, gameProvider);
        }
      });
    } else {
      // 오답일 때: 0.3초 후 다이얼로그 표시
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showWrongAnswerDialog(problem, gameProvider);
        }
      });
    }
  }

  void _showCongratulationsDialog(MathProblem problem, GameProvider gameProvider) {
    // 사운드 설정 확인 - 로딩 중이면 소리 재생하지 않음
    final settingsProvider = context.read<SettingsProvider>();
    if (!settingsProvider.loading && settingsProvider.soundEnabled) {
      _audioPlayer.stop(); // 기존 사운드 중지
      _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3E5F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: Column(
          children: [
            Lottie.asset('assets/animations/unicorn.json', width: 80, repeat: false),
            const SizedBox(height: 8),
            const Text(
              'Congratulations! 🎉',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C4DFF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 300,
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/animations/star.json', width: 60, repeat: false),
              const SizedBox(height: 12),
              const Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'You got the correct answer!',
                    style: TextStyle(fontSize: 18, color: Color(0xFF512DA8)),
                  ),
                  SizedBox(width: 8),
                  Text('🌟', style: TextStyle(fontSize: 20)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _moveToNextProblem();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _moveToNextProblem() async {
    if (!mounted) return;
    // 문제 넘어갈 때 사운드 중지
    _audioPlayer.stop();
    // GameProvider에서 다음 문제로 이동
    final gameProvider = context.read<GameProvider>();
    final wasLastProblem = gameProvider.currentProblemIndex + 1 >= gameProvider.totalProblems;
    gameProvider.moveToNextProblem();
    // 게임이 끝났으면 결과 화면으로 이동
    if (wasLastProblem) {
      final correctAnswers = gameProvider.correctAnswers;
      final totalProblems = gameProvider.totalProblems;
      final duration = gameProvider.gameDuration;
      // 통계 최종 저장 (로그인 유저만) - 프로필과 스티커는 MainShell에서 처리
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isLoggedIn && auth.user != null) {
        final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
        await statisticsProvider.upsertStatistics();
      }
      final lastLevel = gameProvider.problems.isNotEmpty ? gameProvider.problems.last.level : null;
      print('GameScreen: lastLevel = ' + (lastLevel?.toString() ?? 'null'));
      // 즉시 ResultScreen 호출 (지연 시간 제거)
      MainShell.showResultScreen?.call(correctAnswers, totalProblems, duration, lastLevel);
      return;
    }
    
    // 모든 상태 완전 초기화
    setState(() {
      _showingFeedback = false;
      _selectedAnswer = null;
      _isCorrect = false;
      _showingWrongAnswerDialog = false;
      _showingCorrectAnswer = false; // 정답 확인 모드도 초기화
      _showingCongratulations = false; // 축하 메시지도 초기화
    });
    
    // 애니메이션 컨트롤러 완전 리셋
    _feedbackAnimationController.reset();
    _questionAnimationController.reset();
    _questionAnimationController.forward();
  }

  void _showWrongAnswerDialog(MathProblem problem, GameProvider gameProvider) {
    // 사운드 설정 확인 - 로딩 중이면 소리 재생하지 않음
    final settingsProvider = context.read<SettingsProvider>();
    if (!settingsProvider.loading && settingsProvider.soundEnabled) {
      _audioPlayer.stop(); // 기존 사운드 중지
      _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
    }
    
    setState(() {
      _showingWrongAnswerDialog = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: Column(
          children: [
            Lottie.asset('assets/animations/confetti.json', width: 80, repeat: false),
            const SizedBox(height: 8),
            const Text(
              'Wrong Answer! 😢',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/animations/star.json', width: 60, repeat: false),
            const SizedBox(height: 12),
            const Text(
              'You can try again or check the correct answer.',
              style: TextStyle(fontSize: 18, color: Color(0xFF512DA8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _retryProblem(gameProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _checkAnswer(problem, gameProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Check Answer'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _showingWrongAnswerDialog = false;
        });
      }
    });
  }

  void _retryProblem(GameProvider gameProvider) {
    if (!mounted) return;
    
    // GameProvider에서 현재 문제를 다시 시도할 수 있도록 설정
    gameProvider.retryCurrentProblem();
    
    // 모든 상태 완전 초기화
    setState(() {
      _showingFeedback = false;
      _selectedAnswer = null;
      _isCorrect = false;
      _showingWrongAnswerDialog = false;
      _showingCorrectAnswer = false; // 정답 확인 모드도 초기화
      _showingCongratulations = false; // 축하 메시지도 초기화
    });
    
    // 애니메이션 컨트롤러 완전 리셋
    _feedbackAnimationController.reset();
    _questionAnimationController.reset();
    _questionAnimationController.forward();
  }

  void _checkAnswer(MathProblem problem, GameProvider gameProvider) {
    if (!mounted) return;
    // 정답 확인 모드 활성화
    setState(() {
      _showingFeedback = true;
      _showingCorrectAnswer = true; // 정답 확인 모드 활성화
    });
    // 1.5초 후 다음 문제로 넘어가기
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _moveToNextProblem(); // 여기서만 호출
      }
    });
  }

  Widget _buildCongratulationsMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _moveToNextProblem(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 