import 'dart:convert';

class WrongAnswer {
  final String problemId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final DateTime timestamp;
  final String type; // 덧셈, 뺄셈, 곱셈, 나눗셈, 혼합 등
  final int level;
  final bool isFlagged;

  WrongAnswer({
    required this.problemId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.timestamp,
    required this.type,
    required this.level,
    this.isFlagged = false,
  });

  Map<String, dynamic> toJson() => {
    'problemId': problemId,
    'question': question,
    'userAnswer': userAnswer,
    'correctAnswer': correctAnswer,
    'created_at': timestamp.toIso8601String(),
    'type': type,
    'level': level,
    'isFlagged': isFlagged,
  };

  factory WrongAnswer.fromJson(Map<String, dynamic> json) => WrongAnswer(
    problemId: json['problemId'],
    question: json['question'],
    userAnswer: json['userAnswer'],
    correctAnswer: json['correctAnswer'],
    timestamp: DateTime.parse(json['created_at']),
    type: json['type'],
    level: json['level'],
    isFlagged: json['isFlagged'] ?? false,
  );

  static List<WrongAnswer> listFromJson(String jsonStr) {
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((e) => WrongAnswer.fromJson(e)).toList();
  }

  static String listToJson(List<WrongAnswer> list) {
    return json.encode(list.map((e) => e.toJson()).toList());
  }
} 