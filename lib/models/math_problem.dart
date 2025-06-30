enum OperationType { addition, subtraction, multiplication, division }

enum GameLevel {
  level1,
  level2,
  level3,
  level4,
  level5,
  level6,
  level7,
  level8,
  level9,
  level10,
  level11,
  level12,
}

class LevelConfig {
  final GameLevel level;
  final String name;
  final String description;
  final String example;
  final List<OperationType> operations;
  final int minNumber;
  final int maxNumber;
  final bool hasParentheses;
  final bool isMixed;

  const LevelConfig({
    required this.level,
    required this.name,
    required this.description,
    required this.example,
    required this.operations,
    required this.minNumber,
    required this.maxNumber,
    this.hasParentheses = false,
    this.isMixed = false,
  });
}

class MathProblem {
  final int num1;
  final int num2;
  final OperationType operation;
  final int correctAnswer;
  final List<int> choices;
  final String questionText;
  final GameLevel? level;

  MathProblem({
    required this.num1,
    required this.num2,
    required this.operation,
    required this.correctAnswer,
    required this.choices,
    required this.questionText,
    this.level,
  });

  String get operationSymbol {
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

  String get operationText {
    switch (operation) {
      case OperationType.addition:
        return '더하기';
      case OperationType.subtraction:
        return '빼기';
      case OperationType.multiplication:
        return '곱하기';
      case OperationType.division:
        return '나누기';
    }
  }
}

class LevelManager {
  static const Map<GameLevel, LevelConfig> levelConfigs = {
    GameLevel.level1: LevelConfig(
      level: GameLevel.level1,
      name: 'Lv1',
      description: 'Numbers 1~10, Addition',
      example: '7 + 3 = ?',
      operations: [OperationType.addition],
      minNumber: 1,
      maxNumber: 10,
    ),
    GameLevel.level2: LevelConfig(
      level: GameLevel.level2,
      name: 'Lv2',
      description: 'Numbers 1~10, Subtraction',
      example: '8 - 3 = ?',
      operations: [OperationType.subtraction],
      minNumber: 1,
      maxNumber: 10,
    ),
    GameLevel.level3: LevelConfig(
      level: GameLevel.level3,
      name: 'Lv3',
      description: 'Numbers 1~20, Addition (Two-digit + One-digit)',
      example: '15 + 7 = ?',
      operations: [OperationType.addition],
      minNumber: 1,
      maxNumber: 20,
    ),
    GameLevel.level4: LevelConfig(
      level: GameLevel.level4,
      name: 'Lv4',
      description: 'Numbers 1~20, Subtraction (Two-digit - One-digit)',
      example: '18 - 9 = ?',
      operations: [OperationType.subtraction],
      minNumber: 1,
      maxNumber: 20,
    ),
    GameLevel.level5: LevelConfig(
      level: GameLevel.level5,
      name: 'Lv5',
      description: 'Two-digit Addition',
      example: '23 + 12 = ?',
      operations: [OperationType.addition],
      minNumber: 10,
      maxNumber: 99,
    ),
    GameLevel.level6: LevelConfig(
      level: GameLevel.level6,
      name: 'Lv6',
      description: 'Two-digit Subtraction',
      example: '54 - 26 = ?',
      operations: [OperationType.subtraction],
      minNumber: 10,
      maxNumber: 99,
    ),
    GameLevel.level7: LevelConfig(
      level: GameLevel.level7,
      name: 'Lv7',
      description: 'Multiplication Tables 2~3',
      example: '2 × 4 = ?',
      operations: [OperationType.multiplication],
      minNumber: 2,
      maxNumber: 9,
    ),
    GameLevel.level8: LevelConfig(
      level: GameLevel.level8,
      name: 'Lv8',
      description: 'Multiplication Tables 4~6',
      example: '6 × 7 = ?',
      operations: [OperationType.multiplication],
      minNumber: 4,
      maxNumber: 9,
    ),
    GameLevel.level9: LevelConfig(
      level: GameLevel.level9,
      name: 'Lv9',
      description: 'Multiplication Tables 7~9',
      example: '8 × 9 = ?',
      operations: [OperationType.multiplication],
      minNumber: 7,
      maxNumber: 9,
    ),
    GameLevel.level10: LevelConfig(
      level: GameLevel.level10,
      name: 'Lv10',
      description: 'Simple Division (Integer Results)',
      example: '12 ÷ 3 = ?',
      operations: [OperationType.division],
      minNumber: 2,
      maxNumber: 12,
    ),
    GameLevel.level11: LevelConfig(
      level: GameLevel.level11,
      name: 'Lv11',
      description: 'Mixed Operations (Addition + Multiplication)',
      example: '3 + 2 × 4 = ?',
      operations: [OperationType.addition, OperationType.multiplication],
      minNumber: 1,
      maxNumber: 10,
      isMixed: true,
    ),
    GameLevel.level12: LevelConfig(
      level: GameLevel.level12,
      name: 'Lv12',
      description: 'Mixed Operations with Parentheses',
      example: '(2 + 3) × 4 = ?',
      operations: [OperationType.addition, OperationType.multiplication],
      minNumber: 1,
      maxNumber: 10,
      hasParentheses: true,
      isMixed: true,
    ),
  };

  static LevelConfig getLevelConfig(GameLevel level) {
    return levelConfigs[level]!;
  }

  static List<LevelConfig> getAllLevels() {
    return levelConfigs.values.toList();
  }
} 