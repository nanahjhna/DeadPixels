import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dead_pixels_game.dart';
import 'projectile.dart';
import 'enemy.dart';

class Player extends PositionComponent with HasGameRef<DeadPixelsGame>, KeyboardHandler {
  Vector2 velocity = Vector2.zero();
  double baseSpeed = 160.0;

  // 스킬 쿨타임 시스템 데이터 변수
  final Map<String, double> _skillCooldowns = {'Q': 0.0, 'W': 0.0, 'E': 0.0, 'R': 0.0};
  final Map<String, double> _maxCooldowns = {'Q': 0.4, 'W': 3.5, 'E': 2.0, 'R': 12.0};

  // 🔥 해결: 외부(SkillOverlay)에서 스킬 쿨타임 정보를 읽어갈 수 있도록 겟터를 개방합니다.
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

    // 쿨타임 타이머 실시간 감소
    _skillCooldowns.forEach((key, value) {
      if (value > 0) _skillCooldowns[key] = (value - dt).clamp(0.0, double.infinity);
    });

    // 방향키 기반 이동 벡터 반영
    if (!velocity.isZero()) {
      position += velocity.normalized() * baseSpeed * dt;
    }
  }

  /// ⌨️ 순수 방향키 감지 모듈
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (gameRef.isGamePaused) {
      velocity.setZero();
      return super.onKeyEvent(event, keysPressed);
    }

    double x = 0;
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) x -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) x += 1;

    double y = 0;
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) y -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) y += 1;

    velocity.setValues(x, y);

    return super.onKeyEvent(event, keysPressed);
  }

  /// 🔥 해결: InputManager에서 호출하는 바로 그 핵심 스킬 실행 메서드입니다.
  void useSkill(String skillType) {
    if (_skillCooldowns[skillType]! > 0) {
      print("⏳ $skillType 스킬 재사용 대기 중: ${_skillCooldowns[skillType]!.toStringAsFixed(1)}초");
      return;
    }

    _skillCooldowns[skillType] = _maxCooldowns[skillType]!;

    switch (skillType) {
      case 'Q':
        _executeSkillQ();
        break;
      case 'W':
        _executeSkillW();
        break;
      case 'E':
        _executeSkillE();
        break;
      case 'R':
        _executeSkillR();
        break;
    }
  }

  // 🔫 [Q] 속사포 권총 사격
  void _executeSkillQ() {
    final enemies = gameRef.children.whereType<Enemy>();
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
      gameRef.add(Projectile(
        position: position.clone(),
        direction: fireDirection,
        damage: 20.0,
      ));
    }
  }

  // 💣 [W] 발밑 지뢰 매설
  void _executeSkillW() {
    print("💣 [스킬 W] 아빠가 발밑 지뢰 매설 완료!");
    final enemies = gameRef.children.whereType<Enemy>();
    for (final enemy in enemies) {
      if (position.distanceTo(enemy.position) < 110.0) {
        enemy.takeDamage(60.0);
      }
    }
  }

  // ⚡ [E] 긴급 대시
  void _executeSkillE() {
    print("⚡ [스킬 E] 아빠 방향키 기반 긴급 대시!");
    Vector2 dashDir = velocity.isZero() ? Vector2(1, 0) : velocity.normalized();
    position.add(dashDir * 50.0);
  }

  // 💥 [R 궁극기] 화면 전체 충격파
  void _executeSkillR() {
    print("💥 [스킬 R 궁극기] 전체 섬멸 충격파 발사!");
    final enemies = gameRef.children.whereType<Enemy>().toList();
    for (final enemy in enemies) {
      enemy.takeDamage(120.0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.blueAccent;
    canvas.drawRect(size.toRect(), paint);
  }
}