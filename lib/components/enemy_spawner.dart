import 'dart:math';
import 'package:flame/components.dart';
import '../dead_pixels_game.dart';
import 'zombie_normal.dart'; // 정식 일반 좀비 클래스 연동

class EnemySpawner extends Component with HasGameRef<DeadPixelsGame> {
  final Random _random = Random();

  // 스폰 주기 타이머
  double _spawnTimer = 0.0;

  // 초기 스폰 쿨타임 (2.0초에 한 번씩 생성)
  double _currentSpawnInterval = 2.0;

  // 최대로 가속되었을 때의 최소 스폰 주기 (0.4초)
  final double _minSpawnInterval = 0.4;

  @override
  void update(double dt) {
    super.update(dt);

    // 게임이 일시정지(예: 레벨업 창 오픈) 상태면 타이머와 좀비 스폰을 멈춤
    if (gameRef.isGamePaused) return;

    // 1. 시간에 따른 서바이벌 난이도 조절
    // 총 제한 시간 120초 중에서 경과된 시간에 비례하여 스폰 속도를 서서히 가속
    double progress = (120.0 - gameRef.gameTime) / 120.0;
    _currentSpawnInterval = (2.0 - (1.6 * progress)).clamp(_minSpawnInterval, 2.0);

    // 2. 스폰 타이머 누적 및 좀비 생성 트리거
    _spawnTimer += dt;
    if (_spawnTimer >= _currentSpawnInterval) {
      _spawnTimer = 0.0;
      _spawnZombie();
    }
  }

  /// 화면 바깥의 임의의 위치에 일반 좀비를 스폰하고 게임 엔진에 등록합니다.
  void _spawnZombie() {
    Vector2 spawnPosition = _getOutsideSpawnPosition();

    // 완성해 둔 'ZombieNormal' 객체를 생성하여 인게임 루프에 투입
    final zombie = ZombieNormal(position: spawnPosition);
    gameRef.add(zombie);
  }

  /// 800x600 화면 영역 밖의 무작위 상/하/좌/우 경계면 좌표를 연산합니다.
  Vector2 _getOutsideSpawnPosition() {
    final double mapWidth = gameRef.size.x;
    final double mapHeight = gameRef.size.y;
    const double padding = 40.0; // 화면 완전히 바깥에서 스폰되도록 주기용 패딩값

    // 0: 상단, 1: 하단, 2: 좌측, 3: 우측 중 무작위 선택
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