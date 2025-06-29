import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wrong_answer.dart';

class WrongNoteProvider extends ChangeNotifier {
  static const String tableName = 'wrong_answers';
  List<WrongAnswer> _wrongAnswers = [];

  List<WrongAnswer> get wrongAnswers => _wrongAnswers;

  String? userId;

  Future<void> loadWrongAnswers() async {
    if (userId == null) return;
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from(tableName)
        .select()
        .eq('user_id', userId!)
        .order('created_at', ascending: false);
    _wrongAnswers = (response as List)
        .map((e) => WrongAnswer.fromJson({
              'problemId': e['problem_id'],
              'question': e['question'],
              'userAnswer': e['user_answer'],
              'correctAnswer': e['correct_answer'],
              'timestamp': e['created_at'],
              'type': e['type'],
              'level': e['level'],
              'isFlagged': e['is_flagged'] ?? false,
            }))
        .toList();
    notifyListeners();
  }

  Future<void> addWrongAnswer(WrongAnswer answer) async {
    if (userId == null) return;
    final supabase = Supabase.instance.client;
    await supabase.from(tableName).insert({
      'user_id': userId!,
      'problem_id': answer.problemId,
      'question': answer.question,
      'user_answer': answer.userAnswer,
      'correct_answer': answer.correctAnswer,
      'type': answer.type,
      'level': answer.level,
      'is_flagged': answer.isFlagged,
    });
    await loadWrongAnswers();
  }

  Future<void> removeWrongAnswer(String problemId) async {
    if (userId == null) return;
    final supabase = Supabase.instance.client;
    await supabase.from(tableName)
        .delete()
        .eq('user_id', userId!)
        .eq('problem_id', problemId);
    await loadWrongAnswers();
  }

  Future<void> clearAll() async {
    if (userId == null) return;
    final supabase = Supabase.instance.client;
    await supabase.from(tableName)
        .delete()
        .eq('user_id', userId!);
    await loadWrongAnswers();
  }

  // 필터링 기능
  List<WrongAnswer> filter({String? type, int? level, DateTime? from, DateTime? to}) {
    return _wrongAnswers.where((a) {
      if (type != null && a.type != type) return false;
      if (level != null && a.level != level) return false;
      if (from != null && a.timestamp.isBefore(from)) return false;
      if (to != null && a.timestamp.isAfter(to)) return false;
      return true;
    }).toList();
  }

  // 복습 모드: 랜덤/날짜순
  List<WrongAnswer> getForReview({bool random = false}) {
    final list = List<WrongAnswer>.from(_wrongAnswers);
    if (random) {
      list.shuffle();
    } else {
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    return list;
  }

  // 주의 문제 강조
  Future<void> flagProblem(String problemId, {bool flag = true}) async {
    if (userId == null) return;
    final supabase = Supabase.instance.client;
    await supabase.from(tableName)
        .update({'is_flagged': flag})
        .eq('user_id', userId!)
        .eq('problem_id', problemId);
    await loadWrongAnswers();
  }
} 