import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'components/player.dart';
import 'components/enemy_spawner.dart';
import 'components/daughter_base.dart';
import 'managers/input_manager.dart';
import 'overlays/skill_overlay.dart'; // 🔥 스킬 오버레이 임포트 추가

class DeadPixelsGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, ChangeNotifier {
  double gameTime = 120.0;
  int playerGold = 0;
  int playerLevel = 1;
  int playerExp = 0;
  int maxExp = 50;

  bool isGamePaused = false;

  late final InputManager _inputManager;
  late final DaughterBase daughterBase;

// ... 기존 코드 상단 및 변수들 동일 유지 ...

  @override
  Future<void> onLoad() async {
    super.onLoad();
    images.prefix = 'assets/images/';
    _inputManager = InputManager(this);

    // 기지 및 캐릭터 생성 배치
    daughterBase = DaughterBase();
    daughterBase.position = Vector2(size.x / 2, size.y / 2);
    add(daughterBase);

    final player = Player();
    player.position = Vector2(size.x / 2, size.y / 2 + 80);
    add(player);

    add(EnemySpawner());

    // 🔥 [수정] 인게임에 필요한 기본 UI 레이어들을 '동시에' 싹 다 화면에 띄웁니다!
    overlays.addAll(['HUD', 'Shop', 'SkillUI']);
  }

// ... 아래 update 및 LevelUp 처리 로직 생략 (기존대로 유지) ...

  @override
  void update(double dt) {
    if (isGamePaused) return;
    super.update(dt);

    if (gameTime > 0) {
      gameTime -= dt;
      notifyListeners();

      if (gameTime <= 0) {
        gameTime = 0;
        _triggerVictory();
      }
    }
  }

  // Enemy 및 내부 컴포넌트 실시간 UI 동기화 노티파이어
  void updateUI() {
    notifyListeners();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final managedResult = _inputManager.handleKeyEvent(event, keysPressed);
    if (managedResult == KeyEventResult.handled) {
      return managedResult;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  // 상점 기지 업그레이드 비즈니스 로직
  void buyTowerUpgrade(String type) {
    if (type == 'repair') {
      if (playerGold >= 50) {
        playerGold -= 50;
        daughterBase.currentHp = (daughterBase.currentHp + 100).clamp(0.0, daughterBase.maxHp);
        notifyListeners();
      }
    } else {
      if (playerGold >= 100) {
        playerGold -= 100;
        notifyListeners();
      }
    }
  }

  // 레벨업 팝업 오픈 (게임 일시정지)
  void triggerLevelUp() {
    isGamePaused = true;
    overlays.add('LevelUp');
    notifyListeners();
  }

  // 레벨업 선택 완료 후 인게임 복귀 팩토리
  void resumeGameAfterLevelUp() {
    isGamePaused = false;
    overlays.remove('LevelUp');
    playerLevel++;
    playerExp = 0;
    maxExp = (maxExp * 1.4).toInt();
    notifyListeners();
  }

  void _triggerVictory() {
    isGamePaused = true;
    notifyListeners();
  }
}