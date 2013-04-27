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
    var targetX = getTarget(playerPos.x, follower.minX, follower.maxX);
    var targetY = getTarget(playerPos.y, follower.minY, follower.maxY);
    var diffX = targetX - pos.x;
    var diffY = targetY - pos.y;
    pos.x += FastMath.signum(diffX) * min(diffX.abs(), follower.maxChangeX);
    pos.y += FastMath.signum(diffY) * min(diffY.abs(), follower.maxChangeY);
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