part of ld26_minimalism;

typedef void GameInitializer();
class GameSwitchingSystem extends IntervalEntitySystem {
  List<GameInitializer> gameInitializer = new List<GameInitializer>(4);
  List<String> blockColors = ['#d34549', '#d3aa9a', '#6dc3cb', '#d37d2c', '#6daa2c', '#346524', '#dbd75d', '#dfefd7'];
  GroupManager gm;
  GameState gameState;
  int currentGame = 0;
  GameSwitchingSystem(this.gameState) : super(20000, Aspect.getEmpty());

  initialize() {
    gameInitializer[0] = initWaitGame;
    gameInitializer[3] = initPong;
    gameInitializer[2] = initMultiPong;
    gameInitializer[1] = initBreakout;
    gm = world.getManager(GroupManager);
  }

  processEntities(_) {
    var currentEntities = gm.getEntities(gameState.getGroup(GROUP_GAME));
    if (!currentEntities.isEmpty) {
      currentEntities.forEach((entity) {
        entity.disable();
      });
    }
    currentGame = ++currentGame % gameInitializer.length;
    gameState.gameId = currentGame;
    var nextEntities = gm.getEntities(gameState.getGroup(GROUP_GAME));
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
    createPongBall(PI/4 + random.nextDouble() * PI/2);
    createPaddle(WIDTH~/2, HEIGHT - 100,  100, 20);
    createPaddle(WIDTH~/2, 100,  WIDTH - 220, 20);
    createPaddle(100, HEIGHT ~/ 2,  20, HEIGHT - 220);
    createPaddle(WIDTH - 100, HEIGHT ~/ 2,  20, HEIGHT - 220);
  }

  void initMultiPong() {
    GroupManager gm = world.getManager(GroupManager);
    createPongBall(PI/4 + random.nextDouble() * PI/2);
    createPaddle(WIDTH~/2, HEIGHT - 100,  100, 20);
    createPaddle(WIDTH~/2, 100,  100, 20);
    createPaddle(100, HEIGHT ~/ 2,  20, 100);
    createPaddle(WIDTH - 100, HEIGHT ~/ 2,  20, 100);
  }

  void initBreakout() {
    GroupManager gm = world.getManager(GroupManager);
    createPongBall(PI/4 + random.nextDouble() * PI/2);
    createPaddle(WIDTH~/2, HEIGHT - 100,  100, 20);
    createPaddle(WIDTH~/2, 100,  WIDTH - 220, 20);
    createPaddle(100, HEIGHT ~/ 2,  20, HEIGHT - 220);
    createPaddle(WIDTH - 100, HEIGHT ~/ 2,  20, HEIGHT - 220);
    createBreakoutBlocks();
  }

  void createPongBall(num angle) {
    var e = world.createEntity();
    e.addComponent(new Position(WIDTH~/2, HEIGHT - 120));
    e.addComponent(new RectangleBody(10, 10));
    e.addComponent(new RenderStyle(fillStyle: '#452434'));
    e.addComponent(new Velocity(0.25, angle));
    e.addToWorld();
    gm.add(e, gameState.getGroup(GROUP_PONG_BALL));
    gm.add(e, gameState.getGroup(GROUP_GAME));
  }

  void createPaddle(int cx, int cy, int width, int height) {
    var e = world.createEntity();
    e.addComponent(new Position(cx, cy));
    e.addComponent(new RectangleBody(width, height));
    e.addComponent(new RenderStyle(strokeStyle: '#452434', fillStyle: '#8696a2'));
    e.addComponent(new PlayerFollower(100 + height~/2 + width~/2,
                                      WIDTH - (100 + height~/2 + width~/2),
                                      100 + height~/2 + width~/2,
                                      HEIGHT - (100 + height~/2 + width~/2),
                                      width > height ? 0.3 : 0,
                                      height > width ? 0.3 : 0));
    e.addToWorld();
    gm.add(e, gameState.getGroup(GROUP_BLOCK));
    gm.add(e, gameState.getGroup(GROUP_GAME));
  }

  void createBreakoutBlocks() {
    for (int x = 135; x < WIDTH - 130; x+= 60) {
      String fillStyle = blockColors[random.nextInt(blockColors.length)];
      for (int y = 150; y < HEIGHT - 250; y+= 30) {
        var e = world.createEntity();
        e.addComponent(new Position(x+20, y+20));
        e.addComponent(new RectangleBody(50, 20));
        e.addComponent(new RenderStyle(strokeStyle: '#140c1c', fillStyle: fillStyle));
        e.addComponent(new Destroyable());
        e.addToWorld();
        gm.add(e, gameState.getGroup(GROUP_BLOCK));
        gm.add(e, gameState.getGroup(GROUP_GAME));
      }
    }
  }
}