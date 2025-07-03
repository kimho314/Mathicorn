import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import '../utils/unicorn_theme.dart';

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
            'Solve problems to collect stickers!',
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

  Widget _buildStickerCard(String sticker, int index, BuildContext context) {
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
          onTap: () => _showStickerDetail(context, sticker, index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sticker,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sticker #${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStickerDetail(BuildContext context, String sticker, int index) {
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
                child: Text(
                  sticker,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sticker #${index + 1}',
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