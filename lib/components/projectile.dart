import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';
import 'enemy.dart';

// 💡 1. CollisionCallbacks 믹스인 추가 (필수!)
class Projectile extends PositionComponent
    with HasGameRef<DeadPixelsGame>, CollisionCallbacks {

  Vector2 direction;
  double speed = 300.0;
  final double damage;

  // 💡 2. 이미 맞은 적을 기록하여 데미지 중복 방지
  final Set<Enemy> _hitEnemies = {};

  Projectile({required Vector2 position, required this.direction, required this.damage}) {
    this.position = position;
    this.size = Vector2(8, 8);
    this.anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 💡 3. collisionType 설정 (일반적인 투사체는 active)
    add(CircleHitbox(radius: 4, collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;

    if (position.x < -50 || position.x > 850 || position.y < -50 || position.y > 650) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Enemy && !_hitEnemies.contains(other)) {
      other.takeDamage(damage);
      _hitEnemies.add(other); // 이 적에게는 더 이상 데미지를 입히지 않음

      // 💡 선택: 관통형 미사일이 아니라면 아래 주석 해제하여 즉시 삭제
      // removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // 💡 4. render의 좌표계 확인 (Anchor가 center이므로 Offset.zero가 중심)
    canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.yellow);
  }
}