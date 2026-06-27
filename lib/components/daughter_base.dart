import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';
import 'enemy.dart';
import 'projectile.dart'; // 🔥 이 임포트가 누락되어 빨간 줄이 떴습니다!
import 'dart:math'; // 💡 랜덤 방향 계산을 위해 필수

class DaughterBase extends PositionComponent with HasGameRef<DeadPixelsGame>, CollisionCallbacks {
  double maxHp = 500.0;
  double currentHp = 500.0;
  double attackTimer = 0.0;
  double attackCooldown = 1.5;

  // 💡 미사일 개수 변수로 변경
  int missileCount = 0;

  DaughterBase() {
    size = Vector2(64, 64);
    anchor = Anchor.center;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // 화면 크기가 변경될 때마다 정중앙으로 재배치
    position = size / 2;
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

    // 미사일이 1개 이상 활성화되어 있을 때만 공격 시도
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
    // 적이 없을 때도 쏘고 싶다면 if (enemies.isEmpty) 조건문을 제거하면 됩니다.
    // 여기서는 적이 있을 때만 쏘도록 유지하겠습니다.
    final enemies = gameRef.children.whereType<Enemy>();
    if (enemies.isEmpty) return;

    final random = Random();

    for (int i = 0; i < missileCount; i++) {
      // 1. 화면 끝 지점 중 하나를 랜덤하게 결정 (상, 하, 좌, 우)
      // 화면 크기를 가져와서 랜덤한 x, y 좌표를 생성합니다.
      final screenWidth = gameRef.size.x;
      final screenHeight = gameRef.size.y;

      final targetPoint = Vector2(
        random.nextDouble() * screenWidth,
        random.nextDouble() * screenHeight,
      );

      // 2. 기지 위치에서 랜덤 타겟 지점까지의 방향 벡터 계산
      final direction = (targetPoint - position).normalized();

      // 3. 미사일 발사
      gameRef.add(Projectile(
        position: position.clone(),
        direction: direction,
        damage: 25.0, // Projectile 클래스에서 충돌 시 removeFromParent()를 하지 않도록 수정해야 관통이 됩니다.
      ));
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