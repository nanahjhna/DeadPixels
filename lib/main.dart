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
        // 🚨 해결: 전체 화면 영역에서 800x600 박스 스케일을 정중앙에 고정하되,
        // 하위 오버레이들이 이 크기를 온전히 인식하여 상하좌우 정렬(Alignment)을 계산할 수 있도록 구조를 정립합니다.
        body: Center(
          child: ClipRect( // 게임 화면이 800x600 바깥으로 삐져나가지 않도록 커팅
            child: SizedBox(
              width: 800,
              height: 600,
              child: GameWidget<DeadPixelsGame>(
                key: const ValueKey('dead_pixels_game_widget'),
                game: DeadPixelsGame(),

                // 🛠️ 모든 오버레이 팩토리 설계도 매핑
                // 개별 오버레이 파일 내부에서 Scaffold를 써서 배경을 가려버리는 이슈를 방지하기 위해,
                // 여기서Material 위젯과 투명화 처리를 컨테이너 레이어로 한 번 더 안전하게 감싸서 내보냅니다.
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