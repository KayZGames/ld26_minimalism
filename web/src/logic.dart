part of ld26_minimalism;

class TimeIsScoreSystem extends VoidEntitySystem {
  var activeFor = [GAME_WAIT];
  GameState gameState;
  Position playerPos;
  num lastX, lastY;
  TimeIsScoreSystem(this.gameState);

  initialize() {
    TagManager tm = world.getManager(TagManager);
    playerPos = tm.getEntity(TAG_PLAYER).getComponentByClass(Position);
    lastX = playerPos.cx;
    lastY = playerPos.cy;
  }

  processSystem() {
    if (lastX == playerPos.cx && lastY == playerPos.cy) {
      gameState.addWaited(world.delta / 1000);
    } else {
      gameState.score -= world.delta / 100;
      gameState.moved += world.delta / 100;
      lastX = playerPos.cx;
      lastY = playerPos.cy;
    }
  }

  checkProcessing() => gameState.running && activeFor.contains(gameState.gameId);
}

class AchievementSystem extends VoidEntitySystem {
  GameState gameState;
  AchievementSystem(this.gameState);

  processSystem() {
    var matches = new List<String>();
    achievements.forEach((key, achievement) {
      if (achievement['check'](gameState)) {
        Entity e = world.createEntity();
        e.addComponent(new Achievement(achievement['label'], achievement['desc'], gameState.achievementCount));
        e.addComponent(new ExpirationTimer(5000));
        e.addToWorld();
        e = world.createEntity();
        e.addComponent(new Sound('achievement'));
        e.addToWorld();
        gameState.achievementEarned(achievement['score']);
        matches.add(key);
      }
    });
    matches.forEach((key) => achievements.remove(key));
  }
}

class ExpirationSystem extends EntityProcessingSystem {
  ComponentMapper<ExpirationTimer> tm;
  GameState gameState;
  ExpirationSystem(this.gameState) : super(Aspect.getAspectForAllOf([ExpirationTimer]));

  initialize() {
    tm = new ComponentMapper<ExpirationTimer>(ExpirationTimer, world);
  }

  processEntity(Entity e) {
    var timer = tm.get(e);
    if (timer.current < 0) {
      e.deleteFromWorld();
    } else {
      timer.current -= world.delta;
    }
  }

  checkProcessing() => gameState.running && super.checkProcessing();
}

class PlayerFollowingMovementSystem extends EntityProcessingSystem {
  Position playerPos;
  ComponentMapper<Position> pm;
  ComponentMapper<PlayerFollower> fm;
  GameState gameState;
  PlayerFollowingMovementSystem(this.gameState) : super(Aspect.getAspectForAllOf([Position, PlayerFollower]));

  initialize() {
    TagManager tm = world.getManager(TagManager);
    playerPos = tm.getEntity(TAG_PLAYER).getComponentByClass(Position);
    pm = new ComponentMapper<Position>(Position, world);
    fm = new ComponentMapper<PlayerFollower>(PlayerFollower, world);
  }

  processEntity(Entity e) {
    var pos = pm.get(e);
    var follower = fm.get(e);
    var diffX = 0;
    var diffY = 0;
    if (follower.horizontal) {
      var targetX = getTarget(playerPos.cx, follower.minX, follower.maxX);
      diffX = targetX - pos.cx;
    }
    if (follower.vertical) {
      var targetY = getTarget(playerPos.cy, follower.minY, follower.maxY);
      diffY = targetY - pos.cy;
    }
    num angle = atan2(diffY, diffX);
    var changeX = follower.maxVelocity * cos(angle) * world.delta;
    var changeY = follower.maxVelocity * sin(angle) * world.delta;
    pos.cx += FastMath.signum(changeX) * min(changeX.abs(), diffX.abs());
    pos.cy += FastMath.signum(changeY) * min(changeY.abs(), diffY.abs());
  }

  num getTarget(num targetPos, num minPos, num maxPos) {
    if (targetPos > maxPos) {
      targetPos = maxPos;
    } else if (targetPos < minPos) {
      targetPos = minPos;
    }
    return targetPos;
  }

  checkProcessing() => gameState.running && super.checkProcessing();
}

class MovementSystem extends EntityProcessingSystem {
  ComponentMapper<Position> pm;
  ComponentMapper<Velocity> vm;
  GameState gameState;
  MovementSystem(this.gameState) : super(Aspect.getAspectForAllOf([Position, Velocity]));

  initialize() {
    vm = new ComponentMapper<Velocity>(Velocity, world);
    pm = new ComponentMapper<Position>(Position, world);
  }

  processEntity(Entity e) {
    var v = vm.get(e);
    var p = pm.get(e);
    p.cx += v.amount * cos(v.angle) * world.delta;
    p.cy += v.amount * sin(-v.angle) * world.delta;
  }

  checkProcessing() => gameState.running && super.checkProcessing();
}

class PongCollisionDetectionSystem extends EntityProcessingSystem {
  GroupManager gm;
  ComponentMapper<Position> pm;
  ComponentMapper<Velocity> vm;
  ComponentMapper<RectangleBody> bm;
  ComponentMapper<Destroyable> dm;
  ComponentMapper<Speedup> sm;
  GameState gameState;

  PongCollisionDetectionSystem(this.gameState) : super(Aspect.getAspectForAllOf([Position, RectangleBody, Velocity]).exclude([PlayerFollower]));

  initialize() {
    gm = world.getManager(GroupManager);
    vm = new ComponentMapper<Velocity>(Velocity, world);
    pm = new ComponentMapper<Position>(Position, world);
    bm = new ComponentMapper<RectangleBody>(RectangleBody, world);
    dm = new ComponentMapper<Destroyable>(Destroyable, world);
    sm = new ComponentMapper<Speedup>(Speedup, world);
  }

  processEntity(Entity e) {
    var ballPos = pm.get(e);
    var ballBody = bm.get(e);
    var blocks = gm.getEntities(gameState.getGroup(GROUP_BLOCK));
    blocks.forEach((block) {
      var paddlePos = pm.get(block);
      var paddleBody = bm.get(block);
      var xDiff = ballPos.cx - paddlePos.cx;
      var yDiff = ballPos.cy - paddlePos.cy;
      if (isColliding(xDiff, yDiff, ballBody, paddleBody)) {
        gameState.score += 1;
        var ballVel = vm.get(e);
        var nextAngle = getNextAngle(ballPos, ballBody, paddlePos, paddleBody, ballVel);

        do {
          ballPos.cx -= ballVel.amount * cos(ballVel.angle) * world.delta;
          ballPos.cy -= ballVel.amount * sin(-ballVel.angle) * world.delta;
          xDiff = ballPos.cx - paddlePos.cx;
          yDiff = ballPos.cy - paddlePos.cy;
        } while (isColliding(xDiff, yDiff, ballBody, paddleBody));

        ballVel.angle = nextAngle;
        if (null != dm.getSafe(block)) {
          block.deleteFromWorld();
          createSound(world, 'blockdestroyed');
          gameState.blocks++;
        } else {
          if (paddleBody.width == 100 || paddleBody.height == 100) {
            gameState.ponged++;
            gameState.pongLost = 0;
          }
          createSound(world, 'paddlehit');
        }
        if (null != sm.getSafe(block)) {
          ballVel.amount += 0.01;
        }
      }
    });
    if (ballPos.cx < -200 || ballPos.cy < -200 || ballPos.cx > WIDTH + 200 || ballPos.cy > HEIGHT + 200) {
      gameState.score -= 10;
      e.deleteFromWorld();
      gameState.ponged = 0;
      gameState.pongLost++;
    }
  }

  num getNextAngle(Position ballPos, RectangleBody ballBody, Position paddlePos, RectangleBody paddleBody, Velocity ballVel) {
    var nextAngle;
    var ballRect = getRect(ballPos, ballBody);
    var paddleRect = getRect(paddlePos, paddleBody);
    var intersection = ballRect.intersection(paddleRect);
    if (isLeftOrRight(intersection)) {
      if ((intersection.width - intersection.height).abs() < 6) {
        nextAngle = PI - ballVel.angle - PI/4 + random.nextDouble() * PI/2;
      } else {
        nextAngle = PI - ballVel.angle;
      }
    } else {
      if ((intersection.width - intersection.height).abs() < 6) {
        nextAngle = -ballVel.angle - PI/4 + random.nextDouble() * PI/2;
      } else {
        nextAngle = -ballVel.angle;
      }
    }
    return nextAngle;
  }

  Rectangle getRect(Position pos, RectangleBody body) {
    return new Rectangle(pos.cx - body.width/2, pos.cy - body.height/2, body.width, body.height);
  }

  bool isLeftOrRight(Rectangle intersection) {
    if (intersection.width < intersection.height) {
      return true;
    }
    return false;
  }

  bool isColliding(num xDiff, num yDiff, RectangleBody ballBody, RectangleBody paddleBody) {
    if (xDiff.abs() <= ballBody.width/2 + paddleBody.width/2
        && yDiff.abs() <= ballBody.height/2 + paddleBody.height/2) {
        return true;
    }
    return false;
  }

  checkProcessing() => gameState.running && super.checkProcessing();
}

class DodgeballSpawningSystem extends IntervalEntitySystem {
  var activeFor = [GAME_DODGEBALL];
  Position playerPos;
  GameState gameState;
  GroupManager gm;
  DodgeballSpawningSystem(this.gameState) : super(900, Aspect.getEmpty());

  initialize() {
    gm = world.getManager(GroupManager);
    TagManager tm = world.getManager(TagManager);
    playerPos = tm.getEntity(TAG_PLAYER).getComponentByClass(Position);
  }

  processEntities(_) {
    var amount = 1 + max(0, gameState.score ~/ 250);
    for (int i = 0; i < amount; i++) {
      spawnBall();
    }
  }

  void spawnBall() {
    var x, y;
    if (random.nextBool()) {
      x = random.nextInt(WIDTH);
      if (random.nextBool()) {
        y = - 100;
      } else {
        y = HEIGHT + 100;
      }
    } else if (random.nextBool()) {
      x = - 100;
      y = random.nextInt(HEIGHT);
    } else {
      x = WIDTH + 100;
      y = random.nextInt(HEIGHT);
    }
    num targetX = max(min(playerPos.cx, WIDTH - 100), 100);
    num targetY = max(min(playerPos.cy, HEIGHT - 100), 100);
    num angle = atan2(targetY - y, targetX - x);
    var e = world.createEntity();

    e.addComponent(new Position(x, y));
    e.addComponent(new Velocity(0.5, -angle));
    e.addComponent(new CircleBody(10));
    e.addComponent(new RenderStyle(fillStyle: '#d34549'));
    e.addToWorld();
    gm.add(e, gameState.getGroup(GROUP_PONG_BALL));
    gm.add(e, gameState.getGroup(GROUP_GAME));
  }

  checkProcessing() => gameState.running && activeFor.contains(gameState.gameId)  && super.checkProcessing();
}

class DodgeballScoringSystem extends EntityProcessingSystem {
  var activeFor = [GAME_DODGEBALL];
  TagManager tm;
  ComponentMapper<Position> pm;
  ComponentMapper<Velocity> vm;
  ComponentMapper<CircleBody> bm;
  ComponentMapper<Destroyable> dm;
  GameState gameState;

  DodgeballScoringSystem(this.gameState) : super(Aspect.getAspectForAllOf([Position, CircleBody, Velocity]).exclude([PlayerFollower]));

  initialize() {
    tm = world.getManager(TagManager);
    vm = new ComponentMapper<Velocity>(Velocity, world);
    pm = new ComponentMapper<Position>(Position, world);
    bm = new ComponentMapper<CircleBody>(CircleBody, world);
    dm = new ComponentMapper<Destroyable>(Destroyable, world);
  }

  processEntity(Entity e) {
    var ballPos = pm.get(e);
    var ballBody = bm.get(e);
    var player = tm.getEntity(TAG_DODGEBALLPLAYER);
    var playerPos = pm.get(player);
    var playerBody = bm.get(player);
    if (Utils.doCirclesCollide(ballPos.cx, ballPos.cy, ballBody.radius, playerPos.cx, playerPos.cy, playerBody.radius)) {
      gameState.score -= 10;
      e.deleteFromWorld();
      createSound(world, 'dodgeballhit');
      gameState.dodged = 0;
      gameState.notDodged++;
    } else if (ballPos.cx < -200 || ballPos.cy < -200 || ballPos.cx > WIDTH + 200 || ballPos.cy > HEIGHT + 200) {
      gameState.score += 1;
      e.deleteFromWorld();
      gameState.dodged++;
      gameState.notDodged = 0;
    }
  }


  checkProcessing() => gameState.running && activeFor.contains(gameState.gameId);
}

void createSound(World world, String name) {
  var sound = world.createEntity();
  sound.addComponent(new Sound(name));
  sound.addToWorld();
}