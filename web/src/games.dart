part of ld26_minimalism;

class GameSwitchingSystem extends IntervalEntitySystem {
  List<GameInitializer> gameInitializer = new List<GameInitializer>(2);
  GameState gameState;
  int currentGame = 0;
  GameSwitchingSystem(this.gameState) : super(60000, Aspect.getEmpty());

  initialize() {
    gameInitializer[0] = initWaitGame;
    gameInitializer[1] = initPong;
  }

  processEntities(_) {
    gameInitializer[++currentGame % gameInitializer.length]();
  }

  checkProcessing() => gameState.running && super.checkProcessing();

  void initWaitGame() {
    // wait
  }

  void initPong() {
    var e = world.createEntity();
    e.addComponent(new Position(WIDTH / 2, 7/8 * HEIGHT));
    e.addComponent(new RectangleBody(100, 20));
    e.addComponent(new RenderStyle(strokeStyle: '#452434', fillStyle: '#140c1c'));
    e.addComponent(new PlayerFollower(100, WIDTH - 100, 100, HEIGHT - 100, 5, 0));
    e.addToWorld();
  }
}