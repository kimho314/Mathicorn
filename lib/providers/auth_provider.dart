import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Mathicorn/models/user_profile.dart';
import 'dart:convert';
import 'package:Mathicorn/models/user_settings.dart';
import 'package:Mathicorn/providers/wrong_note_provider.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  WrongNoteProvider? _wrongNoteProvider;

  AuthProvider() {
    _user = Supabase.instance.client.auth.currentUser;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      _updateWrongNoteProvider();
      notifyListeners();
    });
  }

  // WrongNoteProvider 참조 설정
  void setWrongNoteProvider(WrongNoteProvider provider) {
    _wrongNoteProvider = provider;
    _updateWrongNoteProvider();
  }

  // WrongNoteProvider의 userId 업데이트
  void _updateWrongNoteProvider() {
    if (_wrongNoteProvider != null) {
      _wrongNoteProvider!.userId = _user?.id;
      print('Debug: Updated WrongNoteProvider userId to: ${_user?.id}');
    }
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  String get nickname {
    final meta = _user?.userMetadata;
    final nick = meta?['nickname']?.toString().trim();
    if (nick != null && nick.isNotEmpty) return nick;
    final email = _user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@')[0];
    }
    return 'Guest';
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      print('[Supabase Login Result] user: ${res.user}, session: ${res.session}');
      if (res.user != null) {
        _updateWrongNoteProvider();
        return null;
      }
      return 'Login failed';
    } on AuthException catch (e) {
      print('[Supabase Login AuthException] ${e.message}');
      return e.message;
    } catch (e) {
      print('[Supabase Login Exception] ${e.toString()}');
      return 'Login failed';
    }
  }

  Future<String?> signUp(String email, String password, String nickname) async {
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'nickname': nickname},
      );
      print('[Supabase SignUp Result] user: ${res.user}, session: ${res.session}');
      if (res.user != null) {
        // users 테이블에도 정보 저장
        await Supabase.instance.client.from('users').insert({
          'id': res.user!.id,
          'email': email,
          'nickname': nickname,
        });
        _updateWrongNoteProvider();
        return null;
      }
      // 이메일 인증이 필요한 경우
      if (res.session == null && res.user == null) {
        return 'Check your email to confirm your account!';
      }
      return 'Sign up failed';
    } on AuthException catch (e) {
      print('[Supabase SignUp AuthException] ${e.message}');
      return e.message;
    } catch (e) {
      print('[Supabase SignUp Exception] ${e.toString()}');
      return 'Sign up failed';
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    _updateWrongNoteProvider();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('No logged in user');
    await Supabase.instance.client.from('user_profiles').upsert({
      'id': user.id,
      'name': profile.name,
      'total_score': profile.totalScore,
      'total_problems': profile.totalProblems,
      'collected_stickers': jsonEncode(profile.collectedStickers),
    });
  }

  Future<UserProfile?> fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('No logged in user');
    final res = await Supabase.instance.client
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle(); // 변경: .single() -> .maybeSingle() (row 없을 때 null 반환)
    if (res == null) {
      // row가 없으면 기본 프로필 생성 및 저장
      final defaultProfile = UserProfile(
        name: nickname,
        totalScore: 0,
        totalProblems: 0,
        collectedStickers: [],
      );
      await saveUserProfile(defaultProfile);
      return defaultProfile;
    }
    // collected_stickers는 jsonb이므로 List<String>으로 변환
    final stickers = (res['collected_stickers'] is String)
        ? List<String>.from(jsonDecode(res['collected_stickers']))
        : List<String>.from(res['collected_stickers'] ?? []);
    return UserProfile(
      name: res['name'] ?? 'Friend',
      totalScore: res['total_score'] ?? 0,
      totalProblems: res['total_problems'] ?? 0,
      collectedStickers: stickers,
    );
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('No logged in user');
    await Supabase.instance.client.from('user_settings').upsert({
      'id': user.id,
      'sound_enabled': settings.soundEnabled,
      'language': settings.language,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<UserSettings> fetchUserSettings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('No logged in user');
    final res = await Supabase.instance.client
        .from('user_settings')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (res == null) {
      // row가 없으면 기본 세팅 생성 및 저장
      final defaultSettings = UserSettings(soundEnabled: true, language: 'en');
      await saveUserSettings(defaultSettings);
      return defaultSettings;
    }
    return UserSettings.fromJson(res);
  }

  Future<void> addStickerToCollection(String stickerName) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('No logged in user');
    
    // 현재 프로필 가져오기
    final currentProfile = await fetchUserProfile();
    if (currentProfile == null) throw Exception('Failed to fetch user profile');
    
    // 이미 수집된 스티커인지 확인
    if (currentProfile.collectedStickers.contains(stickerName)) {
      print('Sticker $stickerName already collected');
      return;
    }
    
    // 새로운 스티커 추가
    final updatedStickers = List<String>.from(currentProfile.collectedStickers)..add(stickerName);
    final updatedProfile = currentProfile.copyWith(collectedStickers: updatedStickers);
    
    // Supabase에 저장
    await saveUserProfile(updatedProfile);
    print('Sticker $stickerName added to collection');
  }

  Future<List<String>> getCollectedStickers() async {
    final profile = await fetchUserProfile();
    return profile?.collectedStickers ?? [];
  }
} 