import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';

class LevelUpOverlay extends StatelessWidget {
  final DeadPixelsGame game;

  const LevelUpOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      // 💡 화면이 좁을 경우를 대비해 SingleChildScrollView 추가
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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

            // 💡 Row 대신 Column을 사용하여 카드를 세로로 배치
            _buildCard(context, '🏃 무빙 강화', '아빠의 이동 속도가 15% 증가합니다.', () => game.resumeGameAfterLevelUp()),
            const SizedBox(height: 16),
            _buildCard(context, '⚔️ 격투 술사', '기본 평타 공격 속도가 20% 빨라집니다.', () => game.resumeGameAfterLevelUp()),
            const SizedBox(height: 16),
            _buildCard(context, '🎒 보급 장인', '라운드 종료 시 획득하는 골드가 25% 늘어납니다.', () => game.resumeGameAfterLevelUp()),
          ],
        ),
      ),
    );
  }

// 💡 _buildCard의 width를 화면 전체 대비 상대값으로 변경
  Widget _buildCard(BuildContext context, String title, String desc, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, // 화면 가로를 꽉 채움
      height: 140, // 세로 길이를 살짝 줄여서 한 화면에 다 보이게 함
      child: Card(
        color: const Color(0xFF2A2A2A),
        // ... (기존 style 동일)
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row( // 💡 카드 내부도 Row로 바꿔서 옆으로 텍스트+버튼 배치
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onTap,
                  child: const Text('선택'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}