import 'dart:ui';
import 'package:flutter/material.dart';

Future<void> showLoginRequiredDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Stack(
        children: [
          // Glassmorphism Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 유니콘 아이콘 (카드 스타일 X, gradient X)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.7),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF8B5CF6), // primary purple
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 타이틀
                      Text(
                        'Login Required',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 설명
                      Text(
                        'This feature is available after login.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 버튼들
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 뒤로가기 버튼 (secondary)
                          _UnicornDialogButton(
                            text: 'Back',
                            onPressed: () => Navigator.pop(context),
                            color: Colors.white.withOpacity(0.2),
                            textColor: Colors.white,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          // 로그인 버튼 (primary)
                          _UnicornDialogButton(
                            text: 'Login',
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/auth');
                            },
                            color: Color(0xFF8B5CF6), // primary purple
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 배경 장식(별, 구름 등) - 기능 요소와 겹치지 않게 Stack 하단에 배치
          Positioned(
            top: -16,
            right: -16,
            child: Icon(Icons.star, color: Color(0xFFFDE047).withOpacity(0.7), size: 32),
          ),
          Positioned(
            bottom: -12,
            left: -12,
            child: Icon(Icons.cloud, color: Colors.white.withOpacity(0.5), size: 40),
          ),
        ],
      ),
    ),
  );
}

// 버튼 위젯(글래스모피즘 X, gradient X, solid color만)
class _UnicornDialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final Border? border;

  const _UnicornDialogButton({
    required this.text,
    required this.onPressed,
    required this.color,
    required this.textColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
} 