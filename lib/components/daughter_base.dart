import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';
import 'enemy.dart';
import 'projectile.dart';
import 'dart:math';

class DaughterBase extends PositionComponent with HasGameRef<DeadPixelsGame>, CollisionCallbacks {
  double maxHp = 500.0;
  double currentHp = 500.0;
  double attackTimer = 0.0;
  double attackCooldown = 1.5;
  int missileCount = 0;

  DaughterBase() {
    size = Vector2(64, 64);
    anchor = Anchor.center;
    // 💡 World 시스템에서는 좌표가 고정되므로 생성자에서 위치를 잡아줍니다.
    position = Vector2(400, 300);
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

    if (missileCount > 0) {
      attackTimer += dt;
      if (attackTimer >= attackCooldown) {
        attackTimer = 0.0;
        _fireAutoTurret();
      }
    }
  }

  void takeDamage(double damage) {
    currentHp = (currentHp - damage).clamp(0.0, maxHp);
    if (currentHp <= 0) {
      _triggerGameOver();
    }
  }

  void _fireAutoTurret() {
    // 1. world 안의 적들을 찾습니다.
    final enemies = gameRef.world.children.whereType<Enemy>();
    if (enemies.isEmpty) return;

    final random = Random();

    for (int i = 0; i < missileCount; i++) {
      // 2. 월드 좌표계(800x600) 기준으로 타겟 생성
      final targetPoint = Vector2(
        random.nextDouble() * 800,
        random.nextDouble() * 600,
      );

      final direction = (targetPoint - position).normalized();

      // 💡 3. 핵심: gameRef.add(X) -> gameRef.world.add(O)
      // 투사체는 반드시 world에 추가되어야 카메라에 잡힙니다.
      gameRef.world.add(Projectile(
        position: position.clone(),
        direction: direction,
        damage: 25.0,
      ));
      print("🚀 미사일 발사! 현재 위치: $position"); // 로그 확인
    }
  }

  // 💡 미사일 수 증가 메서드 (아이템 구매 시 호출)
  void upgradeMissileCount() {
    missileCount++;
    print("🚀 미사일 업그레이드! 현재 미사일 수: $missileCount");
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