import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/events.dart';
import '../dead_pixels_game.dart';
import '../components/player.dart';

class InputManager {
  final DeadPixelsGame game;

  InputManager(this.game);

  KeyEventResult handleKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // 1. 키를 누른 순간(KeyDown)과 뗀 순간(KeyUp) 모두 체크하기 위해
    // 방향키 이동 연속성을 방해하지 않도록 단축키 처리는 KeyDownEvent에서만 필터링합니다.
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // 🚨 2. 레벨업 팝업이 떠서 게임이 일시정지된 상태일 때의 단축키 (카드 선택 1, 2, 3)
    if (game.isGamePaused) {
      if (key == LogicalKeyboardKey.digit1) {
        _selectLevelUpCard(0);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit2) {
        _selectLevelUpCard(1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit3) {
        _selectLevelUpCard(2);
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled; // 일시정지 중 다른 키 입력 차단
    }

    // 3. 인게임 플레이 중 단축키 핸들링
    // 포탑/오라/바리케이드 업그레이드 단축키 (1, 2, 3)
    if (key == LogicalKeyboardKey.digit1) {
      game.buyTowerUpgrade('turret');
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.digit2) {
      game.buyTowerUpgrade('aura');
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.digit3) {
      game.buyTowerUpgrade('repair');
      return KeyEventResult.handled;
    }

    // 4. QWER 액티브 스킬 단축키 연동
    final player = game.children.whereType<Player>().firstOrNull;
    if (player != null) {
      if (key == LogicalKeyboardKey.keyQ) {
        player.useSkill('Q');
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyW) {
        player.useSkill('W');
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyE) {
        player.useSkill('E');
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyR) {
        player.useSkill('R');
        return KeyEventResult.handled;
      }
    }

    // 방향키(Arrow Keys)는 Player 컴포넌트의 KeyboardHandler가 읽을 수 있도록 통과시킵니다.
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  /// 1, 2, 3 단축키로 레벨업 카드를 강제 선택하고 게임을 재개시키는 헬퍼 함수
  void _selectLevelUpCard(int index) {
    print("🎯 [단축키 선택] 레벨업 카드 ${index + 1}번 선택됨!");
    // 현재 레벨업 화면에 정의된 액션을 호출하고 게임을 재개합니다.
    game.resumeGameAfterLevelUp();
  }
}