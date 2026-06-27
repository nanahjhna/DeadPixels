import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/events.dart';
import '../dead_pixels_game.dart';
import '../components/player.dart';

class InputManager {
  final DeadPixelsGame game;

  InputManager(this.game);

  KeyEventResult handleKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {

    // 1. 일시정지 상태 처리 (KeyDown 이벤트에서만 단축키 실행)
    if (game.isGamePaused) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.digit1) _selectLevelUpCard(0);
        else if (event.logicalKey == LogicalKeyboardKey.digit2) _selectLevelUpCard(1);
        else if (event.logicalKey == LogicalKeyboardKey.digit3) _selectLevelUpCard(2);
      }
      return KeyEventResult.handled;
    }

    // 2. 인게임 단축키 및 이동 처리
    final player = game.world.children.whereType<Player>().firstOrNull;

    // --- A. 단축키는 KeyDown 일 때만 실행 ---
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // 업그레이드 단축키
      if (key == LogicalKeyboardKey.digit1) game.buyTowerUpgrade('turret');
      else if (key == LogicalKeyboardKey.digit2) game.buyTowerUpgrade('aura');
      else if (key == LogicalKeyboardKey.digit3) game.buyTowerUpgrade('repair');

      // 스킬 단축키
      if (player != null) {
        if (key == LogicalKeyboardKey.keyQ) player.useSkill('Q');
        else if (key == LogicalKeyboardKey.keyW) player.useSkill('W');
        else if (key == LogicalKeyboardKey.keyE) player.useSkill('E');
        else if (key == LogicalKeyboardKey.keyR) player.useSkill('R');
      }
    }

    // --- B. 이동 로직은 이벤트 타입과 무관하게 매번 계산 (연속성 보장) ---
    if (player != null) {
      double x = 0;
      double y = 0;
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) x -= 1;
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) x += 1;
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) y -= 1;
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) y += 1;

      player.velocity.setValues(x, y);
    }

    return KeyEventResult.handled;
  }

  void _selectLevelUpCard(int index) {
    game.resumeGameAfterLevelUp();
  }
}