import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../dead_pixels_game.dart';
import 'daughter_base.dart';

abstract class Enemy extends PositionComponent with HasGameRef<DeadPixelsGame>, CollisionCallbacks {
  double hp;
  double speed;
  double damage;
  int goldReward;
  int expReward;

  Enemy({
    required Vector2 position,
    required this.hp,
    required this.speed,
    required this.damage,
    required this.goldReward,
    required this.expReward,
  }) {
    this.position = position;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGamePaused) return;

    // 💡 1. gameRef.size 대신 world 안의 DaughterBase를 직접 찾습니다.
    final base = gameRef.world.children.whereType<DaughterBase>().firstOrNull;

    if (base != null) {
      // 💡 2. 기지의 위치를 타겟으로 삼습니다. (화면 크기 무관)
      Vector2 target = base.position;
      Vector2 moveDirection = target - position;

      if (moveDirection.length > 5) { // 기지에 거의 다다르면 멈춤
        moveDirection.normalize();
        position += moveDirection * speed * dt;
      }
    } else {
      // 기지가 없는 경우(게임 오버 등)에는 멈추거나 기본 행동 수행
    }
  }

  // 총알이나 스킬에 피격당했을 때 호출
  void takeDamage(double amount) {
    hp -= amount;
    if (hp <= 0) {
      _die();
    }
  }

  void _die() {
    // 플레이어에게 전리품 자원 지급
    gameRef.playerGold += goldReward;
    gameRef.playerExp += expReward;

    // 레벨업 조건 충족 체크
    if (gameRef.playerExp >= gameRef.maxExp) {
      gameRef.triggerLevelUp();
    } else {
      gameRef.updateUI();
    }

    removeFromParent(); // 인게임 컴포넌트 풀에서 완전 삭제
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // 중앙 딸의 대피소 기지에 닿으면 자폭 공격 후 소멸
    if (other is DaughterBase) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }
}