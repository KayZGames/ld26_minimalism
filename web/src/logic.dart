part of ld26_minimalism;

class TimeIsScoreSystem extends VoidEntitySystem {
  GameState gameState;
  TimeIsScoreSystem(this.gameState);

  processSystem() {
    gameState.addWaited(world.delta / 1000);
  }
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