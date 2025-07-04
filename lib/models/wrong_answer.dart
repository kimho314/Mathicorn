import 'dart:convert';

class WrongAnswer {
  final String id;
  final String userId;
  final String questionText;
  final String userAnswer;
  final String correctAnswer;
  final String? operationType;
  final int? level;
  final DateTime? createdAt;

  WrongAnswer({
    required this.id,
    required this.userId,
    required this.questionText,
    required this.userAnswer,
    required this.correctAnswer,
    this.operationType,
    this.level,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'question_text': questionText,
    'user_answer': userAnswer,
    'correct_answer': correctAnswer,
    'operation_type': operationType,
    'level': level,
    'created_at': createdAt?.toIso8601String(),
  };

  factory WrongAnswer.fromJson(Map<String, dynamic> json) => WrongAnswer(
    id: json['id'],
    userId: json['user_id'],
    questionText: json['question_text'],
    userAnswer: json['user_answer'],
    correctAnswer: json['correct_answer'],
    operationType: json['operation_type'],
    level: json['level'],
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
  );

  static List<WrongAnswer> listFromJson(String jsonStr) {
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((e) => WrongAnswer.fromJson(e)).toList();
  }

  static String listToJson(List<WrongAnswer> list) {
    return json.encode(list.map((e) => e.toJson()).toList());
  }
} 