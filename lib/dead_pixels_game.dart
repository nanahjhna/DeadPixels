import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'components/player.dart';
import 'components/enemy_spawner.dart';
import 'components/daughter_base.dart';
import 'components/floating_text.dart';
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

    // 💡 수정 후: 화면 정중앙으로 배치
    daughterBase = DaughterBase();
    // 초기 배치: 이때 size는 이미 로드된 상태입니다.
    daughterBase.position = size / 2;
    add(daughterBase);

    // 💡 플레이어 배치: 기지 바로 아래 (기지 y좌표 + 기지 높이 + 여백)
    final player = Player();
    player.position = daughterBase.position + Vector2(0, 100);
    add(player);

    add(EnemySpawner());

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
    bool isSuccess = false;
    int cost = 0;
    String message = "";

    // 1. 타입별 로직 분기
    if (type == 'repair') {
      cost = 50;
      if (playerGold >= cost) {
        playerGold -= cost;
        daughterBase.currentHp = (daughterBase.currentHp + 100).clamp(0.0, daughterBase.maxHp);
        message = "기지 수리 완료! (+100HP)";
        isSuccess = true;
      }
    }
    else if (type == 'turret') {
      cost = 1;
      if (playerGold >= cost) {
        playerGold -= cost;

        // 💡 수정된 부분: 기지의 업그레이드 메서드 호출
        daughterBase.upgradeMissileCount();

        message = "포탑 업그레이드 완료!";
        isSuccess = true;
      }
    }
    else if (type == 'aura') {
      cost = 100;
      if (playerGold >= cost) {
        playerGold -= cost;
        message = "오라 강화 완료!";
        isSuccess = true;
      }
    }

    // 2. 결과 처리
    if (isSuccess) {
      notifyListeners(); // UI 갱신 (골드, 포탑 개수 등)

      // 메시지 출력
      final Vector2 messagePosition = daughterBase.position + Vector2(0, -daughterBase.size.y / 2 - 30);
      add(FloatingText(message, messagePosition));
    } else {
      print("❌ 골드 부족 또는 업그레이드 불가");
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

    playerLevel++; // 👈 여기서 직접 올림
    print("🎯 게임 매니저 레벨업: $playerLevel");

    playerExp = 0;
    maxExp = (maxExp * 1.4).toInt();
    notifyListeners(); // 👈 여기서 UI 갱신 신호를 보냄
  }

  void _triggerVictory() {
    isGamePaused = true;
    notifyListeners();
  }
}