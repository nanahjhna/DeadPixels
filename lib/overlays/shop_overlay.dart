import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';

class ShopOverlay extends StatelessWidget {
  final DeadPixelsGame game;

  const ShopOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // 🔥 하단 오른쪽(bottomRight) 정렬로 확실하게 고정
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  // 오른쪽 구석과 바닥에서 적당히 띄워줍니다.
                  padding: const EdgeInsets.only(right: 60.0, bottom: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    // 기둥 업그레이드, 기지 수리 등 기존에 작성하셨던 상점 내부 UI 배치 구조
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildShopButton('1', '포탑', '100G', () => game.buyTowerUpgrade('turret')),
                        const SizedBox(width: 10),
                        _buildShopButton('2', '오라', '100G', () => game.buyTowerUpgrade('aura')),
                        const SizedBox(width: 10),
                        _buildShopButton('3', '수리', '50G', () => game.buyTowerUpgrade('repair')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 상점 버튼 위젯 헬퍼 (기존 테마에 맞춰 변경하셔도 좋습니다)
  Widget _buildShopButton(String hotkey, String title, String price, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '[$hotkey] $title',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              price,
              style: const TextStyle(fontSize: 9, color: Colors.yellowAccent),
            ),
          ],
        ),
      ),
    );
  }
}