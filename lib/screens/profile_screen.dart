import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import 'package:Mathicorn/models/user_profile.dart';
import 'package:Mathicorn/providers/auth_provider.dart';
import 'package:Mathicorn/screens/main_shell.dart';
import '../utils/unicorn_theme.dart';

import 'package:flutter/foundation.dart';
import 'dart:ui';

import 'dart:io' as io;

// Helper function to create File object safely
dynamic createFileObject(String path) {
  if (kIsWeb) {
    return null; // Web doesn't need File object
  } else {
    try {
      // Create File object for mobile platforms
      return io.File(path);
    } catch (e) {
      print('Error creating File object: $e');
      return null;
    }
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  bool _isEditing = false;
  UserProfile? _userProfile;
  bool _loading = false;
  String? _error;
  int _retryCount = 0;
  static const int _maxRetries = 2;
  bool _isUploadingImage = false;
  dynamic _selectedImageFile; // 선택된 이미지 파일 임시 저장
  Uint8List? _selectedImageBytes; // 선택된 이미지의 바이트 데이터 (웹용)
  bool _isSavingProfile = false; // 프로필 저장 중 상태
  late AnimationController _skeletonAnimationController;
  late Animation<double> _skeletonAnimation;

  @override
  void initState() {
    super.initState();
    
    // 스켈레톤 애니메이션 초기화
    _skeletonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _skeletonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _skeletonAnimationController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserProfileFromSupabase();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 표시될 때마다 최신 프로필 로드
    _fetchUserProfileFromSupabase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skeletonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfileFromSupabase() async {
    print('Debug: Starting _fetchUserProfileFromSupabase');
    setState(() { _loading = true; _error = null; });
    
    // 스켈레톤 애니메이션 시작
    _skeletonAnimationController.repeat();
    
    while (_retryCount <= _maxRetries) {
      try {
        final auth = context.read<AuthProvider>();
        final profile = await auth.fetchUserProfile();
        
        print('Debug: Fetched profile - name: ${profile?.name}');
        
        setState(() {
          _userProfile = profile;
          _nameController.text = profile?.name ?? '';
          _loading = false;
          _retryCount = 0; // 성공 시 재시도 카운트 리셋
        });
        
        // 스켈레톤 애니메이션 중지
        _skeletonAnimationController.stop();
        
        print('Debug: Profile state updated - _userProfile?.name: ${_userProfile?.name}');
        print('Debug: Triggering rebuild...');
        return; // 성공 시 함수 종료
      } catch (e) {
        print('Debug: Error fetching profile: $e');
        _retryCount++;
        if (_retryCount <= _maxRetries) {
          // 2초 대기 후 재시도
          await Future.delayed(const Duration(seconds: 2));
        } else {
          // 최대 재시도 횟수 초과
          setState(() {
            _error = 'Network Error';
            _loading = false;
          });
          
          // 스켈레톤 애니메이션 중지
          _skeletonAnimationController.stop();
          
          _showNetworkErrorDialog();
          return;
        }
      }
    }
  }

  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Network Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load profile data.\nPlease check your internet connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    MainShell.setTabIndex?.call(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black.withOpacity(0.1),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
        ),
        actions: [
                     IconButton(
             onPressed: _isSavingProfile ? null : () {
               setState(() {
                 _isEditing = !_isEditing;
                 if (!_isEditing) {
                   _saveProfile();
                 }
               });
             },
             icon: _isSavingProfile 
                 ? const SizedBox(
                     width: 20,
                     height: 20,
                     child: CircularProgressIndicator(
                       strokeWidth: 2,
                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                     ),
                   )
                 : Icon(_isEditing ? Icons.save : Icons.edit),
           ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await context.read<AuthProvider>().signOut();
              } catch (e) {
                print('Error during logout: $e');
              }
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                MainShell.setTabIndex?.call(0);
              }
            },
          ),
        ],
      ),
      body: Material(
        color: Colors.transparent,
        child: Container(
          decoration: UnicornDecorations.appBackground,
          child: _loading
              ? _buildSkeletonUI()
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // 프로필 카드
                          _buildProfileCard(_userProfile),
                          const SizedBox(height: 24),
                          // 통계 카드
                          _buildStatsCard(_userProfile),
                          const SizedBox(height: 24),
                          // 스티커 갤러리
                          _buildStickerGallery(_userProfile),
                          const SizedBox(height: 20), // 하단 여백 추가
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile? userProfile) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
                             CircleAvatar(
                 radius: 50,
                 backgroundColor: const Color(0xFFF8FAFC),
                                   backgroundImage: _selectedImageFile != null
                      ? (kIsWeb 
                          ? (_selectedImageBytes != null 
                              ? MemoryImage(_selectedImageBytes!) as ImageProvider
                              : null)
                          : FileImage(createFileObject(_selectedImageFile.path)) as ImageProvider)
                      : (_userProfile?.profileImageUrl != null
                         ? (_userProfile!.profileImageUrl!.startsWith('file://')
                             ? null // 로컬 파일은 Web에서 표시하지 않음
                             : (() {
                                 try {
                                   print('Debug: Creating NetworkImage with URL: ${_userProfile!.profileImageUrl}');
                                   return NetworkImage(_userProfile!.profileImageUrl!) as ImageProvider;
                                 } catch (e) {
                                   print('Debug: Error creating NetworkImage: $e');
                                   return null;
                                 }
                               })())
                         : null),
                 child: (_userProfile?.profileImageUrl == null && _selectedImageFile == null)
                     ? Text(
                         (_userProfile?.name ?? auth.nickname).substring(0, 1).toUpperCase(),
                         style: const TextStyle(
                           fontSize: 40,
                           fontWeight: FontWeight.bold,
                           color: Color(0xFF8B5CF6),
                         ),
                       )
                     : null,
               ),
                             if (_isEditing)
                 Positioned(
                   bottom: 0,
                   right: 0,
                   child: Container(
                                           decoration: BoxDecoration(
                        color: _selectedImageFile != null 
                            ? const Color(0xFF8B5CF6).withOpacity(0.9)
                            : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                     child: IconButton(
                       icon: _isUploadingImage
                           ? const SizedBox(
                               width: 20,
                               height: 20,
                               child: CircularProgressIndicator(
                                 strokeWidth: 2,
                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                               ),
                             )
                           : Icon(
                               _selectedImageFile != null 
                                   ? Icons.check 
                                   : Icons.camera_alt,
                               color: Colors.white,
                               size: 20,
                             ),
                       onPressed: _isUploadingImage ? null : _showImagePickerDialog,
                     ),
                   ),
                 ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditing) ...[
                         Container(
                               decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
               child: TextField(
                 controller: _nameController,
                 decoration: const InputDecoration(
                   labelText: 'Nickname',
                   labelStyle: TextStyle(
                     color: Colors.white70,
                     fontSize: 16,
                     fontWeight: FontWeight.w500,
                   ),
                   border: InputBorder.none,
                   contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                 ),
                 textAlign: TextAlign.center,
                 style: const TextStyle(
                   fontSize: 18,
                   color: Colors.white,
                   fontWeight: FontWeight.w500,
                 ),
               ),
             ),
            const SizedBox(height: 16),
          ] else ...[
            Builder(
              builder: (context) {
                final displayName = _userProfile?.name ?? auth.nickname;
                print('Debug: Displaying nickname in profile card: $displayName');
                print('Debug: _userProfile?.name: ${_userProfile?.name}');
                print('Debug: auth.nickname: ${auth.nickname}');
                return Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCard(UserProfile? userProfile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Learning Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
            ),
          ),
          const SizedBox(height: 16),
          if (userProfile != null) ...[
            Row(
              children: [
                Flexible(
                  child: Text('Total Score:', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('${userProfile.totalScore}', style: TextStyle(color: Color(0xFFFDE047), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text('Total Problems:', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('${userProfile.totalProblems}', style: TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStickerGallery(UserProfile? userProfile) {
    final stickers = userProfile?.collectedStickers ?? [];
    
    return Container(
      height: 300, // 고정 높이 설정
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎖️ Collected Stickers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
            ),
          ),
          const SizedBox(height: 16),
          if (stickers.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_emotions_outlined, size: 64, color: Colors.white70),
                    SizedBox(height: 16),
                    Text(
                      'No stickers collected yet!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Get 100 points to collect stickers!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: stickers.length,
                itemBuilder: (context, index) {
                  final stickerName = stickers[index];
                  final imagePath = _getStickerImagePath(stickerName);
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imagePath != null
                          ? Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.emoji_emotions,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String? _getStickerImagePath(String stickerName) {
    switch (stickerName) {
      case 'lv1_sticker':
        return 'assets/images/lv1.png';
      case 'lv2_sticker':
        return 'assets/images/lv2.png';
      case 'lv3_sticker':
        return 'assets/images/lv3.png';
      case 'lv4_sticker':
        return 'assets/images/lv4.png';
      case 'lv5_sticker':
        return 'assets/images/lv5.png';
      case 'lv6_sticker':
        return 'assets/images/lv6.png';
      case 'lv7_sticker':
        return 'assets/images/lv7.png';
      case 'lv8_sticker':
        return 'assets/images/lv8.png';
      case 'lv9_sticker':
        return 'assets/images/lv9.png';
      case 'lv10_sticker':
        return 'assets/images/lv10.png';
      case 'lv11_sticker':
        return 'assets/images/lv11.png';
      case 'lv12_sticker':
        return 'assets/images/lv12.png';
      default:
        return null;
    }
  }

         void _saveProfile() async {
     try {
       setState(() {
         _isSavingProfile = true;
       });
       
       final authProvider = context.read<AuthProvider>();
       final gameProvider = context.read<GameProvider>();
       
       final newNickname = _nameController.text.trim();
       
       print('Debug: Saving profile with new nickname: $newNickname');
      
      // 선택된 이미지가 있으면 업로드
      if (_selectedImageFile != null) {
        print('Debug: Uploading selected image...');
        setState(() {
          _isUploadingImage = true;
        });
        
                 try {
                       final imageUrl = await authProvider.uploadProfileImage(
              kIsWeb ? _selectedImageFile : createFileObject(_selectedImageFile.path)
            );
          if (imageUrl != null) {
            print('Debug: Image uploaded successfully, updating profile');
            await authProvider.updateProfileImage(imageUrl);
            setState(() {
              _selectedImageFile = null; // 업로드 완료 후 초기화
              _selectedImageBytes = null; // 이미지 바이트도 초기화
            });
          } else {
            print('Debug: Image upload failed');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to upload image. Please try again.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return; // 이미지 업로드 실패 시 저장 중단
          }
        } catch (e) {
          print('Error uploading image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return; // 이미지 업로드 실패 시 저장 중단
        } finally {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }
      
      // 닉네임 업데이트 (users 테이블)
      await authProvider.updateNickname(newNickname);
      
      print('Debug: Nickname updated in database');
      
      // 로컬 GameProvider도 업데이트
      gameProvider.setUserProfile(newNickname);
      
      print('Debug: GameProvider updated');
      
      // UI 업데이트를 위해 프로필 새로고침
      await _fetchUserProfileFromSupabase();
      
             print('Debug: Profile refreshed from database');
       print('Debug: Current _userProfile?.name: ${_userProfile?.name}');
       
       // 프로필 저장 완료 다이얼로그 표시
       if (mounted) {
         _showProfileSavedDialog();
       }
     } catch (e) {
       print('Error saving profile: $e');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Failed to save profile: ${e.toString()}'),
             backgroundColor: Colors.red,
           ),
         );
       }
     } finally {
       if (mounted) {
         setState(() {
           _isSavingProfile = false;
         });
       }
     }
   }

  // 이미지 선택 메서드 (업로드는 저장 시에만)
  Future<void> _pickImage({bool fromCamera = false}) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      print('Debug: Starting image pick process');
      final authProvider = context.read<AuthProvider>();
      final imageFile = await authProvider.pickImage(fromCamera: fromCamera);
      
                   if (imageFile != null) {
        print('Debug: Image picked successfully, type: ${imageFile.runtimeType}');
        
        // Load image bytes for web preview
        Uint8List? imageBytes;
        if (kIsWeb) {
          try {
            imageBytes = await imageFile.readAsBytes();
            print('Debug: Image bytes loaded for web preview');
          } catch (e) {
            print('Debug: Error loading image bytes: $e');
          }
        }
        
        setState(() {
          _selectedImageFile = imageFile;
          _selectedImageBytes = imageBytes;
        });
      } else {
        print('Debug: No image selected');
      }
    } catch (e) {
      print('Error in _pickImage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.deleteProfileImage();
      setState(() {
        _selectedImageFile = null; // 선택된 이미지도 초기화
        _selectedImageBytes = null; // 이미지 바이트도 초기화
      });
      await _fetchUserProfileFromSupabase(); // 프로필 새로고침
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image deleted successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image deletion failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Select Profile Image',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                         ListTile(
               leading: const Icon(Icons.camera_alt, color: Color(0xFF8B5CF6)),
               title: const Text('Take Photo'),
               onTap: () {
                 Navigator.pop(context);
                 _pickImage(fromCamera: true);
               },
             ),
             ListTile(
               leading: const Icon(Icons.photo_library, color: Color(0xFF8B5CF6)),
               title: const Text('Choose from Gallery'),
               onTap: () {
                 Navigator.pop(context);
                 _pickImage(fromCamera: false);
               },
             ),
            if (_userProfile?.profileImageUrl != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Image', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfileImage();
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

     void _showProfileSavedDialog() {
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (context) => Dialog(
         backgroundColor: Colors.transparent,
         child: Container(
           padding: const EdgeInsets.all(24),
           decoration: BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
               colors: [
                 Colors.white.withOpacity(0.25),
                 Colors.white.withOpacity(0.1),
               ],
             ),
             borderRadius: BorderRadius.circular(24),
             border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
             boxShadow: [
               BoxShadow(
                 color: Colors.black.withOpacity(0.10),
                 blurRadius: 16,
                 offset: const Offset(0, 8),
               ),
             ],
           ),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                     colors: [
                       Colors.white.withOpacity(0.3),
                       Colors.white.withOpacity(0.15),
                     ],
                   ),
                   borderRadius: BorderRadius.circular(50),
                   border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                 ),
                 child: const Icon(
                   Icons.check_circle,
                   color: Colors.white,
                   size: 32,
                 ),
               ),
               const SizedBox(height: 16),
               const Text(
                 'Profile Updated!',
                 style: TextStyle(
                   color: Colors.white,
                   fontSize: 20,
                   fontWeight: FontWeight.w600,
                   shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                 ),
               ),
               const SizedBox(height: 12),
               Text(
                 'Your profile has been successfully updated.',
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   color: Colors.white.withOpacity(0.7),
                   fontSize: 16,
                   fontWeight: FontWeight.w400,
                 ),
               ),
               const SizedBox(height: 24),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                     Navigator.of(context).pop();
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.white.withOpacity(0.9),
                     foregroundColor: const Color(0xFF8B5CF6),
                     padding: const EdgeInsets.symmetric(vertical: 12),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                     shadowColor: Colors.black.withOpacity(0.1),
                     elevation: 2,
                   ),
                   child: const Text(
                     'OK',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
               ),
             ],
           ),
         ),
       ),
     );
   }

   void _showStatDetailDialog(String title, Color color) {
    String description = '';
    String howToImprove = '';
    IconData icon = Icons.info;
    
    switch (title) {
      case 'Total Problems':
        description = 'This shows the total number of math problems you have attempted in all your games.';
        howToImprove = '• Play more games to increase this number\n• Try different types of operations\n• Challenge yourself with more problems per game';
        icon = Icons.quiz;
        break;
      case 'Total Score':
        description = 'This represents the total number of correct answers you have given across all games.';
        howToImprove = '• Focus on accuracy when answering\n• Take your time to think before answering\n• Practice regularly to improve your skills\n• Review wrong answers to learn from mistakes';
        icon = Icons.star;
        break;
      case 'Accuracy':
        description = 'This percentage shows how often you answer correctly compared to total problems attempted.';
        howToImprove = '• Double-check your answers before submitting\n• Practice mental math regularly\n• Start with easier problems and gradually increase difficulty\n• Use the "Check Answer" feature to learn from mistakes';
        icon = Icons.trending_up;
        break;
      case 'Stickers':
        description = 'These are rewards you earn for completing games and achieving good scores.';
        howToImprove = '• Complete games to earn stickers\n• Get high scores (90% or above) for special stickers\n• Try different operation types\n• Play regularly to collect more stickers';
        icon = Icons.emoji_emotions;
        break;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is this?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How to improve:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              howToImprove,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 스켈레톤 UI 빌드 메서드
  Widget _buildSkeletonUI() {
    return AnimatedBuilder(
      animation: _skeletonAnimation,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 프로필 카드 스켈레톤
              _buildProfileCardSkeleton(),
              const SizedBox(height: 24),
              // 통계 카드 스켈레톤
              _buildStatsCardSkeleton(),
              const SizedBox(height: 24),
              // 스티커 갤러리 스켈레톤
              _buildStickerGallerySkeleton(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // 프로필 카드 스켈레톤
  Widget _buildProfileCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              children: [
                // 프로필 이미지 스켈레톤
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value)),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 닉네임 스켈레톤
                Container(
                  width: 120,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 통계 카드 스켈레톤
  Widget _buildStatsCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 스켈레톤
                Container(
                  width: 180,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                // 통계 항목들 스켈레톤
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 스티커 갤러리 스켈레톤
  Widget _buildStickerGallerySkeleton() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 스켈레톤
                Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                // 스티커 그리드 스켈레톤
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 8, // 8개의 스켈레톤 아이템
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1 + (0.05 * _skeletonAnimation.value)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value))),
                        ),
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15 + (0.1 * _skeletonAnimation.value)),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 