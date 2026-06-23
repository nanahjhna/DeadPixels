import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';
import 'enemy.dart'; // 분석기가 이 관계를 명확히 알 수 있도록 확실히 임포트

class Projectile extends PositionComponent with HasGameRef<DeadPixelsGame>, CollisionCallbacks {
  final Vector2 direction;
  final double damage;
  final double speed = 350.0;

  Projectile({
    required Vector2 position,
    required this.direction,
    required this.damage,
  }) {
    this.position = position;
    size = Vector2(8, 8);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGamePaused) return;

    position += direction * speed * dt;

    if (position.x < -10 || position.x > gameRef.size.x + 10 ||
        position.y < -10 || position.y > gameRef.size.y + 10) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // other가 Enemy인지 명확하게 비교 연산 처리
    if (other is Enemy) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final bulletPaint = Paint()..color = Colors.yellowAccent;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      bulletPaint,
    );
  }
}