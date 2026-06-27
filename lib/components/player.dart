import 'package:flame/components.dart';
import 'package:flame/events.dart'; // KeyboardHandler를 위해 필수
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dead_pixels_game.dart';
import 'projectile.dart';
import 'enemy.dart';

// 💡 1. KeyboardHandler 믹스인 추가 (이벤트 감지를 위해 필요)
class Player extends PositionComponent with HasGameRef<DeadPixelsGame> {
  Vector2 velocity = Vector2.zero();
  double baseSpeed = 160.0;

  int get level => gameRef.playerLevel;

  final Map<String, double> _skillCooldowns = {'Q': 0.0, 'W': 0.0, 'E': 0.0, 'R': 0.0};
  final Map<String, double> _maxCooldowns = {'Q': 0.4, 'W': 3.5, 'E': 2.0, 'R': 12.0};
  final Map<String, int> _reqLevels = {'Q': 1, 'W': 3, 'E': 5, 'R': 7};

  Map<String, double> get skillCooldowns => _skillCooldowns;
  Map<String, double> get maxCooldowns => _maxCooldowns;

  Player() {
    size = Vector2(32, 32);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGamePaused) return;

    _skillCooldowns.forEach((key, value) {
      if (value > 0) _skillCooldowns[key] = (value - dt).clamp(0.0, double.infinity);
    });

    if (!velocity.isZero()) {
      position += velocity.normalized() * baseSpeed * dt;

      // 월드 범위(800x600) 제한
      position.x = position.x.clamp(0, 800);
      position.y = position.y.clamp(0, 600);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (gameRef.isGamePaused) {
      velocity.setZero();
      return true;
    }
    double x = 0;
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) x -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) x += 1;
    double y = 0;
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) y -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) y += 1;
    velocity.setValues(x, y);
    return true;
  }

  void _executeSkillQ() {
    // 💡 1. gameRef.world.children 으로 적 탐색
    final enemies = gameRef.world.children.whereType<Enemy>();
    if (enemies.isEmpty) return;

    Enemy? targetEnemy;
    double minTargetDist = double.maxFinite;
    for (final enemy in enemies) {
      double dist = position.distanceTo(enemy.position);
      if (dist < minTargetDist) {
        minTargetDist = dist;
        targetEnemy = enemy;
      }
    }

    if (targetEnemy != null) {
      final fireDirection = (targetEnemy.position - position).normalized();

      // 💡 2. 반드시 world.add를 사용해야 카메라 화면에 보입니다!
      gameRef.world.add(
          Projectile(
              position: position.clone(),
              direction: fireDirection,
              damage: 20.0
          )
      );
      print("🔫 Q 스킬 투사체 발사 성공!");
    } else {
      print("🚫 타겟 적을 찾을 수 없음");
    }
  }

  void _executeSkillW() {
    final enemies = gameRef.world.children.whereType<Enemy>();
    for (final enemy in enemies) {
      if (position.distanceTo(enemy.position) < 110.0) enemy.takeDamage(60.0);
    }
  }

  void _executeSkillE() {
    Vector2 dashDir = velocity.isZero() ? Vector2(1, 0) : velocity.normalized();
    position.add(dashDir * 50.0);
  }

  void _executeSkillR() {
    final enemies = gameRef.world.children.whereType<Enemy>().toList();
    for (final enemy in enemies) {
      enemy.takeDamage(120.0);
    }
  }

  // useSkill 메서드는 이전과 동일하게 유지...
  void useSkill(String skillType) {
    int required = _reqLevels[skillType] ?? 99;

    // 이제 여기서 참조하는 level은 항상 gameRef.playerLevel입니다.
    if (level < required) {
      debugPrint("❌ 레벨 부족! (플레이어 레벨: $level, 필요 레벨: $required)");
      return;
    }
    if (_skillCooldowns[skillType]! > 0) {
      print("⏳ 스킬 $skillType 발동 실패: 쿨타임 중 (${_skillCooldowns[skillType]!.toStringAsFixed(1)}초 남음)");
      return;
    }

    // 쿨타임 적용
    _skillCooldowns[skillType] = _maxCooldowns[skillType]!;

    // 💡 스킬 발동 로그
    print("🚀 스킬 $skillType 발동 성공!");

    switch (skillType) {
      case 'Q': _executeSkillQ(); break;
      case 'W': _executeSkillW(); break;
      case 'E': _executeSkillE(); break;
      case 'R': _executeSkillR(); break;
      default: print("⚠️ 알 수 없는 스킬 타입: $skillType"); break;
    }
  }


  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paint()..color = Colors.blueAccent);
  }
}