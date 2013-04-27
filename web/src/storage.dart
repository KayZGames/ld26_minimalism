part of ld26_minimalism;

Store createStore() {
  var store;
  var dbName = 'ld26', storeName = 'gameState';
  if (IndexedDbStore.supported) {
    store = new IndexedDbStore(dbName, storeName);
  } else if (WebSqlStore.supported) {
    store = new WebSqlStore(dbName, storeName);
  } else {
    store = new LocalStorageStore();
  }
  return store;
}

class HighScoreSavingSystem extends IntervalEntitySystem {
  const KEY = 'highScore';
  Store<num> store;
  GameState gameState;
  HighScoreSavingSystem(this.store, this.gameState) : super(30000, Aspect.getEmpty());

  initialize() {
    store.getByKey(KEY).then((value) {
      if (null != value) {
        gameState.highScore = value;
      }
    });
  }

  processEntities(_) {
    store.getByKey(KEY).then((value) {
      if (null == value || value < gameState.score) {
        store.save(gameState.score, KEY);
      }
    });
  }
}