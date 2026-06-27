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
import 'package:flame/camera.dart';  // 카메라 시스템을 위해 필수
import 'package:flame/components.dart'; // World 및 각종 컴포넌트를 위해 필수

class DeadPixelsGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, ChangeNotifier {
  // 1. 월드와 카메라 변수 추가
  late final World world;
  late final CameraComponent cameraComponent;

  // 💡 late final 대신 nullable 선언
  InputManager? _inputManager;

  double gameTime = 120.0;
  int playerGold = 0;
  int playerLevel = 1;
  int playerExp = 0;
  int maxExp = 50;

  bool isGamePaused = false;

  late final DaughterBase daughterBase;

// ... 기존 코드 상단 및 변수들 동일 유지 ...

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 💡 onLoad 안에서 초기화
    _inputManager = InputManager(this);

    // 2. 월드 생성 및 추가
    world = World();
    add(world);

    // 3. 카메라 생성 (800x600 고정 해상도 설정)
    cameraComponent = CameraComponent.withFixedResolution(
      width: 800,
      height: 600,
      world: world,
    );
    cameraComponent.viewfinder.anchor = Anchor.center;
    add(cameraComponent);

    // 카메라 정중앙 위치 고정
    cameraComponent.viewfinder.position = Vector2(400, 300);

    // 4. 컴포넌트 추가 위치를 world.add로 변경
    daughterBase = DaughterBase();
    world.add(daughterBase); // 💡 핵심: game.add 대신 world.add

    final player = Player();
    world.add(player);       // 💡 핵심: game.add 대신 world.add

    world.add(EnemySpawner());

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
    // 💡 _inputManager가 null일 경우, KeyEventResult.ignored를 기본값으로 사용
    final managedResult = _inputManager?.handleKeyEvent(event, keysPressed) ?? KeyEventResult.ignored;

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