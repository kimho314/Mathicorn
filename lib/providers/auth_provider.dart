import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Mathicorn/models/user_profile.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:Mathicorn/models/user_settings.dart';
import 'package:Mathicorn/providers/wrong_note_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' if (dart.library.io) 'dart:io' as html;
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'dart:io' as dart_io;

class AuthProvider with ChangeNotifier {
  User? _user;
  WrongNoteProvider? _wrongNoteProvider;
  int _retryCount = 0;
  static const int _maxRetries = 2;



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
    // userMetadata에서 nickname을 먼저 확인 (기존 호환성)
    final meta = _user?.userMetadata;
    final nick = meta?['nickname']?.toString().trim();
    if (nick != null && nick.isNotEmpty) return nick;
    
    // users 테이블에서 nickname을 가져오는 것은 비동기 작업이므로
    // 여기서는 기본값을 반환하고, 실제 데이터는 fetchUserProfile에서 처리
    final email = _user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@')[0];
    }
    return 'Guest';
  }

  Future<String?> signIn(String email, String password) async {
    _retryCount = 0;
    
    while (_retryCount <= _maxRetries) {
      try {
        final res = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
        print('[Supabase Login Result] user: ${res.user}, session: ${res.session}');
        if (res.user != null) {
          _updateWrongNoteProvider();
          _retryCount = 0; // 성공 시 재시도 카운트 리셋
          return null;
        }
        return 'Login failed';
      } on AuthException catch (e) {
        print('[Supabase Login AuthException] ${e.message}');
        // 네트워크 관련 에러인지 확인
        if (e.message.contains('SocketException') || 
            e.message.contains('Failed host lookup') ||
            e.message.contains('No address associated with hostname') ||
            e.message.contains('Connection refused') ||
            e.message.contains('Network is unreachable')) {
          _retryCount++;
          print('[Supabase Login Network AuthException] attempt $_retryCount: ${e.toString()}');
          if (_retryCount <= _maxRetries) {
            // 1초 대기 후 재시도
            await Future.delayed(const Duration(seconds: 1));
            continue; // while 루프의 다음 반복으로
          } else {
            // 최대 재시도 횟수 초과
            print('Max retries reached for login (AuthException)');
            return 'Network Error';
          }
        }
        return e.message;
      } catch (e) {
        _retryCount++;
        print('[Supabase Login Exception] attempt $_retryCount: ${e.toString()}');
        if (_retryCount <= _maxRetries) {
          // 1초 대기 후 재시도
          await Future.delayed(const Duration(seconds: 1));
        } else {
          // 최대 재시도 횟수 초과
          print('Max retries reached for login');
          return 'Network Error';
        }
      }
    }
    return 'Network Error';
  }

  Future<String?> signUp(String email, String password, String nickname) async {
    _retryCount = 0;
    
    while (_retryCount <= _maxRetries) {
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
          _retryCount = 0; // 성공 시 재시도 카운트 리셋
          return null;
        }
        // 이메일 인증이 필요한 경우
        if (res.session == null && res.user == null) {
          return 'Check your email to confirm your account!';
        }
        return 'Sign up failed';
      } on AuthException catch (e) {
        print('[Supabase SignUp AuthException] ${e.message}');
        // 네트워크 관련 에러인지 확인
        if (e.message.contains('SocketException') || 
            e.message.contains('Failed host lookup') ||
            e.message.contains('No address associated with hostname') ||
            e.message.contains('Connection refused') ||
            e.message.contains('Network is unreachable')) {
          _retryCount++;
          print('[Supabase SignUp Network AuthException] attempt $_retryCount: ${e.toString()}');
          if (_retryCount <= _maxRetries) {
            // 1초 대기 후 재시도
            await Future.delayed(const Duration(seconds: 1));
            continue; // while 루프의 다음 반복으로
          } else {
            // 최대 재시도 횟수 초과
            print('Max retries reached for signup (AuthException)');
            return 'Network Error';
          }
        }
        return e.message;
      } catch (e) {
        _retryCount++;
        print('[Supabase SignUp Exception] attempt $_retryCount: ${e.toString()}');
        if (_retryCount <= _maxRetries) {
          // 1초 대기 후 재시도
          await Future.delayed(const Duration(seconds: 1));
        } else {
          // 최대 재시도 횟수 초과
          print('Max retries reached for signup');
          return 'Network Error';
        }
      }
    }
    return 'Network Error';
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Network error during sign out: $e');
      // 네트워크 에러가 발생해도 로컬에서 로그아웃 처리
    }
    // 로컬 상태 초기화
    _user = null;
    _updateWrongNoteProvider();
    notifyListeners();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No logged in user');
      
      print('Debug: Saving user profile for user ${user.id}');
      print('Debug: Profile data - name: ${profile.name}, score: ${profile.totalScore}, problems: ${profile.totalProblems}');
      print('Debug: Profile image URL: ${profile.profileImageUrl}');
      
      // user_profiles 테이블에 저장 (name은 users.nickname에서 관리)
      await Supabase.instance.client.from('user_profiles').upsert({
        'id': user.id,
        'total_score': profile.totalScore,
        'total_problems': profile.totalProblems,
        'collected_stickers': jsonEncode(profile.collectedStickers),
        'profile_image_url': profile.profileImageUrl,
      });
      
      // users 테이블의 nickname 업데이트 (email 포함)
      await Supabase.instance.client.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'nickname': profile.name,
      });
      
      print('Debug: User profile saved successfully');
      
      // UI 업데이트를 위해 리스너들에게 알림
      notifyListeners();
    } catch (e) {
      print('Error saving user profile: $e');
      throw Exception('Failed to save user profile: $e');
    }
  }

  Future<UserProfile?> fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No logged in user');
      
      print('Debug: Fetching user profile for user ${user.id}');
      
      // user_profiles 테이블에서 프로필 정보 가져오기
      final profileRes = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      // users 테이블에서 nickname 가져오기
      final userRes = await Supabase.instance.client
          .from('users')
          .select('nickname')
          .eq('id', user.id)
          .maybeSingle();
      
      print('Debug: Profile response: $profileRes');
      print('Debug: User response: $userRes');
      
      if (profileRes == null) {
        // row가 없으면 기본 프로필 생성 및 저장
        print('Debug: No profile found, creating default profile');
        final defaultProfile = UserProfile(
          name: userRes?['nickname'] ?? nickname,
          totalScore: 0,
          totalProblems: 0,
          collectedStickers: [],
        );
        await saveUserProfile(defaultProfile);
        return defaultProfile;
      }
      
      // collected_stickers는 jsonb이므로 List<String>으로 변환
      final stickers = (profileRes['collected_stickers'] is String)
          ? List<String>.from(jsonDecode(profileRes['collected_stickers']))
          : List<String>.from(profileRes['collected_stickers'] ?? []);
      
      final profile = UserProfile(
        name: userRes?['nickname'] ?? nickname,
        totalScore: profileRes['total_score'] ?? 0,
        totalProblems: profileRes['total_problems'] ?? 0,
        collectedStickers: stickers,
        profileImageUrl: profileRes['profile_image_url'],
      );
      
      print('Debug: Profile loaded successfully - name: ${profile.name}, image: ${profile.profileImageUrl}');
      return profile;
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
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

  // 닉네임만 업데이트하는 메서드
  Future<void> updateNickname(String newNickname) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No logged in user');
      
      print('Debug: Updating nickname for user ${user.id} to: $newNickname');
      
      // users 테이블의 nickname 업데이트 (email 포함)
      await Supabase.instance.client.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'nickname': newNickname,
      });
      
      print('Debug: Nickname updated successfully');
      
      // UI 업데이트를 위해 리스너들에게 알림
      notifyListeners();
    } catch (e) {
      print('Error updating nickname: $e');
      throw Exception('Failed to update nickname: $e');
    }
  }

  // 이미지 선택 및 업로드 메서드들
  Future<dynamic> pickImage({bool fromCamera = false}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image != null) {
      // Web과 Mobile 모두에서 XFile을 그대로 사용
      return image;
    }
    return null;
  }

  Future<String?> uploadProfileImage(dynamic imageFile) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No logged in user');

      print('Debug: Starting image upload for user ${user.id}');
      print('Debug: Image file type: ${imageFile.runtimeType}');
      print('Debug: Image file: $imageFile');

             // Check if avatars bucket exists
       await _ensureAvatarsBucketExists();

      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${user.id}/$fileName';

      print('Debug: Uploading to path: $filePath');

      // XFile에서 바이트 데이터 읽기
      Uint8List imageBytes;
      if (imageFile is XFile) {
        try {
          print('Debug: Processing XFile: ${imageFile.path}');
          imageBytes = await imageFile.readAsBytes();
          print('Debug: Read ${imageBytes.length} bytes from XFile');
        } catch (readError) {
          print('Debug: Error reading XFile: $readError');
          throw Exception('Failed to read image file: $readError');
        }
      } else if (imageFile is Uint8List) {
        print('Debug: Processing Uint8List directly');
        imageBytes = imageFile;
        print('Debug: Using Uint8List with ${imageBytes.length} bytes');
      } else {
        throw Exception('Unsupported image file type: ${imageFile.runtimeType}');
      }

      // Validate image bytes
      if (imageBytes.isEmpty) {
        throw Exception('Image file is empty');
      }

      print('Debug: Image bytes length: ${imageBytes.length}');
      print('Debug: File path: $filePath');
      
      // Create proper File objects for upload
      if (kIsWeb) {
        print('Debug: Running on web, creating File from Blob');
        try {
          // Create a Blob and then a File from it
          final blob = html.Blob([imageBytes], 'image/jpeg');
          final file = html.File([blob], fileName);
          
          print('Debug: Uploading File object to Supabase Storage...');
          await Supabase.instance.client.storage
              .from('avatars')
              .upload(filePath, file);
          print('Debug: Image uploaded successfully with File object (web)');
        } catch (webError) {
          print('Debug: Web File upload failed: $webError');
          
          // Try with uploadBinary as fallback
          try {
            print('Debug: Trying uploadBinary as fallback...');
            await Supabase.instance.client.storage
                .from('avatars')
                .uploadBinary(filePath, imageBytes);
            print('Debug: Image uploaded successfully with uploadBinary (web)');
          } catch (binaryError) {
            print('Debug: uploadBinary also failed: $binaryError');
            throw Exception('All web upload methods failed: $binaryError');
          }
        }
             } else {
         print('Debug: Running on mobile, using uploadBinary method');
         try {
           // For mobile, use uploadBinary directly
           await Supabase.instance.client.storage
               .from('avatars')
               .uploadBinary(filePath, imageBytes);
           print('Debug: Image uploaded successfully with uploadBinary (mobile)');
         } catch (mobileError) {
           print('Debug: Mobile uploadBinary failed: $mobileError');
           
           // Try with regular upload as fallback
           try {
             print('Debug: Trying regular upload as fallback...');
             await Supabase.instance.client.storage
                 .from('avatars')
                 .upload(filePath, imageBytes);
             print('Debug: Image uploaded successfully with regular upload (mobile)');
           } catch (fallbackError) {
             print('Debug: Regular upload also failed: $fallbackError');
             throw Exception('All mobile upload methods failed: $fallbackError');
           }
         }
       }

      // 공개 URL 가져오기
      print('Debug: Getting public URL...');
      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      print('Debug: Generated public URL: $imageUrl');
      print('Debug: URL type: ${imageUrl.runtimeType}');
      return imageUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      print('Error stack trace: ${StackTrace.current}');
      return null;
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    try {
      print('Debug: Starting profile image update with URL: $imageUrl');
      print('Debug: Image URL type: ${imageUrl.runtimeType}');
      
      final currentProfile = await fetchUserProfile();
      if (currentProfile == null) throw Exception('Failed to fetch user profile');

      print('Debug: Current profile - name: ${currentProfile.name}, image: ${currentProfile.profileImageUrl}');
      
      final updatedProfile = currentProfile.copyWith(profileImageUrl: imageUrl);
      print('Debug: Updated profile - name: ${updatedProfile.name}, image: ${updatedProfile.profileImageUrl}');
      
      await saveUserProfile(updatedProfile);
      print('Debug: Profile image updated successfully');
      
      notifyListeners();
    } catch (e) {
      print('Error updating profile image: $e');
      print('Error stack trace: ${StackTrace.current}');
      throw Exception('Failed to update profile image: $e');
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      final currentProfile = await fetchUserProfile();
      if (currentProfile == null) throw Exception('Failed to fetch user profile');

      // 기존 이미지가 있으면 Storage에서 삭제
      if (currentProfile.profileImageUrl != null && !currentProfile.profileImageUrl!.startsWith('file://')) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          try {
            // URL에서 파일 경로 추출
            final urlParts = currentProfile.profileImageUrl!.split('/');
            final fileName = urlParts.last;
            final filePath = '${user.id}/$fileName';
            
            await Supabase.instance.client.storage
                .from('avatars')
                .remove([filePath]);
          } catch (e) {
            print('Error deleting old image from storage: $e');
          }
        }
      }

      // 프로필에서 이미지 URL 제거
      final updatedProfile = currentProfile.copyWith(profileImageUrl: null);
      await saveUserProfile(updatedProfile);
      
      notifyListeners();
    } catch (e) {
      print('Error deleting profile image: $e');
      throw Exception('Failed to delete profile image: $e');
    }
  }

  // Ensure avatars bucket exists
  Future<void> _ensureAvatarsBucketExists() async {
    try {
      print('Debug: Checking if avatars bucket exists...');
      final buckets = await Supabase.instance.client.storage.listBuckets();
      print('Debug: Available buckets: ${buckets.map((b) => b.name).toList()}');
      
      final avatarsBucket = buckets.where((b) => b.name == 'avatars').firstOrNull;
      if (avatarsBucket == null) {
        print('Debug: Avatars bucket not found, attempting to create...');
        // Note: Bucket creation typically requires admin privileges
        // This is just for debugging - the bucket should be created manually
        throw Exception('Avatars bucket not found. Please create it manually in the Supabase dashboard.');
      }
      print('Debug: Avatars bucket found: ${avatarsBucket.name}');
    } catch (e) {
      print('Debug: Error checking/creating avatars bucket: $e');
      // Continue anyway, as the bucket might exist but not be listable
    }
  }
} 