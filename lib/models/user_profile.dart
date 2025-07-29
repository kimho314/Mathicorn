import 'math_problem.dart';

class UserProfile {
  final String name;
  final int totalScore;
  final int totalProblems;
  final List<String> collectedStickers;
  final List<MathProblem> wrongProblems;
  final String? profileImageUrl;

  UserProfile({
    required this.name,
    this.totalScore = 0,
    this.totalProblems = 0,
    this.collectedStickers = const [],
    this.wrongProblems = const [],
    this.profileImageUrl,
  });

  UserProfile copyWith({
    String? name,
    int? totalScore,
    int? totalProblems,
    List<String>? collectedStickers,
    List<MathProblem>? wrongProblems,
    String? profileImageUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      totalScore: totalScore ?? this.totalScore,
      totalProblems: totalProblems ?? this.totalProblems,
      collectedStickers: collectedStickers ?? this.collectedStickers,
      wrongProblems: wrongProblems ?? this.wrongProblems,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalScore': totalScore,
      'totalProblems': totalProblems,
      'collectedStickers': collectedStickers,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Friend',
      totalScore: json['totalScore'] ?? 0,
      totalProblems: json['totalProblems'] ?? 0,
      collectedStickers: List<String>.from(json['collectedStickers'] ?? []),
      profileImageUrl: json['profileImageUrl'],
    );
  }
} 