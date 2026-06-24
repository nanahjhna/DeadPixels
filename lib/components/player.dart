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

  // 게임의 메인 레벨을 담당
  int level = 1;

  final Map<String, double> _skillCooldowns = {'Q': 0.0, 'W': 0.0, 'E': 0.0, 'R': 0.0};
  final Map<String, double> _maxCooldowns = {'Q': 0.4, 'W': 3.5, 'E': 2.0, 'R': 12.0};
  final Map<String, int> _reqLevels = {'Q': 1, 'W': 3, 'E': 5, 'R': 7};

  Map<String, double> get skillCooldowns => _skillCooldowns;
  Map<String, double> get maxCooldowns => _maxCooldowns;

  Player() {
    size = Vector2(32, 32);
    anchor = Anchor.center;
  }

// 레벨업 시 호출: UI 갱신 신호(notifyListeners) 전송
  void addLevel() {
    level++;
    gameRef.notifyListeners();
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
    }
  }

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

  void useSkill(String skillType) {
    int required = _reqLevels[skillType] ?? 99;
    if (level < required) return; // 레벨 미달 시 무시
    if (_skillCooldowns[skillType]! > 0) return;

    _skillCooldowns[skillType] = _maxCooldowns[skillType]!;

    switch (skillType) {
      case 'Q': _executeSkillQ(); break;
      case 'W': _executeSkillW(); break;
      case 'E': _executeSkillE(); break;
      case 'R': _executeSkillR(); break;
    }
  }

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
      gameRef.add(Projectile(position: position.clone(), direction: fireDirection, damage: 20.0));
    }
  }

  void _executeSkillW() {
    final enemies = gameRef.children.whereType<Enemy>();
    for (final enemy in enemies) {
      if (position.distanceTo(enemy.position) < 110.0) enemy.takeDamage(60.0);
    }
  }

  void _executeSkillE() {
    Vector2 dashDir = velocity.isZero() ? Vector2(1, 0) : velocity.normalized();
    position.add(dashDir * 50.0);
  }

  void _executeSkillR() {
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