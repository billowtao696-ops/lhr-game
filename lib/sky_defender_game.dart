import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SkyDefenderGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  late PlayerPlane player;
  final Random random = Random();
  
  // Game state
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isGameOverNotifier = ValueNotifier<bool>(false);
  bool isGameOver = false;
  
  // Background clouds
  final List<Cloud> clouds = [];
  
  // Spawn timers
  double enemySpawnTimer = 0;
  double bombSpawnTimer = 0;
  final double enemySpawnInterval = 1.0;  // X2 enemies (2.0 -> 1.0)
  final double bombSpawnInterval = 1.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add background clouds (use dynamic size)
    for (int i = 0; i < 8; i++) {
      clouds.add(Cloud(
        position: Vector2(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y,
        ),
        speed: 20 + random.nextDouble() * 30,
      ));
      add(clouds.last);
    }
    
    // Add player (center bottom of screen)
    player = PlayerPlane(position: Vector2(size.x / 2, size.y * 0.8));
    await add(player);
    
    // Start spawning enemies
    startGame();
  }

  void startGame() {
    isGameOver = false;
    isGameOverNotifier.value = false;
    scoreNotifier.value = 0;
  }

  void resetGame() {
    // Remove all game objects
    children.whereType<EnemyPlane>().toList().forEach((enemy) => enemy.removeFromParent());
    children.whereType<Bomb>().toList().forEach((bomb) => bomb.removeFromParent());
    children.whereType<Rocket>().toList().forEach((rocket) => rocket.removeFromParent());
    children.whereType<PlayerBullet>().toList().forEach((bullet) => bullet.removeFromParent());
    
    // Reset player position (center bottom of screen)
    player.position = Vector2(size.x / 2, size.y * 0.8);
    player.isDead = false;
    player.bulletTimer = 0;
    
    // Reset timers
    enemySpawnTimer = 0;
    bombSpawnTimer = 0;
    
    startGame();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isGameOver) return;
    
    // Spawn enemies
    enemySpawnTimer += dt;
    if (enemySpawnTimer >= enemySpawnInterval) {
      enemySpawnTimer = 0;
      spawnEnemy();
    }
    
    // Spawn bombs
    bombSpawnTimer += dt;
    if (bombSpawnTimer >= bombSpawnInterval) {
      bombSpawnTimer = 0;
      spawnBomb();
    }
  }

  void spawnEnemy() {
    final x = random.nextDouble() * size.x;
    final enemy = EnemyPlane(position: Vector2(x, -20));
    add(enemy);
  }

  void spawnBomb() {
    final x = random.nextDouble() * size.x;
    final bomb = Bomb(position: Vector2(x, -20));
    add(bomb);
  }

  void addScore(int points) {
    scoreNotifier.value += points;
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    isGameOverNotifier.value = true;
  }

  @override
  void render(Canvas canvas) {
    // Draw sky background
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF87CEEB),  // Sky blue
        const Color(0xFFE0F6FF),  // Light blue
      ],
    );
    
    final paint = Paint()
      ..shader = skyGradient.createShader(
        Rect.fromLTWH(0, 0, size.x, size.y),
      );
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    
    super.render(canvas);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (isGameOver) return KeyEventResult.ignored;
    
    // Always update velocity based on currently pressed keys
    player.updateVelocityFromKeys(keysPressed);
    
    return KeyEventResult.handled;
  }
}

// Cloud Component
class Cloud extends PositionComponent with HasGameReference<SkyDefenderGame> {
  Cloud({required Vector2 position, required this.speed}) 
      : super(position: position, size: Vector2(60, 30));
  
  final double speed;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    position.y += speed * dt;
    
    // Reset cloud to top when it goes off screen
    if (position.y > game.size.y) {
      position.y = -30;
      position.x = random.nextDouble() * game.size.x;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    // Draw fluffy cloud shape
    canvas.drawCircle(const Offset(-15, 0), 12, paint);
    canvas.drawCircle(const Offset(0, -5), 15, paint);
    canvas.drawCircle(const Offset(15, 0), 12, paint);
    canvas.drawCircle(const Offset(0, 5), 10, paint);
  }
}

// Player Plane Component
class PlayerPlane extends PositionComponent with HasGameReference<SkyDefenderGame> {
  PlayerPlane({required Vector2 position}) : super(position: position, size: Vector2(40, 40));
  
  bool isDead = false;
  Vector2 velocity = Vector2.zero();
  final double speed = 250.0;
  
  // Bullet firing
  double bulletTimer = 0;
  final double bulletInterval = 0.25;  // 4 bullets per second (1/4 = 0.25s)

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
  }

  void updateVelocityFromKeys(Set<LogicalKeyboardKey> keysPressed) {
    // Reset velocity
    velocity = Vector2.zero();
    
    // Check horizontal movement
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      velocity.x = -speed;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      velocity.x = speed;
    }
    
    // Check vertical movement
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      velocity.y = -speed;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      velocity.y = speed;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isDead) return;
    
    position += velocity * dt;
    
    // Keep player within full screen bounds (allow full screen movement)
    position.x = position.x.clamp(0.0, game.size.x);
    position.y = position.y.clamp(0.0, game.size.y);
    
    // Auto fire bullets
    bulletTimer += dt;
    if (bulletTimer >= bulletInterval) {
      bulletTimer = 0;
      fireBullet();
    }
  }

  void fireBullet() {
    final bullet = PlayerBullet(position: position.clone());
    game.add(bullet);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (isDead) return;
    
    // Draw red player plane
    final paint = Paint()..color = const Color(0xFFE53935);
    final bodyPaint = Paint()..color = const Color(0xFFB71C1C);
    
    // Main body (triangle pointing up)
    final path = Path()
      ..moveTo(0, -20)  // nose
      ..lineTo(-15, 15)  // left wing
      ..lineTo(15, 15)   // right wing
      ..close();
    
    canvas.drawPath(path, paint);
    
    // Cockpit
    canvas.drawCircle(const Offset(0, 0), 5, bodyPaint);
    
    // Wing details
    canvas.drawLine(
      const Offset(-15, 15),
      const Offset(-10, 10),
      Paint()..color = Colors.white..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(15, 15),
      const Offset(10, 10),
      Paint()..color = Colors.white..strokeWidth = 2,
    );
  }

  void checkCollision(PositionComponent other) {
    if (isDead) return;
    
    final distance = position.distanceTo(other.position);
    // Reduced collision range from 30 to 20
    if (distance < 20) {
      isDead = true;
      game.gameOver();
    }
  }
}

// Player Bullet Component
class PlayerBullet extends PositionComponent with HasGameReference<SkyDefenderGame> {
  PlayerBullet({required Vector2 position}) : super(position: position, size: Vector2(6, 15));
  
  final double speed = 400.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    position.y -= speed * dt;
    
    // Remove if off screen
    if (position.y < -20) {
      removeFromParent();
      return;
    }
    
    // Check collision with enemies ONLY (bullets cannot destroy bombs)
    for (final enemy in game.children.whereType<EnemyPlane>()) {
      final distance = position.distanceTo(enemy.position);
      if (distance < 25) {
        enemy.removeFromParent();
        removeFromParent();
        game.addScore(2);  // +2 for enemy
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw yellow bullet
    final paint = Paint()..color = const Color(0xFFFFEB3B);
    final glowPaint = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    // Glow effect
    canvas.drawOval(
      const Rect.fromLTWH(-4, -8, 8, 16),
      glowPaint,
    );
    
    // Bullet body
    canvas.drawOval(
      const Rect.fromLTWH(-3, -7, 6, 14),
      paint,
    );
  }
}

// Enemy Plane Component
class EnemyPlane extends PositionComponent with HasGameReference<SkyDefenderGame> {
  EnemyPlane({required Vector2 position}) : super(position: position, size: Vector2(40, 40));
  
  final double speed = 200.0;  // X2 speed (100 -> 200)
  double rocketTimer = 0;
  final double rocketInterval = 2.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    position.y += speed * dt;
    
    // Fire rockets at intervals
    rocketTimer += dt;
    if (rocketTimer >= rocketInterval) {
      rocketTimer = 0;
      fireRocket();
    }
    
    // Remove if off screen and add score
    if (position.y > game.size.y) {
      removeFromParent();
      game.addScore(2);  // +2 for enemy escaping (you survived)
    }
    
    // Check collision with player
    if (!game.player.isDead) {
      game.player.checkCollision(this);
    }
  }

  void fireRocket() {
    // Fire 4 rockets at different angles (X4 quantity)
    // Half normal speed, half high speed
    for (int i = 0; i < 4; i++) {
      final angle = (Random().nextDouble() - 0.5) * pi / 2;  // -45° to +45°
      final isHighSpeed = i < 2;  // First 2 are high speed, last 2 are normal
      final rocket = Rocket(
        position: position.clone(),
        rocketAngle: angle,
        isHighSpeed: isHighSpeed,
      );
      game.add(rocket);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw gray enemy plane (inverted triangle)
    final paint = Paint()..color = const Color(0xFF607D8B);
    final darkPaint = Paint()..color = const Color(0xFF455A64);
    
    // Main body (triangle pointing down)
    final path = Path()
      ..moveTo(0, 20)   // nose pointing down
      ..lineTo(-15, -15)  // left wing
      ..lineTo(15, -15)   // right wing
      ..close();
    
    canvas.drawPath(path, paint);
    
    // Cockpit
    canvas.drawCircle(const Offset(0, 0), 5, darkPaint);
  }
}

// Rocket Component
class Rocket extends PositionComponent with HasGameReference<SkyDefenderGame> {
  Rocket({
    required Vector2 position, 
    required this.rocketAngle,
    this.isHighSpeed = false,
  }) : super(position: position, size: Vector2(10, 20), angle: rocketAngle);
  
  final double rocketAngle;
  final bool isHighSpeed;
  late final double speed = isHighSpeed ? 300.0 : 150.0;  // High speed X2

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move in the direction of the angle
    position.x += sin(rocketAngle) * speed * dt;
    position.y += cos(rocketAngle) * speed * dt;
    
    // Remove if off screen
    if (position.y > game.size.y || position.x < -20 || position.x > game.size.x + 20) {
      removeFromParent();
    }
    
    // Check collision with player
    if (!game.player.isDead) {
      game.player.checkCollision(this);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw rocket (different colors for different speeds)
    final paint = Paint()..color = isHighSpeed 
        ? const Color(0xFFE91E63)  // Pink/magenta for high speed
        : const Color(0xFFFF6F00);  // Orange for normal speed
    final flamePaint = Paint()..color = isHighSpeed
        ? const Color(0xFFFF4081)  // Bright pink flame for high speed
        : const Color(0xFFFFEB3B);  // Yellow flame for normal
    
    canvas.save();
    canvas.rotate(rocketAngle);
    
    // Rocket body
    canvas.drawRect(
      const Rect.fromLTWH(-3, -10, 6, 15),
      paint,
    );
    
    // Rocket nose
    final nosePath = Path()
      ..moveTo(0, -10)
      ..lineTo(-3, -7)
      ..lineTo(3, -7)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFFD84315));
    
    // Flame
    canvas.drawCircle(const Offset(0, 7), 3, flamePaint);
    
    canvas.restore();
  }
}

// Bomb Component
class Bomb extends PositionComponent with HasGameReference<SkyDefenderGame> {
  Bomb({required Vector2 position}) : super(position: position, size: Vector2(30, 30));
  
  final double speed = 200.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    position.y += speed * dt;
    
    // Remove if off screen and add score
    if (position.y > game.size.y) {
      removeFromParent();
      game.addScore(1);  // +1 for bomb escaping (you survived)
    }
    
    // Check collision with player
    if (!game.player.isDead) {
      game.player.checkCollision(this);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw black bomb
    final paint = Paint()..color = Colors.black;
    final fusePaint = Paint()..color = const Color(0xFF8D6E63);
    
    // Bomb body (circle)
    canvas.drawCircle(const Offset(0, 5), 12, paint);
    
    // Fuse
    canvas.drawLine(
      const Offset(0, -7),
      const Offset(0, 0),
      fusePaint..strokeWidth = 3,
    );
    
    // Fuse spark
    canvas.drawCircle(
      const Offset(0, -7),
      3,
      Paint()..color = const Color(0xFFFF5722),
    );
  }
}
