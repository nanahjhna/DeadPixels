import 'dart:math';
import 'package:flame/components.dart';
import '../dead_pixels_game.dart';
import 'zombie_normal.dart';

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

    // 💡 1. gameRef.add가 아니라 gameRef.world.add로 변경
    final zombie = ZombieNormal(position: spawnPosition);
    gameRef.world.add(zombie);
  }

  /// 💡 2. 화면 기준이 아닌 고정 월드 크기(800x600) 기준으로 스폰 좌표 계산
  Vector2 _getOutsideSpawnPosition() {
    const double mapWidth = 800.0;  // 카메라 해상도와 일치하는 월드 폭
    const double mapHeight = 600.0; // 카메라 해상도와 일치하는 월드 높이
    const double padding = 50.0;

    int edge = _random.nextInt(4);
    double x = 0;
    double y = 0;

    switch (edge) {
      case 0: // 상단
        x = _random.nextDouble() * mapWidth;
        y = -padding;
        break;
      case 1: // 하단
        x = _random.nextDouble() * mapWidth;
        y = mapHeight + padding;
        break;
      case 2: // 좌측
        x = -padding;
        y = _random.nextDouble() * mapHeight;
        break;
      case 3: // 우측
        x = mapWidth + padding;
        y = _random.nextDouble() * mapHeight;
        break;
    }
    return Vector2(x, y);
  }
}