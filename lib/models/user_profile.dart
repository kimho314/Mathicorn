import 'math_problem.dart';

class UserProfile {
  final String name;
  final int totalScore;
  final int totalProblems;
  final List<String> collectedStickers;
  final List<MathProblem> wrongProblems;

  UserProfile({
    required this.name,
    this.totalScore = 0,
    this.totalProblems = 0,
    this.collectedStickers = const [],
    this.wrongProblems = const [],
  });

  UserProfile copyWith({
    String? name,
    int? totalScore,
    int? totalProblems,
    List<String>? collectedStickers,
    List<MathProblem>? wrongProblems,
  }) {
    return UserProfile(
      name: name ?? this.name,
      totalScore: totalScore ?? this.totalScore,
      totalProblems: totalProblems ?? this.totalProblems,
      collectedStickers: collectedStickers ?? this.collectedStickers,
      wrongProblems: wrongProblems ?? this.wrongProblems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalScore': totalScore,
      'totalProblems': totalProblems,
      'collectedStickers': collectedStickers,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Friend',
      totalScore: json['totalScore'] ?? 0,
      totalProblems: json['totalProblems'] ?? 0,
      collectedStickers: List<String>.from(json['collectedStickers'] ?? []),
    );
  }
} 