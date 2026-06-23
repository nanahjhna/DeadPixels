import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart'; // 순수 메테리얼만 임포트
import 'enemy.dart';

class ZombieNormal extends Enemy {
  ZombieNormal({required Vector2 position})
      : super(
    position: position,
    hp: 40.0,
    speed: 65.0,
    damage: 15.0,
    goldReward: 12,
    expReward: 8,
  ) {
    size = Vector2(24, 24);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  // 🔥 적들이 확실하게 붉은 도트 블록으로 노출되도록 보정
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 좀비 몸통 사각형
    final zombieRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bodyPaint = Paint()..color = const Color(0xFFD32F2F); // 명확한 붉은색
    canvas.drawRect(zombieRect, bodyPaint);

    // 좀비 외곽 테두리선
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(zombieRect, borderPaint);

    // 무시무시한 붉은 눈빛 도트 연출
    final eyePaint = Paint()..color = Colors.yellowAccent;
    canvas.drawRect(const Rect.fromLTWH(4, 4, 4, 4), eyePaint);
    canvas.drawRect(const Rect.fromLTWH(14, 4, 4, 4), eyePaint);
  }
}