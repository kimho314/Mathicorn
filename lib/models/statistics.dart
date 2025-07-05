import 'dart:convert';

class Statistics {
  final String userId;
  final int totalSolved;
  final int totalCorrect;
  final double averageAccuracy;
  final double averageTimePerQuestion;
  final String favoriteOperation;
  final String weakestOperation;
  final Map<String, int> dailyActivity;
  final Map<String, double> operationAccuracy;
  final Map<int, double> levelAccuracy;

  Statistics({
    required this.userId,
    required this.totalSolved,
    required this.totalCorrect,
    required this.averageAccuracy,
    required this.averageTimePerQuestion,
    required this.favoriteOperation,
    required this.weakestOperation,
    required this.dailyActivity,
    required this.operationAccuracy,
    required this.levelAccuracy,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      userId: json['user_id'] as String,
      totalSolved: json['total_solved'] ?? 0,
      totalCorrect: json['total_correct'] ?? 0,
      averageAccuracy: (json['average_accuracy'] ?? 0.0).toDouble(),
      averageTimePerQuestion: (json['average_time_per_question'] ?? 0.0).toDouble(),
      favoriteOperation: json['favorite_operation'] ?? '',
      weakestOperation: json['weakest_operation'] ?? '',
      dailyActivity: json['daily_activity'] != null
          ? Map<String, int>.from(jsonDecode(json['daily_activity'] is String ? json['daily_activity'] : jsonEncode(json['daily_activity'])))
          : {},
      operationAccuracy: json['operation_accuracy'] != null
          ? Map<String, double>.from(jsonDecode(json['operation_accuracy'] is String ? json['operation_accuracy'] : jsonEncode(json['operation_accuracy'])).map((k, v) => MapEntry(k, (v as num).toDouble())))
          : {},
      levelAccuracy: json['level_accuracy'] != null
          ? Map<int, double>.from(jsonDecode(json['level_accuracy'] is String ? json['level_accuracy'] : jsonEncode(json['level_accuracy'])).map((k, v) => MapEntry(int.parse(k), (v as num).toDouble())))
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_solved': totalSolved,
      'total_correct': totalCorrect,
      'average_accuracy': averageAccuracy,
      'average_time_per_question': averageTimePerQuestion,
      'favorite_operation': favoriteOperation,
      'weakest_operation': weakestOperation,
      'daily_activity': dailyActivity,
      'operation_accuracy': operationAccuracy,
      'level_accuracy': levelAccuracy.map((k, v) => MapEntry(k.toString(), v)),
    };
  }
} 