part of ld26_minimalism;

class HighScoreSavingSystem extends IntervalEntitySystem {
  static const KEY = 'highScore';
  Store store;
  GameState gameState;
  HighScoreSavingSystem(this.store, this.gameState)
      : super(30000, Aspect.getEmpty());

  initialize() {
    store.getByKey(KEY).then((value) {
      if (null != value) {
        gameState.highScore = num.parse(value);
      }
    });
  }

  processEntities(_) {
    store.getByKey(KEY).then((value) {
      if (null == value || num.parse(value) < gameState.score) {
        store.save(gameState.score.toString(), KEY);
      }
    });
  }
}
