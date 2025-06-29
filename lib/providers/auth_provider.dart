import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  AuthProvider() {
    _user = Supabase.instance.client.auth.currentUser;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
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
      if (res.user != null) return null;
      return 'Login failed';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
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
      if (res.user != null) {
        // users 테이블에도 정보 저장
        await Supabase.instance.client.from('users').insert({
          'id': res.user!.id,
          'email': email,
          'nickname': nickname,
        });
        return null;
      }
      // 이메일 인증이 필요한 경우
      if (res.session == null && res.user == null) {
        return 'Check your email to confirm your account!';
      }
      return 'Sign up failed';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Sign up failed';
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
} 