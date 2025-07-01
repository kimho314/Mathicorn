import 'package:flutter/material.dart';
import '../models/statistics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticsProvider extends ChangeNotifier {
  Statistics? _statistics;
  bool _isLoading = false;
  String? _error;

  Statistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // TODO: 실제 데이터 fetch 로직 구현 (API 연동 등)
  Future<void> fetchStatistics(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('statistics')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (response != null && response is Map<String, dynamic>) {
        _statistics = Statistics.fromJson(response);
      } else {
        // 없으면 기본값 생성
        _statistics = Statistics(
          userId: userId,
          totalSolved: 0,
          totalCorrect: 0,
          averageAccuracy: 0.0,
          averageTimePerQuestion: 0.0,
          favoriteOperation: '',
          weakestOperation: '',
          dailyActivity: {},
          operationAccuracy: {},
          levelAccuracy: {},
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 통계 갱신 (문제 제출 시 호출)
  Future<void> updateStatisticsOnSubmit({
    required bool isCorrect,
    required String operation,
    required double timeTaken,
    required String date,
    int? level,
  }) async {
    if (_statistics == null) return;
    // 총 풀이 문제 수 증가
    final newTotalSolved = _statistics!.totalSolved + 1;
    // 정답 수 증가
    final newTotalCorrect = _statistics!.totalCorrect + (isCorrect ? 1 : 0);
    // 평균 정답률
    final newAccuracy = newTotalSolved > 0 ? (newTotalCorrect / newTotalSolved) * 100 : 0.0;
    // 평균 소요 시간
    final newAvgTime = ((
      _statistics!.averageTimePerQuestion * _statistics!.totalSolved + timeTaken
    ) / newTotalSolved);
    // 일별 학습량 갱신
    final newDailyActivity = Map<String, int>.from(_statistics!.dailyActivity);
    newDailyActivity[date] = (newDailyActivity[date] ?? 0) + 1;
    // 연산별 정확도 집계
    final newOperationAccuracy = Map<String, List<int>>.fromEntries(
      _statistics!.operationAccuracy.entries.map((e) => MapEntry(e.key, [((e.value * newTotalSolved) / 100).round(), newTotalSolved])),
    );
    final op = operation;
    if (!newOperationAccuracy.containsKey(op)) {
      newOperationAccuracy[op] = [0, 0];
    }
    newOperationAccuracy[op]![1] += 1; // 시도 수
    if (isCorrect) newOperationAccuracy[op]![0] += 1; // 정답 수
    // 정확도 계산
    final opAccuracy = <String, double>{};
    for (final entry in newOperationAccuracy.entries) {
      opAccuracy[entry.key] = entry.value[1] > 0 ? (entry.value[0] / entry.value[1]) * 100 : 0.0;
    }
    // favorite/weakest operation 계산
    String favoriteOp = opAccuracy.entries.isNotEmpty ?
      opAccuracy.entries.reduce((a, b) => a.value > b.value ? a : b).key : '';
    String weakestOp = opAccuracy.entries.isNotEmpty ?
      opAccuracy.entries.reduce((a, b) => a.value < b.value ? a : b).key : '';

    // 레벨별 정확도 집계 (level 정보는 operation에서 추정, 실제로는 문제 모델에서 받아야 정확)
    final newLevelAccuracy = Map<int, List<int>>.fromEntries(
      _statistics!.levelAccuracy.entries.map((e) => MapEntry(e.key, [((e.value * newTotalSolved) / 100).round(), newTotalSolved])),
    );
    // 레벨별 정확도 집계
    final levelKey = level ?? 1;
    if (!newLevelAccuracy.containsKey(levelKey)) {
      newLevelAccuracy[levelKey] = [0, 0];
    }
    newLevelAccuracy[levelKey]![1] += 1;
    if (isCorrect) newLevelAccuracy[levelKey]![0] += 1;
    final levelAccuracy = <int, double>{};
    for (final entry in newLevelAccuracy.entries) {
      levelAccuracy[entry.key] = entry.value[1] > 0 ? (entry.value[0] / entry.value[1]) * 100 : 0.0;
    }

    _statistics = Statistics(
      userId: _statistics!.userId,
      totalSolved: newTotalSolved,
      totalCorrect: newTotalCorrect,
      averageAccuracy: newAccuracy,
      averageTimePerQuestion: newAvgTime,
      favoriteOperation: favoriteOp,
      weakestOperation: weakestOp,
      dailyActivity: newDailyActivity,
      operationAccuracy: opAccuracy,
      levelAccuracy: levelAccuracy,
    );
    notifyListeners();
    // 서버에 upsert
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('statistics').upsert(_statistics!.toJson());
    } catch (e) {
      // 네트워크 에러 등은 무시하고 로컬만 갱신
    }
  }
} 