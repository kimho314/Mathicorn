import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import 'package:Mathicorn/models/user_profile.dart';
import 'package:Mathicorn/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 표시될 때마다 최신 통계 로드
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadUserProfile() {
    final auth = context.read<AuthProvider>();
    _nameController.text = auth.nickname;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _saveProfile();
                }
              });
            },
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
          ),
        ),
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            // Consumer에서 최신 프로필 정보 가져오기
            final userProfile = gameProvider.userProfile;
            
            // 프로필 정보가 변경되면 로컬 상태 업데이트
            if (userProfile != null && _nameController.text != userProfile.name) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadUserProfile();
              });
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 프로필 카드
                  _buildProfileCard(userProfile),
                  const SizedBox(height: 24),
                  
                  // 통계 카드
                  _buildStatsCard(userProfile),
                  const SizedBox(height: 24),
                  
                  // 스티커 갤러리
                  _buildStickerGallery(userProfile),
                  const SizedBox(height: 20), // 하단 여백 추가
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile? userProfile) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Text(
              auth.nickname.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 이름 입력
          if (_isEditing) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Text(
              auth.nickname,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap each item for details and tips',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Problems',
                  '${userProfile?.totalProblems ?? 0}',
                  Icons.quiz,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Total Score',
                  '${userProfile?.totalScore ?? 0}',
                  Icons.star,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Accuracy',
                  userProfile?.totalProblems != null && userProfile!.totalProblems > 0
                      ? '${((userProfile.totalScore / userProfile.totalProblems) * 100).round()}%'
                      : '0%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Stickers',
                  '${userProfile?.collectedStickers.length ?? 0}',
                  Icons.emoji_emotions,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showStatDetailDialog(title, color),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              Icons.info_outline,
              size: 16,
              color: color.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerGallery(UserProfile? userProfile) {
    final stickers = userProfile?.collectedStickers ?? [];
    
    return Container(
      height: 300, // 고정 높이 설정
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (stickers.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_emotions_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No stickers collected yet!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Solve problems to collect stickers!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
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
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        stickers[index],
                        style: const TextStyle(fontSize: 24),
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

  void _saveProfile() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.setUserProfile(_nameController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로필이 저장되었습니다!')),
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
} 