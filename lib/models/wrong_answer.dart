import 'dart:convert';

class WrongAnswer {
  final String id;
  final String userId;
  final String questionText;
  final String userAnswer;
  final String correctAnswer;
  final String? operationType;
  final int? level;
  final int count;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WrongAnswer({
    required this.id,
    required this.userId,
    required this.questionText,
    required this.userAnswer,
    required this.correctAnswer,
    this.operationType,
    this.level,
    this.count = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'question_text': questionText,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'operation_type': operationType,
      'level': level,
      'count': count,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    
    // id가 0이 아닐 때만 포함 (새로운 레코드 생성 시 제외)
    if (id != '0' && id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }

  factory WrongAnswer.fromJson(Map<String, dynamic> json) => WrongAnswer(
    id: json['id']?.toString() ?? '0',
    userId: json['user_id'],
    questionText: json['question_text'],
    userAnswer: json['user_answer'],
    correctAnswer: json['correct_answer'],
    operationType: json['operation_type'],
    level: json['level'],
    count: json['count'] ?? 1,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );

  // 중복 확인을 위한 복사본 생성 메서드
  WrongAnswer copyWith({
    String? id,
    String? userId,
    String? questionText,
    String? userAnswer,
    String? correctAnswer,
    String? operationType,
    int? level,
    int? count,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WrongAnswer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionText: questionText ?? this.questionText,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      operationType: operationType ?? this.operationType,
      level: level ?? this.level,
      count: count ?? this.count,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 중복 확인을 위한 키 생성
  String get duplicateKey => '$userId:$questionText';

  static List<WrongAnswer> listFromJson(String jsonStr) {
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((e) => WrongAnswer.fromJson(e)).toList();
  }

  static String listToJson(List<WrongAnswer> list) {
    return json.encode(list.map((e) => e.toJson()).toList());
  }
} 