import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';

class HudOverlay extends StatelessWidget {
  final DeadPixelsGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: game,
      builder: (context, child) {
        final minutes = (game.gameTime / 60).floor();
        final seconds = (game.gameTime % 60).floor().toString().padLeft(2, '0');
        final expProgress = (game.playerExp / game.maxExp).clamp(0.0, 1.0);

        return SafeArea(
          child: Padding(
            // 💡 상단 패딩을 16.0에서 32.0으로 늘려 전체적으로 아래로 내림
            padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
            child: Stack(
              children: [
                // 1. 좌측 상단: 레벨 및 경험치 상태바
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LV. ${game.playerLevel} 아빠',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: expProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. 중앙 상단: 생존 탈출 타이머 (margin으로 미세 조정)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    // 💡 상단 마진을 추가하여 다른 요소와 더 명확히 거리 확보
                    margin: const EdgeInsets.only(top: 4.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                    ),
                    child: Text(
                      '⏳ $minutes:$seconds',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // 3. 우측 상단: 자원 (골드) 표시 (margin으로 미세 조정)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    // 💡 상단 마진을 추가하여 우측 상단에서도 적절히 아래로 내림
                    margin: const EdgeInsets.only(top: 4.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${game.playerGold}G',
                          style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}