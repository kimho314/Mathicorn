import 'package:flutter/material.dart';
import '../models/statistics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticsProvider extends ChangeNotifier {
  Statistics? _statistics;
  bool _isLoading = false;
  String? _error;
  int _retryCount = 0;
  static const int _maxRetries = 2;

  Statistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // TODO: 실제 데이터 fetch 로직 구현 (API 연동 등)
  Future<void> fetchStatistics(String userId) async {
    _isLoading = true;
    _error = null;
    _retryCount = 0;
    notifyListeners();
    
    while (_retryCount <= _maxRetries) {
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
        _isLoading = false;
        _retryCount = 0; // 성공 시 재시도 카운트 리셋
        notifyListeners();
        return; // 성공 시 함수 종료
      } catch (e) {
        _retryCount++;
        if (_retryCount <= _maxRetries) {
          // 1초 대기 후 재시도
          await Future.delayed(const Duration(seconds: 1));
        } else {
          // 최대 재시도 횟수 초과
          _error = 'Network Error';
          _isLoading = false;
          notifyListeners();
          _triggerNetworkErrorDialog();
          return;
        }
      }
    }
  }

  void _showNetworkErrorDialog() {
    // BuildContext가 필요하므로 별도 메서드로 분리
    // 실제 다이얼로그는 StatisticsScreen에서 처리
  }

  // 네트워크 에러 다이얼로그 표시를 위한 콜백
  Function()? _onNetworkError;

  void setNetworkErrorCallback(Function() callback) {
    _onNetworkError = callback;
  }

  void _triggerNetworkErrorDialog() {
    if (_onNetworkError != null) {
      _onNetworkError!();
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
    print('[DEBUG] Statistics before upsert (on submit): \\${_statistics!.toJson()}');
    notifyListeners();
    // 서버에 upsert
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase.from('statistics').upsert(_statistics!.toJson());
      print('[STATISTICS upsert on submit] response: \\${res}');
    } catch (e) {
      print('[STATISTICS upsert on submit ERROR] \\${e.toString()}');
    }
  }

  // 현재 statistics를 Supabase에 upsert
  Future<void> upsertStatistics() async {
    if (_statistics == null) return;
    print('[DEBUG] Statistics before upsert (manual): \\${_statistics!.toJson()}');
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase.from('statistics').upsert(_statistics!.toJson());
      print('[STATISTICS upsert] response: \\${res}');
    } catch (e) {
      print('[STATISTICS upsert ERROR] \\${e.toString()}');
    }
  }

  // 통계 객체를 명시적으로 초기화
  void initializeStatistics(String userId) {
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
    notifyListeners();
  }
} 