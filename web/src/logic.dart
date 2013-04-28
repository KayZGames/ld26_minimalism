part of ld26_minimalism;

class TimeIsScoreSystem extends VoidEntitySystem {
  GameState gameState;
  TimeIsScoreSystem(this.gameState);

  processSystem() {
    gameState.addWaited(world.delta / 1000);
  }

  checkProcessing() => gameState.running;
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
        gameState.achievementEarned();
        matches.add(key);
      }
    });
    matches.forEach((key) => achievements.remove(key));
  }
}

class ExpirationSystem extends EntityProcessingSystem {
  ComponentMapper<ExpirationTimer> tm;
  ExpirationSystem() : super(Aspect.getAspectForAllOf([ExpirationTimer]));

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
}

class PlayerFollowingMovementSystem extends EntityProcessingSystem {
  Position playerPos;
  ComponentMapper<Position> pm;
  ComponentMapper<PlayerFollower> fm;
  PlayerFollowingMovementSystem() : super(Aspect.getAspectForAllOf([Position, PlayerFollower]));

  initialize() {
    TagManager tm = world.getManager(TagManager);
    playerPos = tm.getEntity(TAG_PLAYER).getComponentByClass(Position);
    pm = new ComponentMapper<Position>(Position, world);
    fm = new ComponentMapper<PlayerFollower>(PlayerFollower, world);
  }

  processEntity(Entity e) {
    var pos = pm.get(e);
    var follower = fm.get(e);
    var targetX = getTarget(playerPos.cx, follower.minX, follower.maxX);
    var targetY = getTarget(playerPos.cy, follower.minY, follower.maxY);
    var diffX = targetX - pos.cx;
    var diffY = targetY - pos.cy;
    pos.cx += FastMath.signum(diffX) * min(diffX.abs(), follower.maxChangeX * world.delta);
    pos.cy += FastMath.signum(diffY) * min(diffY.abs(), follower.maxChangeY * world.delta);
  }

  num getTarget(num targetPos, num minPos, num maxPos) {
    if (targetPos > maxPos) {
      targetPos = maxPos;
    } else if (targetPos < minPos) {
      targetPos = minPos;
    }
    return targetPos;
  }
}

class MovementSystem extends EntityProcessingSystem {
  ComponentMapper<Position> pm;
  ComponentMapper<Velocity> vm;
  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

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
}

class PongCollisionDetectionSystem extends EntityProcessingSystem {
  GroupManager gm;
  ComponentMapper<Position> pm;
  ComponentMapper<Velocity> vm;
  ComponentMapper<RectangleBody> bm;
  ComponentMapper<Destroyable> dm;
  GameState gameState;

  PongCollisionDetectionSystem(this.gameState) : super(Aspect.getAspectForAllOf([Position, RectangleBody, Velocity]).exclude([PlayerFollower]));

  initialize() {
    gm = world.getManager(GroupManager);
    vm = new ComponentMapper<Velocity>(Velocity, world);
    pm = new ComponentMapper<Position>(Position, world);
    bm = new ComponentMapper<RectangleBody>(RectangleBody, world);
    dm = new ComponentMapper<Destroyable>(Destroyable, world);
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
        var ballVel = vm.get(e);
        var nextAngle = getNextAngle(ballPos, ballBody, paddlePos, paddleBody, ballVel);

        do {
          ballPos.cx -= ballVel.amount * cos(ballVel.angle) * world.delta;
          ballPos.cy -= ballVel.amount * sin(-ballVel.angle) * world.delta;
          xDiff = ballPos.cx - paddlePos.cx;
          yDiff = ballPos.cy - paddlePos.cy;
        } while (isColliding(xDiff, yDiff, ballBody, paddleBody));

        ballVel.angle = nextAngle;
        if (null != dm.getSafe(block)) block.deleteFromWorld();
      }
    });
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

  Rect getRect(Position pos, RectangleBody body) {
    return new Rect(pos.cx - body.width/2, pos.cy - body.height/2, body.width, body.height);
  }

  bool isLeftOrRight(Rect intersection) {
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
}