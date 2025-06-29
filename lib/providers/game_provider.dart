import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Mathicorn/models/math_problem.dart';
import 'package:Mathicorn/models/user_profile.dart';
import 'package:Mathicorn/models/wrong_answer.dart';
import 'package:Mathicorn/providers/wrong_note_provider.dart';

class GameProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  List<MathProblem> _problems = [];
  int _currentProblemIndex = 0;
  int _correctAnswers = 0;
  int _totalProblems = 10;
  List<OperationType> _selectedOperations = [OperationType.addition];
  GameLevel? _selectedLevel;
  bool _isGameActive = false;
  DateTime? _gameStartTime;
  WrongNoteProvider? wrongNoteProvider;

  UserProfile? get userProfile => _userProfile;
  List<MathProblem> get problems => _problems;
  int get currentProblemIndex => _currentProblemIndex;
  int get correctAnswers => _correctAnswers;
  int get totalProblems => _totalProblems;
  List<OperationType> get selectedOperations => _selectedOperations;
  GameLevel? get selectedLevel => _selectedLevel;
  bool get isGameActive => _isGameActive;
  MathProblem? get currentProblem => 
      _problems.isNotEmpty && _currentProblemIndex < _problems.length 
          ? _problems[_currentProblemIndex] 
          : null;

  Future<void> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('userName');
      final totalScore = prefs.getInt('totalScore');
      final totalProblems = prefs.getInt('totalProblems');
      final collectedStickers = prefs.getStringList('collectedStickers');
      
      print('Debug: 프로필 로드 시도 - 이름: $userName, 총 점수: $totalScore, 총 문제 수: $totalProblems');
      
      if (userName != null) {
        _userProfile = UserProfile(
          name: userName,
          totalScore: totalScore ?? 0,
          totalProblems: totalProblems ?? 0,
          collectedStickers: collectedStickers ?? [],
        );
        print('Debug: 프로필 로드 성공 - 총 점수: ${_userProfile!.totalScore}, 총 문제 수: ${_userProfile!.totalProblems}');
      } else {
        // 기본 프로필 생성
        _userProfile = UserProfile(
          name: '친구',
          totalScore: 0,
          totalProblems: 0,
          collectedStickers: [],
        );
        print('Debug: 기본 프로필 생성');
      }
      notifyListeners();
    } catch (e) {
      print('Debug: 프로필 로드 실패: $e');
      // 에러 발생 시 기본 프로필 생성
      _userProfile = UserProfile(
        name: '친구',
        totalScore: 0,
        totalProblems: 0,
        collectedStickers: [],
      );
      notifyListeners();
    }
  }

  Future<void> saveUserProfile() async {
    if (_userProfile == null) {
      print('Debug: 저장할 프로필이 없음');
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _userProfile!.name);
      await prefs.setInt('totalScore', _userProfile!.totalScore);
      await prefs.setInt('totalProblems', _userProfile!.totalProblems);
      await prefs.setStringList('collectedStickers', _userProfile!.collectedStickers);
      
      print('Debug: 프로필 저장 완료 - 이름: ${_userProfile!.name}, 총 점수: ${_userProfile!.totalScore}, 총 문제 수: ${_userProfile!.totalProblems}');
    } catch (e) {
      print('Debug: 프로필 저장 실패: $e');
      rethrow;
    }
  }

  void setUserProfile(String name) {
    // 기존 통계 유지
    int existingTotalScore = _userProfile?.totalScore ?? 0;
    int existingTotalProblems = _userProfile?.totalProblems ?? 0;
    List<String> existingStickers = _userProfile?.collectedStickers ?? [];
    
    _userProfile = UserProfile(
      name: name, 
      totalScore: existingTotalScore,
      totalProblems: existingTotalProblems,
      collectedStickers: existingStickers,
    );
    saveUserProfile();
    notifyListeners();
  }

  void setGameSettings({
    required int totalProblems,
    required List<OperationType> operations,
    GameLevel? level,
  }) {
    _totalProblems = totalProblems;
    _selectedOperations = operations;
    _selectedLevel = level;
    notifyListeners();
  }

  void startGame() {
    try {
      // 프로필이 로드되지 않았다면 다시 로드
      if (_userProfile == null) {
        print('Debug: 게임 시작 시 프로필이 없어서 로드 시도');
        loadUserProfile();
      }
      
      _generateProblems();
      
      // 문제가 제대로 생성되었는지 확인
      if (_problems.isEmpty) {
        throw Exception('문제 생성에 실패했습니다.');
      }
      
      _currentProblemIndex = 0;
      _correctAnswers = 0;
      _isGameActive = true;
      _gameStartTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      // 에러 발생 시 기본 문제로 재시도
      _problems.clear();
      _selectedOperations = [OperationType.addition];
      _totalProblems = 5;
      _selectedLevel = null;
      _generateProblems();
      _currentProblemIndex = 0;
      _correctAnswers = 0;
      _isGameActive = true;
      _gameStartTime = DateTime.now();
      notifyListeners();
    }
  }

  void _generateProblems() {
    _problems.clear();
    final random = Random();
    
    if (_selectedLevel != null) {
      // 레벨 기반 문제 생성
      _generateLevelBasedProblems(random);
    } else {
      // 기존 방식 (연산 선택 기반)
      _generateOperationBasedProblems(random);
    }
  }

  void _generateLevelBasedProblems(Random random) {
    final levelConfig = LevelManager.getLevelConfig(_selectedLevel!);
    
    for (int i = 0; i < _totalProblems; i++) {
      MathProblem problem;
      
      if (levelConfig.isMixed && levelConfig.operations.length > 1) {
        // 혼합 연산 문제 생성 (Lv11 이상)
        problem = _createMixedOperationProblem(levelConfig, random);
      } else {
        // 단일 연산 문제 생성
        final operation = levelConfig.operations[random.nextInt(levelConfig.operations.length)];
        problem = _createSingleOperationProblem(operation, levelConfig, random);
      }
      
      _problems.add(problem);
    }
  }

  void _generateOperationBasedProblems(Random random) {
    for (int i = 0; i < _totalProblems; i++) {
      final operation = _selectedOperations[random.nextInt(_selectedOperations.length)];
      MathProblem problem;
      
      switch (operation) {
        case OperationType.addition:
          final num1 = random.nextInt(20) + 1;
          final num2 = random.nextInt(20) + 1;
          final answer = num1 + num2;
          problem = _createProblem(num1, num2, operation, answer);
          break;
        case OperationType.subtraction:
          final num1 = random.nextInt(20) + 10;
          final num2 = random.nextInt(num1) + 1;
          final answer = num1 - num2;
          problem = _createProblem(num1, num2, operation, answer);
          break;
        case OperationType.multiplication:
          final num1 = random.nextInt(10) + 1;
          final num2 = random.nextInt(10) + 1;
          final answer = num1 * num2;
          problem = _createProblem(num1, num2, operation, answer);
          break;
        case OperationType.division:
          final num2 = random.nextInt(9) + 2;
          final answer = random.nextInt(10) + 1;
          final num1 = num2 * answer;
          problem = _createProblem(num1, num2, operation, answer);
          break;
      }
      
      _problems.add(problem);
    }
  }

  MathProblem _createSingleOperationProblem(OperationType operation, LevelConfig levelConfig, Random random) {
    int num1, num2, answer;
    
    switch (operation) {
      case OperationType.addition:
        // 덧셈: 자리 올림 없이 시작
        if (levelConfig.level == GameLevel.level1) {
          // Lv1: 1~5 범위, 자리 올림 없음
          num1 = random.nextInt(5) + 1;
          num2 = random.nextInt(5 - num1 + 1) + 1;
        } else if (levelConfig.level == GameLevel.level5) {
          // Lv5: 두 자리 수 덧셈, 자리 올림 없음
          num1 = random.nextInt(40) + 10; // 10~49
          num2 = random.nextInt(50 - num1) + 10; // num1 + num2 < 100
        } else {
          // 일반 덧셈
          num1 = random.nextInt(levelConfig.maxNumber - levelConfig.minNumber + 1) + levelConfig.minNumber;
          num2 = random.nextInt(levelConfig.maxNumber - levelConfig.minNumber + 1) + levelConfig.minNumber;
        }
        answer = num1 + num2;
        break;
        
      case OperationType.subtraction:
        // 뺄셈: 자리 내림 없이 시작
        if (levelConfig.level == GameLevel.level2) {
          // Lv2: 1~10 범위, 자리 내림 없음
          num1 = random.nextInt(10) + 1;
          num2 = random.nextInt(num1) + 1;
        } else if (levelConfig.level == GameLevel.level6) {
          // Lv6: 두 자리 수 뺄셈, 자리 내림 없음
          num1 = random.nextInt(40) + 50; // 50~89
          num2 = random.nextInt(num1 - 10) + 10; // 10 <= num2 < num1
        } else {
          // 일반 뺄셈
          num1 = random.nextInt(levelConfig.maxNumber - levelConfig.minNumber + 1) + levelConfig.minNumber;
          num2 = random.nextInt(num1 - levelConfig.minNumber + 1) + levelConfig.minNumber;
        }
        answer = num1 - num2;
        break;
        
      case OperationType.multiplication:
        // 곱셈: 구구단 안에서만
        if (levelConfig.level == GameLevel.level7) {
          // Lv7: 2~3단
          num1 = random.nextInt(2) + 2; // 2~3
          num2 = random.nextInt(9) + 1; // 1~9
        } else if (levelConfig.level == GameLevel.level8) {
          // Lv8: 4~6단
          num1 = random.nextInt(3) + 4; // 4~6
          num2 = random.nextInt(9) + 1; // 1~9
        } else if (levelConfig.level == GameLevel.level9) {
          // Lv9: 7~9단
          num1 = random.nextInt(3) + 7; // 7~9
          num2 = random.nextInt(9) + 1; // 1~9
        } else {
          // 일반 곱셈
          num1 = random.nextInt(levelConfig.maxNumber - levelConfig.minNumber + 1) + levelConfig.minNumber;
          num2 = random.nextInt(levelConfig.maxNumber - levelConfig.minNumber + 1) + levelConfig.minNumber;
        }
        answer = num1 * num2;
        break;
        
      case OperationType.division:
        // 나눗셈: 나눠떨어지게
        if (levelConfig.level == GameLevel.level10) {
          // Lv10: 간단한 나눗셈, 나눠떨어지게
          num2 = random.nextInt(9) + 2; // 2~10
          answer = random.nextInt(10) + 1; // 1~10
          num1 = num2 * answer;
        } else {
          // 일반 나눗셈
          num2 = random.nextInt(levelConfig.maxNumber - levelConfig.minNumber + 1) + levelConfig.minNumber;
          if (num2 == 0) num2 = 1;
          answer = random.nextInt(10) + 1;
          num1 = num2 * answer;
        }
        break;
    }
    
    return _createProblem(num1, num2, operation, answer, level: levelConfig.level);
  }

  MathProblem _createMixedOperationProblem(LevelConfig levelConfig, Random random) {
    // 혼합 연산 문제 생성 (Lv11 이상)
    final operation1 = levelConfig.operations[0];
    final operation2 = levelConfig.operations[1];
    
    int num1, num2, num3, answer;
    String questionText;
    
    if (levelConfig.hasParentheses) {
      // Lv12: 괄호 포함 혼합 연산
      // (num1 + num2) × num3 형태
      num1 = random.nextInt(5) + 1; // 1~5
      num2 = random.nextInt(5) + 1; // 1~5
      num3 = random.nextInt(5) + 1; // 1~5
      
      int tempResult = _calculateResult(num1, num2, operation1);
      answer = _calculateResult(tempResult, num3, operation2);
      questionText = '($num1 ${_getOperationSymbol(operation1)} $num2) ${_getOperationSymbol(operation2)} $num3 = ?';
    } else {
      // Lv11: 일반 혼합 연산 (연산 순서 고려)
      if (operation2 == OperationType.multiplication) {
        // num1 + num2 × num3 형태 (곱셈 우선)
        num1 = random.nextInt(5) + 1; // 1~5
        num2 = random.nextInt(5) + 1; // 1~5
        num3 = random.nextInt(5) + 1; // 1~5
        
        int tempResult = _calculateResult(num2, num3, operation2);
        answer = _calculateResult(num1, tempResult, operation1);
        questionText = '$num1 ${_getOperationSymbol(operation1)} $num2 ${_getOperationSymbol(operation2)} $num3 = ?';
      } else {
        // num1 + num2 - num3 형태 (왼쪽부터 계산)
        num1 = random.nextInt(5) + 1; // 1~5
        num2 = random.nextInt(5) + 1; // 1~5
        num3 = random.nextInt(5) + 1; // 1~5
        
        int tempResult = _calculateResult(num1, num2, operation1);
        answer = _calculateResult(tempResult, num3, operation2);
        questionText = '$num1 ${_getOperationSymbol(operation1)} $num2 ${_getOperationSymbol(operation2)} $num3 = ?';
      }
    }
    
    return _createProblem(num1, num2, operation1, answer, level: levelConfig.level, questionText: questionText);
  }

  int _calculateResult(int a, int b, OperationType operation) {
    switch (operation) {
      case OperationType.addition:
        return a + b;
      case OperationType.subtraction:
        return a - b;
      case OperationType.multiplication:
        return a * b;
      case OperationType.division:
        return a ~/ b;
    }
  }

  MathProblem _createProblem(int num1, int num2, OperationType operation, int correctAnswer, {GameLevel? level, String? questionText}) {
    final random = Random();
    final choices = <int>[correctAnswer];
    
    // 잘못된 선택지 생성 (무한 루프 방지)
    int attempts = 0;
    while (choices.length < 4 && attempts < 20) {
      attempts++;
      int wrongAnswer;
      
      switch (operation) {
        case OperationType.addition:
          wrongAnswer = correctAnswer + random.nextInt(10) - 5;
          break;
        case OperationType.subtraction:
          wrongAnswer = correctAnswer + random.nextInt(10) - 5;
          break;
        case OperationType.multiplication:
          wrongAnswer = correctAnswer + random.nextInt(10) - 5;
          break;
        case OperationType.division:
          wrongAnswer = correctAnswer + random.nextInt(5) - 2;
          break;
      }
      
      // 음수 방지 및 중복 방지
      if (wrongAnswer > 0 && wrongAnswer != correctAnswer && !choices.contains(wrongAnswer)) {
        choices.add(wrongAnswer);
      }
    }
    
    // 4개가 되지 않으면 강제로 추가
    while (choices.length < 4) {
      int additionalAnswer = correctAnswer + choices.length;
      if (!choices.contains(additionalAnswer)) {
        choices.add(additionalAnswer);
      } else {
        additionalAnswer = correctAnswer - choices.length;
        if (additionalAnswer > 0 && !choices.contains(additionalAnswer)) {
          choices.add(additionalAnswer);
        } else {
          choices.add(correctAnswer + 10 + choices.length);
        }
      }
    }
    
    choices.shuffle();
    
    return MathProblem(
      num1: num1,
      num2: num2,
      operation: operation,
      correctAnswer: correctAnswer,
      choices: choices,
      questionText: questionText ?? '$num1 ${_getOperationSymbol(operation)} $num2 = ?',
      level: level,
    );
  }

  String _getOperationSymbol(OperationType operation) {
    switch (operation) {
      case OperationType.addition:
        return '+';
      case OperationType.subtraction:
        return '-';
      case OperationType.multiplication:
        return '×';
      case OperationType.division:
        return '÷';
    }
  }

  bool answerQuestion(int selectedAnswer) {
    final currentProblem = this.currentProblem;
    if (currentProblem == null) return false;
    final isCorrect = selectedAnswer == currentProblem.correctAnswer;
    if (isCorrect) {
      _correctAnswers++;
    } else {
      // 오답 기록 저장
      if (wrongNoteProvider != null) {
        final wrongAnswer = WrongAnswer(
          problemId: _generateProblemId(),
          question: currentProblem.questionText,
          userAnswer: selectedAnswer.toString(),
          correctAnswer: currentProblem.correctAnswer.toString(),
          timestamp: DateTime.now(),
          type: currentProblem.operationText,
          level: currentProblem.level != null ? currentProblem.level!.index + 1 : 0,
        );
        wrongNoteProvider!.addWrongAnswer(wrongAnswer);
      }
    }
    notifyListeners();
    return isCorrect;
  }

  String _generateProblemId() {
    final now = DateTime.now();
    return 'Q${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  // 오답 후 다시 시도할 때 호출
  void retryCurrentProblem() {
    // 현재 문제 인덱스를 그대로 유지 (이미 answerQuestion에서 증가시키지 않았음)
    notifyListeners();
  }

  // 정답 처리 후 다음 문제로 넘어갈 때 호출
  void moveToNextProblem() {
    _currentProblemIndex++;
    
    // 디버그: 정답 수 확인
    print('Debug: 현재 정답 수: $_correctAnswers, 총 문제 수: $_totalProblems, 현재 문제 인덱스: $_currentProblemIndex');
    
    if (_currentProblemIndex >= _problems.length) {
      _endGame();
    }
    
    notifyListeners();
  }

  void _endGame() {
    _isGameActive = false;
    
    // 정답 수를 다시 계산하여 정확성 보장
    int finalCorrectAnswers = _correctAnswers;
    
    print('Debug: 게임 종료 - 정답 수: $finalCorrectAnswers, 총 문제 수: $_totalProblems');
    
    if (_userProfile != null) {
      // 통계 업데이트
      int newTotalScore = _userProfile!.totalScore + finalCorrectAnswers;
      int newTotalProblems = _userProfile!.totalProblems + _totalProblems;
      
      print('Debug: 기존 통계 - 총 점수: ${_userProfile!.totalScore}, 총 문제 수: ${_userProfile!.totalProblems}');
      print('Debug: 새로운 통계 - 총 점수: $newTotalScore, 총 문제 수: $newTotalProblems');
      
      _userProfile = _userProfile!.copyWith(
        totalScore: newTotalScore,
        totalProblems: newTotalProblems,
      );
      
      // 즉시 저장하고 UI 업데이트
      saveUserProfile().then((_) {
        print('Debug: 통계 저장 완료');
        notifyListeners();
      }).catchError((error) {
        print('Debug: 통계 저장 실패: $error');
        notifyListeners();
      });
    } else {
      print('Debug: 사용자 프로필이 없음');
      notifyListeners();
    }
    
    // 최종 정답 수를 다시 설정
    _correctAnswers = finalCorrectAnswers;
  }

  void resetGame() {
    _currentProblemIndex = 0;
    _correctAnswers = 0;
    _isGameActive = false;
    _problems.clear();
    notifyListeners();
  }

  Duration? get gameDuration {
    if (_gameStartTime == null) return null;
    return DateTime.now().difference(_gameStartTime!);
  }
} 