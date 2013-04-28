part of ld26_minimalism;

typedef void GameInitializer();
class GameSwitchingSystem extends IntervalEntitySystem {
  List<GameInitializer> gameInitializer = new List<GameInitializer>(3);
  GroupManager gm;
  GameState gameState;
  int currentGame = 0;
  GameSwitchingSystem(this.gameState) : super(15000, Aspect.getEmpty());

  initialize() {
    gameInitializer[0] = initWaitGame;
    gameInitializer[1] = initPong;
    gameInitializer[2] = initMultiPong;
    gm = world.getManager(GroupManager);
  }

  processEntities(_) {
    var currentEntities = gm.getEntities('gamegroup$currentGame');
    if (!currentEntities.isEmpty) {
      currentEntities.forEach((entity) {
        entity.disable();
      });
    }
    currentGame = ++currentGame % gameInitializer.length;
    var nextEntities = gm.getEntities('gamegroup$currentGame');
    if (!nextEntities.isEmpty) {
      nextEntities.forEach((entity) {
        entity.enable();
      });
    } else {
      gameInitializer[currentGame]();
    }
  }

  checkProcessing() => gameState.running && super.checkProcessing();

  void initWaitGame() {
    // wait
  }

  void initPong() {
    GroupManager gm = world.getManager(GroupManager);
    createPongBall(random.nextDouble() * FastMath.TWO_PI, gm);
    createPaddle(WIDTH~/2, HEIGHT - 100,  100, 20, gm);
    createPaddle(WIDTH~/2, 100,  WIDTH - 220, 20, gm);
    createPaddle(100, HEIGHT ~/ 2,  20, HEIGHT - 220, gm);
    createPaddle(WIDTH - 100, HEIGHT ~/ 2,  20, HEIGHT - 220, gm);
  }

  void initMultiPong() {
    GroupManager gm = world.getManager(GroupManager);
    createPongBall(random.nextDouble() * FastMath.TWO_PI, gm);
    createPaddle(WIDTH~/2, HEIGHT - 100,  100, 20, gm);
    createPaddle(WIDTH~/2, 100,  100, 20, gm);
    createPaddle(100, HEIGHT ~/ 2,  20, 100, gm);
    createPaddle(WIDTH - 100, HEIGHT ~/ 2,  20, 100, gm);
  }

  void createPongBall(num angle, GroupManager gm) {
    var e = world.createEntity();
    e.addComponent(new Position(WIDTH~/2, HEIGHT~/2));
    e.addComponent(new RectangleBody(10, 10));
    e.addComponent(new RenderStyle(fillStyle: '#140c1c'));
    e.addComponent(new Velocity(0.15, angle));
    e.addToWorld();
    gm.add(e, GROUP_PONG_BALL);
    gm.add(e, 'gamegroup$currentGame');
  }

  void createPaddle(int cx, int cy, int width, int height, GroupManager gm) {
    var e = world.createEntity();
    e.addComponent(new Position(cx, cy));
    e.addComponent(new RectangleBody(width, height));
    e.addComponent(new RenderStyle(strokeStyle: '#452434', fillStyle: '#140c1c'));
    e.addComponent(new PlayerFollower(100 + height~/2 + width~/2,
                                      WIDTH - (100 + height~/2 + width~/2),
                                      100 + height~/2 + width~/2,
                                      HEIGHT - (100 + height~/2 + width~/2),
                                      width > height ? 0.3 : 0,
                                      height > width ? 0.3 : 0));
    e.addToWorld();
    gm.add(e, GROUP_PONG_PADDLE);
    gm.add(e, 'gamegroup$currentGame');
  }
}