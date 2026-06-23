import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';

class LevelUpOverlay extends StatelessWidget {
  final DeadPixelsGame game;

  const LevelUpOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 LEVEL UP! 🎉',
              style: TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '딸을 지키기 위한 아빠의 능력을 강화하세요.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCard(context, '🏃 무빙 강화', '아빠의 이동 속도가 15% 증가합니다.', () {
                  print('선택: 이속 증가');
                  game.resumeGameAfterLevelUp();
                }),
                const SizedBox(width: 16),
                _buildCard(context, '⚔️ 격투 술사', '기본 평타 공격 속도가 20% 빨라집니다.', () {
                  print('선택: 공속 증가');
                  game.resumeGameAfterLevelUp();
                }),
                const SizedBox(width: 16),
                _buildCard(context, '🎒 보급 장인', '라운드 종료 시 획득하는 골드가 25% 늘어납니다.', () {
                  print('선택: 골드 보너스');
                  game.resumeGameAfterLevelUp();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String desc, VoidCallback onTap) {
    return SizedBox(
      width: 180,
      height: 220,
      child: Card(
        color: const Color(0xFF2A2A2A),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.greenAccent, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('선택', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}