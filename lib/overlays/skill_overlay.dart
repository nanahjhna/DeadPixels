import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';
import '../components/player.dart';

class SkillOverlay extends StatelessWidget {
  final DeadPixelsGame game;

  const SkillOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, child) {
        final player = game.children.whereType<Player>().firstOrNull;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 60.0, bottom: 20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSkillCard('Q', '속사', Colors.orangeAccent, player, 1),
                        const SizedBox(width: 10),
                        _buildSkillCard('W', '지뢰', Colors.redAccent, player, 3),
                        const SizedBox(width: 10),
                        _buildSkillCard('E', '대시', Colors.blueAccent, player, 5),
                        const SizedBox(width: 10),
                        _buildSkillCard('R', '섬멸', Colors.purpleAccent, player, 7),
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

  Widget _buildSkillCard(String key, String name, Color themeColor, Player? player, int reqLv) {
    final int currentLevel = game.playerLevel;
    final bool isUnlocked = currentLevel >= reqLv;

    double cooldownProgress = 0.0;
    String cooldownText = '';

    if (isUnlocked && player != null) {
      double current = player.skillCooldowns[key] ?? 0.0;
      double max = player.maxCooldowns[key] ?? 1.0;

      cooldownProgress = (current / max).clamp(0.0, 1.0);
      if (current > 0) {
        cooldownText = current.toStringAsFixed(1);
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0xFF2D2D2D) : Colors.black87,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isUnlocked ? themeColor.withOpacity(0.6) : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUnlocked) ...[
                Text(
                  key,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white60, fontSize: 9),
                ),
              ] else ...[
                const Icon(Icons.lock, color: Colors.grey, size: 20),
                Text(
                  'Lv.$reqLv',
                  style: const TextStyle(color: Colors.grey, fontSize: 8),
                ),
              ],
            ],
          ),
        ),
        if (isUnlocked && cooldownProgress > 0)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Text(
                    cooldownText,
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}