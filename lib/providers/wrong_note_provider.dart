import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wrong_answer.dart';

class WrongNoteProvider extends ChangeNotifier {
  static const String tableName = 'wrong_answers';
  static const int pageSize = 20;
  
  List<WrongAnswer> _wrongAnswers = [];
  bool _hasMoreData = true;
  String? _lastLoadedId;
  bool _isLoading = false;
  
  // 필터 상태
  String? _selectedOperationType;
  DateTime? _fromDate;
  DateTime? _toDate;

  List<WrongAnswer> get wrongAnswers => _wrongAnswers;
  bool get hasMoreData => _hasMoreData;
  bool get isLoading => _isLoading;
  String? get selectedOperationType => _selectedOperationType;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  String? userId;

  // 필터 설정
  void setFilters({
    String? operationType,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    _selectedOperationType = operationType;
    _fromDate = fromDate;
    _toDate = toDate;
    
    // 필터가 변경되면 데이터 새로고침
    refresh();
  }

  // 필터 초기화
  void clearFilters() {
    _selectedOperationType = null;
    _fromDate = null;
    _toDate = null;
    refresh();
  }

  // 초기 데이터 로드 (첫 20개)
  Future<void> loadWrongAnswers() async {
    if (userId == null) {
      print('Debug: userId is null, cannot load wrong answers');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      print('Debug: Loading wrong answers for user: $userId');
      
      // 기본 쿼리 시작
      var query = supabase
          .from(tableName)
          .select()
          .eq('user_id', userId!);
      
      // 필터 적용
      if (_selectedOperationType != null && _selectedOperationType!.isNotEmpty) {
        query = query.eq('operation_type', _selectedOperationType!);
        print('Debug: Filtering by operation_type: $_selectedOperationType');
      }
      
      if (_fromDate != null) {
        query = query.gte('created_at', _fromDate!.toIso8601String());
        print('Debug: Filtering from date: $_fromDate');
      }
      
      if (_toDate != null) {
        query = query.lte('created_at', _toDate!.toIso8601String());
        print('Debug: Filtering to date: $_toDate');
      }
      
      // 정렬 및 제한
      final response = await query
          .order('created_at', ascending: false)
          .limit(pageSize);
      
      print('Debug: Loaded ${response.length} wrong answers');
      
      _wrongAnswers = (response as List)
          .map((e) => WrongAnswer.fromJson(e))
          .toList();
      
      // 마지막 ID 저장 (pagination용)
      if (_wrongAnswers.isNotEmpty) {
        _lastLoadedId = _wrongAnswers.last.id;
        _hasMoreData = _wrongAnswers.length >= pageSize;
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      print('Error loading wrong answers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      notifyListeners();
    }
  }

  // 추가 데이터 로드 (pagination) - 필터 적용
  Future<void> loadMoreWrongAnswers() async {
    if (userId == null || !_hasMoreData || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      
      // 기본 쿼리 시작
      var query = supabase
          .from(tableName)
          .select()
          .eq('user_id', userId!)
          .lt('id', _lastLoadedId!);
      
      // 필터 적용
      if (_selectedOperationType != null && _selectedOperationType!.isNotEmpty) {
        query = query.eq('operation_type', _selectedOperationType!);
      }
      
      if (_fromDate != null) {
        query = query.gte('created_at', _fromDate!.toIso8601String());
      }
      
      if (_toDate != null) {
        query = query.lte('created_at', _toDate!.toIso8601String());
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .limit(pageSize);
      
      final newAnswers = (response as List)
          .map((e) => WrongAnswer.fromJson(e))
          .toList();
      
      _wrongAnswers.addAll(newAnswers);
      
      if (newAnswers.isNotEmpty) {
        _lastLoadedId = newAnswers.last.id;
        _hasMoreData = newAnswers.length >= pageSize;
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      print('Error loading more wrong answers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      notifyListeners();
    }
  }

  // 중복 수식 처리 로직이 포함된 오답 추가
  Future<void> addWrongAnswer(WrongAnswer answer) async {
    if (userId == null) {
      print('Debug: userId is null, cannot add wrong answer');
      return;
    }
    
    print('Debug: Adding wrong answer: ${answer.questionText}');
    print('Debug: User ID: $userId');
    
    try {
      final supabase = Supabase.instance.client;
      
      // 기존에 같은 수식이 있는지 확인
      final existingResponse = await supabase
          .from(tableName)
          .select()
          .eq('user_id', userId!)
          .eq('question_text', answer.questionText)
          .maybeSingle();
      
      if (existingResponse != null) {
        print('Debug: Found existing wrong answer, updating count');
        // 기존 레코드가 있으면 count 증가
        final existingAnswer = WrongAnswer.fromJson(existingResponse);
        await supabase
            .from(tableName)
            .update({
              'count': (existingAnswer.count + 1),
              'user_answer': answer.userAnswer, // 최신 답으로 업데이트
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingAnswer.id);
        print('Debug: Updated existing wrong answer');
      } else {
        print('Debug: Creating new wrong answer record');
        // 새로운 레코드 생성
        final insertData = answer.toJson();
        // 새로운 레코드 생성 시에도 updated_at 설정
        insertData['updated_at'] = DateTime.now().toIso8601String();
        print('Debug: Insert data: $insertData');
        
        final result = await supabase.from(tableName).insert(insertData).select();
        print('Debug: Insert result: $result');
      }
      
      // 데이터 새로고침
      await loadWrongAnswers();
    } catch (e) {
      print('Error adding wrong answer: $e');
      print('Error details: ${e.toString()}');
    }
  }

  Future<void> removeWrongAnswer(String id) async {
    if (userId == null) return;
    
    try {
      final supabase = Supabase.instance.client;
      await supabase.from(tableName)
          .delete()
          .eq('user_id', userId!)
          .eq('id', id);
      await loadWrongAnswers();
    } catch (e) {
      print('Error removing wrong answer: $e');
    }
  }

  Future<void> clearAll() async {
    if (userId == null) return;
    
    try {
      final supabase = Supabase.instance.client;
      await supabase.from(tableName)
          .delete()
          .eq('user_id', userId!);
      
      // 상태 초기화
      _wrongAnswers.clear();
      _hasMoreData = true;
      _lastLoadedId = null;
      notifyListeners();
    } catch (e) {
      print('Error clearing wrong answers: $e');
    }
  }

  // 로컬 필터링 (UI에서 사용)
  List<WrongAnswer> getFilteredAnswers() {
    return _wrongAnswers;
  }

  // 복습 모드: 랜덤/날짜순
  List<WrongAnswer> getForReview({bool random = false}) {
    final list = List<WrongAnswer>.from(_wrongAnswers);
    if (random) {
      list.shuffle();
    } else {
      list.sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
    }
    return list;
  }

  // 주의 문제 강조 (ID 타입 변경)
  Future<void> flagProblem(String problemId, {bool flag = true}) async {
    if (userId == null) return;
    
    try {
      final supabase = Supabase.instance.client;
      await supabase.from(tableName)
          .update({'is_flagged': flag})
          .eq('user_id', userId!)
          .eq('id', problemId);
      await loadWrongAnswers();
    } catch (e) {
      print('Error flagging problem: $e');
    }
  }

  // 상태 설정 헬퍼 메서드
  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  // 데이터 새로고침
  Future<void> refresh() async {
    _wrongAnswers.clear();
    _hasMoreData = true;
    _lastLoadedId = null;
    await loadWrongAnswers();
  }

  // 사용 가능한 operation_type 목록 가져오기
  Future<List<String>> getAvailableOperationTypes() async {
    if (userId == null) return [];
    
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('operation_type')
          .eq('user_id', userId!)
          .not('operation_type', 'is', null);
      
      final types = (response as List)
          .map((e) => e['operation_type'] as String)
          .where((type) => type.isNotEmpty)
          .toSet()
          .toList();
      
      return types..sort();
    } catch (e) {
      print('Error getting operation types: $e');
      return [];
    }
  }
} 