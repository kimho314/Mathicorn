import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import '../utils/unicorn_theme.dart';
import 'package:Mathicorn/models/math_problem.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        color: Colors.transparent,
        child: Container(
          decoration: UnicornDecorations.appBackground,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: UnicornDecorations.cardGlass,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sticker Gallery',
                      style: UnicornTextStyles.header,
                    ),
                    const SizedBox(height: 24),
                    Consumer<GameProvider>(
                      builder: (context, gameProvider, child) {
                        final userProfile = gameProvider.userProfile;
                        final stickers = userProfile?.collectedStickers ?? [];
                        return Expanded(
                          child: stickers.isEmpty
                              ? _buildEmptyState(context)
                              : _buildStickerGrid(stickers, context),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: UnicornColors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: UnicornShadows.card,
            ),
            child: const Icon(
              Icons.emoji_emotions_outlined,
              size: 80,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No stickers collected yet!',
            style: UnicornTextStyles.header.copyWith(color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get 100 points to collect stickers!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Game'),
            style: UnicornButtonStyles.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStickerGrid(List<String> stickers, BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: stickers.length,
      itemBuilder: (ctx, index) {
        return _buildStickerCard(stickers[index], index, context);
      },
    );
  }

  Widget _buildStickerCard(String stickerName, int index, BuildContext context) {
    final imagePath = _getStickerImagePath(stickerName);
    
    return Container(
      decoration: UnicornDecorations.cardGlass.copyWith(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStickerDetail(context, stickerName, imagePath, index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagePath != null)
                  Image.asset(
                    imagePath,
                    height: 60,
                    width: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                else
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  _getStickerDisplayName(stickerName),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
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

  String _getStickerDisplayName(String stickerName) {
    switch (stickerName) {
      case 'lv1_sticker':
        return 'Level 1';
      case 'lv2_sticker':
        return 'Level 2';
      case 'lv3_sticker':
        return 'Level 3';
      case 'lv4_sticker':
        return 'Level 4';
      case 'lv5_sticker':
        return 'Level 5';
      case 'lv6_sticker':
        return 'Level 6';
      case 'lv7_sticker':
        return 'Level 7';
      case 'lv8_sticker':
        return 'Level 8';
      case 'lv9_sticker':
        return 'Level 9';
      case 'lv10_sticker':
        return 'Level 10';
      case 'lv11_sticker':
        return 'Level 11';
      case 'lv12_sticker':
        return 'Level 12';
      default:
        return stickerName;
    }
  }

  void _showStickerDetail(BuildContext context, String stickerName, String? imagePath, int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: UnicornDecorations.cardGlass,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: UnicornColors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: imagePath != null
                    ? Image.asset(
                        imagePath,
                        height: 100,
                        width: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.emoji_emotions,
                        size: 80,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                _getStickerDisplayName(stickerName),
                style: UnicornTextStyles.header.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Congratulations! You have obtained this sticker!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: UnicornButtonStyles.primary,
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 