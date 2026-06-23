import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';
import 'enemy.dart';
import 'projectile.dart'; // 🔥 이 임포트가 누락되어 빨간 줄이 떴습니다!

class DaughterBase extends PositionComponent with HasGameRef<DeadPixelsGame>, CollisionCallbacks {
  double maxHp = 500.0;
  double currentHp = 500.0;
  double attackTimer = 0.0;
  double attackCooldown = 1.5;

  DaughterBase() {
    size = Vector2(64, 64);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGamePaused) return;

    attackTimer += dt;
    if (attackTimer >= attackCooldown) {
      attackTimer = 0.0;
      _fireAutoTurret();
    }
  }

  void takeDamage(double damage) {
    currentHp = (currentHp - damage).clamp(0.0, maxHp);
    if (currentHp <= 0) {
      _triggerGameOver();
    }
  }

  void _fireAutoTurret() {
    final enemies = gameRef.children.whereType<Enemy>();
    if (enemies.isEmpty) return;

    Enemy? closestEnemy;
    double minDistance = double.maxFinite;

    for (final enemy in enemies) {
      double dist = position.distanceTo(enemy.position);
      if (dist < minDistance) {
        minDistance = dist;
        closestEnemy = enemy;
      }
    }

    if (closestEnemy != null && minDistance < 250) {
      final direction = (closestEnemy.position - position).normalized();
      gameRef.add(Projectile(
        position: position.clone(),
        direction: direction,
        damage: 25.0,
      ));
    }
  }

  void _triggerGameOver() {
    gameRef.isGamePaused = true;
    print("💀 GAME OVER");
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final baseRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final basePaint = Paint()..color = Colors.teal;
    canvas.drawRect(baseRect, basePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(baseRect, borderPaint);

    final hpBarRect = Rect.fromLTWH(0, -15, size.x, 6);
    final hpProgressRect = Rect.fromLTWH(0, -15, size.x * (currentHp / maxHp), 6);

    canvas.drawRect(hpBarRect, Paint()..color = Colors.grey[800]!);
    canvas.drawRect(hpProgressRect, Paint()..color = Colors.greenAccent);
  }
}