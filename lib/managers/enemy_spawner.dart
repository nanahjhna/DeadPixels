import 'dart:math'; // 🔥 첫 줄 import 오타 수정
import 'package:flame/components.dart';
import '../dead_pixels_game.dart';
import '../components/zombie_normal.dart'; // 🔥 실제 좀비 컴포넌트 임포트

class EnemySpawner extends Component with HasGameRef<DeadPixelsGame> {
  final Random _random = Random();

  double _spawnTimer = 0.0;
  double _currentSpawnInterval = 2.0;
  final double _minSpawnInterval = 0.4;

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.isGamePaused) return;

    double progress = (120.0 - gameRef.gameTime) / 120.0;
    _currentSpawnInterval = (2.0 - (1.6 * progress)).clamp(_minSpawnInterval, 2.0);

    _spawnTimer += dt;
    if (_spawnTimer >= _currentSpawnInterval) {
      _spawnTimer = 0.0;
      _spawnZombie();
    }
  }

  void _spawnZombie() {
    Vector2 spawnPosition = _getOutsideSpawnPosition();

    // 🔥 임시 더미 대신, 이전에 만들어 둔 'ZombieNormal'을 생성하여 맵에 투입합니다.
    final zombie = ZombieNormal(position: spawnPosition);
    gameRef.add(zombie);
  }

  Vector2 _getOutsideSpawnPosition() {
    final double mapWidth = gameRef.size.x;
    final double mapHeight = gameRef.size.y;
    const double padding = 40.0;

    int edge = _random.nextInt(4);
    double x = 0;
    double y = 0;

    switch (edge) {
      case 0: // 상단 외곽
        x = _random.nextDouble() * mapWidth;
        y = -padding;
        break;
      case 1: // 하단 외곽
        x = _random.nextDouble() * mapWidth;
        y = mapHeight + padding;
        break;
      case 2: // 좌측 외곽
        x = -padding;
        y = _random.nextDouble() * mapHeight;
        break;
      case 3: // 우측 외곽
        x = mapWidth + padding;
        y = _random.nextDouble() * mapHeight;
        break;
    }
    return Vector2(x, y);
  }
}