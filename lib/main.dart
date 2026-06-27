import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dead_pixels_game.dart';

// 📦 모든 인게임 오버레이 컴포넌트 임포트
import 'overlays/skill_overlay.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/levelup_overlay.dart';
import 'overlays/shop_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dead Pixels Survivors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        body: Container(
          color: Colors.yellow, // 게임 바깥 배경색
          child: Center(
            child: AspectRatio(
              aspectRatio: 4 / 3, // 💡 4:3 비율 강제 고정
              child: GameWidget<DeadPixelsGame>(
                key: const ValueKey('dead_pixels_game_widget'),
                game: DeadPixelsGame(),
                overlayBuilderMap: {
                  'HUD': (context, game) => Material(
                    color: Colors.transparent,
                    child: HudOverlay(game: game),
                  ),
                  'Shop': (context, game) => Material(
                    color: Colors.transparent,
                    child: ShopOverlay(game: game),
                  ),
                  'LevelUp': (context, game) => Material(
                    color: Colors.transparent,
                    child: LevelUpOverlay(game: game),
                  ),
                  'SkillUI': (context, game) => Material(
                    color: Colors.transparent,
                    child: SkillOverlay(game: game),
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}