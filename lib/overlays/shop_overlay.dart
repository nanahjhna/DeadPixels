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
          body: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 60.0, bottom: 20.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔥 이제 골드 비용을 정수로 넘겨줍니다.
                    _buildShopButton('1', '포탑', 100, 'turret'),
                    const SizedBox(width: 10),
                    _buildShopButton('2', '오라', 100, 'aura'),
                    const SizedBox(width: 10),
                    _buildShopButton('3', '수리', 50, 'repair'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopButton(String hotkey, String title, int cost, String type) {
    // 💡 골드 충족 여부 계산
    final bool canAfford = game.playerGold >= cost;

    return Opacity(
      // 돈이 없으면 0.3 투명도(흐리게), 있으면 1.0(선명하게)
      opacity: canAfford ? 1.0 : 0.3,
      child: InkWell(
        // 돈이 있을 때만 클릭 이벤트 연결 (없으면 null을 반환해 비활성화)
        onTap: canAfford ? () => game.buyTowerUpgrade(type) : null,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: canAfford ? Colors.white.withOpacity(0.5) : Colors.grey[700]!,
            ),
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
                '${cost}G',
                style: TextStyle(
                  fontSize: 9,
                  color: canAfford ? Colors.yellowAccent : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}