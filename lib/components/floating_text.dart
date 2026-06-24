// lib/components/floating_text.dart
import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';
import '../dead_pixels_game.dart';

class FloatingText extends TextComponent with HasGameRef<DeadPixelsGame> {
  double _opacity = 1.0;

  FloatingText(String text, Vector2 position) : super(
    text: text,
    position: position,
    anchor: Anchor.bottomCenter, // 텍스트 하단 중앙 기준
    textRenderer: TextPaint(
      style: const TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= 20 * dt;
    _opacity -= 0.5 * dt;
    decorator = PaintDecorator.tint(Colors.white.withOpacity(_opacity.clamp(0.0, 1.0)));
    if (_opacity <= 0) removeFromParent();
  }
}