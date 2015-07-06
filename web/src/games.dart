part of ld26_minimalism;

typedef void GameInitializer();
typedef void GameReset();
class GameSwitchingSystem extends IntervalEntitySystem {
  List<GameInitializer> gameInitializer = new List<GameInitializer>(5);
  List<GameReset> gameReset = new List<GameReset>(5);
  List<String> blockColors = [
    '#d34549',
    '#d3aa9a',
    '#6dc3cb',
    '#d37d2c',
    '#6daa2c',
    '#346524',
    '#dbd75d',
    '#dfefd7'
  ];
  GroupManager gm;
  TagManager tm;
  GameState gameState;
  int currentGame = 0;
  GameSwitchingSystem(this.gameState) : super(20000, Aspect.getEmpty());

  initialize() {
    gameInitializer[GAME_WAIT] = noop;
    gameInitializer[GAME_NOT_PONG] = initNotPong;
    gameInitializer[GAME_MULTIPONG] = initMultiPong;
    gameInitializer[GAME_BREAKOUT] = initBreakout;
    gameInitializer[GAME_DODGEBALL] = initDodgeball;

    gameReset[GAME_WAIT] = noop;
    gameReset[GAME_NOT_PONG] = resetPongBall;
    gameReset[GAME_MULTIPONG] = resetPongBall;
    gameReset[GAME_BREAKOUT] = resetBreakout;
    gameReset[GAME_DODGEBALL] = noop;
    gm = world.getManager(GroupManager);
    tm = world.getManager(TagManager);
  }

  processEntities(_) {
    var currentEntities = gm.getEntities(gameState.getGroup(GROUP_GAME));
    if (!currentEntities.isEmpty) {
      currentEntities.forEach((entity) {
        entity.disable();
      });
    }
    currentGame = random.nextInt(gameInitializer.length);
    startGame(currentGame);
  }

  void startGame(num gameId) {
    gameState.gameId = gameId;
    var nextEntities = gm.getEntities(gameState.getGroup(GROUP_GAME));
    if (!nextEntities.isEmpty) {
      nextEntities.forEach((entity) {
        entity.enable();
      });
      gameReset[gameId]();
    } else {
      gameInitializer[gameId]();
    }
  }

  checkProcessing() {
    var result = gameState.running && super.checkProcessing();
    gameState.countdown = (20000 - delta) ~/ 1000;
    return result;
  }

  void noop() {
    // wait
  }

  void initNotPong() {
    createPongBall(PI / 4 + random.nextDouble() * PI / 2);
    createPaddle(WIDTH ~/ 2, HEIGHT - 100, 100, 20);
    createPaddle(WIDTH ~/ 2, 100, WIDTH - 220, 20, speedup: true);
    createPaddle(100, HEIGHT ~/ 2, 20, HEIGHT - 220, speedup: true);
    createPaddle(WIDTH - 100, HEIGHT ~/ 2, 20, HEIGHT - 220, speedup: true);
  }

  void resetPongBall() {
    if (gm.getEntities(gameState.getGroup(GROUP_PONG_BALL)).isEmpty) {
      var amount = 1 + max(0, gameState.score ~/ 250);
      for (int i = 0; i < amount; i++) {
        createPongBall(PI / 4 + random.nextDouble() * PI / 2);
      }
    }
  }

  void resetBreakout() {
    resetPongBall();
    if (gm.getEntities(gameState.getGroup(GROUP_DESTROYABLE_BLOCK)).isEmpty) {
      createBreakoutBlocks();
    }
  }

  void initMultiPong() {
    createPongBall(PI / 4 + random.nextDouble() * PI / 2);
    createPaddle(WIDTH ~/ 2, HEIGHT - 100, 100, 20);
    createPaddle(WIDTH ~/ 2, 100, 100, 20);
    createPaddle(100, HEIGHT ~/ 2, 20, 100);
    createPaddle(WIDTH - 100, HEIGHT ~/ 2, 20, 100);
  }

  void initBreakout() {
    createPongBall(PI / 4 + random.nextDouble() * PI / 2);
    createPaddle(WIDTH ~/ 2, HEIGHT - 100, 100, 20);
    createPaddle(WIDTH ~/ 2, 100, WIDTH - 220, 20);
    createPaddle(100, HEIGHT ~/ 2, 20, HEIGHT - 220);
    createPaddle(WIDTH - 100, HEIGHT ~/ 2, 20, HEIGHT - 220);
    createBreakoutBlocks();
  }

  void initDodgeball() {
    createDodgeballPlayer();
  }

  void createDodgeballPlayer() {
    var e = world.createEntity();
    e.addComponent(new Position(WIDTH ~/ 2, HEIGHT ~/ 2));
    e.addComponent(new CircleBody(25));
    e.addComponent(new RenderStyle(fillStyle: '#d37d2c'));
    e.addComponent(new PlayerFollower(100, WIDTH - 100, 100, HEIGHT - 100, 1));
    e.addToWorld();
    tm.register(e, TAG_DODGEBALLPLAYER);
    gm.add(e, gameState.getGroup(GROUP_GAME));
  }

  void createPongBall(num angle) {
    var e = world.createEntity();
    e.addComponent(new Position(WIDTH ~/ 2, HEIGHT - 120));
    e.addComponent(new RectangleBody(10, 10));
    e.addComponent(new RenderStyle(fillStyle: '#452434'));
    e.addComponent(new Velocity(0.25, angle));
    e.addToWorld();
    gm.add(e, gameState.getGroup(GROUP_PONG_BALL));
    gm.add(e, gameState.getGroup(GROUP_GAME));
  }

  void createPaddle(int cx, int cy, int width, int height,
      {bool speedup: false}) {
    var e = world.createEntity();
    if (speedup) {
      e.addComponent(new Speedup());
    }
    e.addComponent(new Position(cx, cy));
    e.addComponent(new RectangleBody(width, height));
    e.addComponent(
        new RenderStyle(strokeStyle: '#452434', fillStyle: '#8696a2'));
    e.addComponent(new PlayerFollower(100 + height ~/ 2 + width ~/ 2,
        WIDTH - (100 + height ~/ 2 + width ~/ 2),
        100 + height ~/ 2 + width ~/ 2,
        HEIGHT - (100 + height ~/ 2 + width ~/ 2), 1,
        horizontal: width > height ? true : false,
        vertical: height > width ? true : false));
    e.addToWorld();
    gm.add(e, gameState.getGroup(GROUP_BLOCK));
    gm.add(e, gameState.getGroup(GROUP_GAME));
  }

  void createBreakoutBlocks() {
    for (int x = 135; x < WIDTH - 130; x += 60) {
      String fillStyle = blockColors[random.nextInt(blockColors.length)];
      for (int y = 150; y < HEIGHT - 250; y += 30) {
        var e = world.createEntity();
        e.addComponent(new Position(x + 20, y + 20));
        e.addComponent(new RectangleBody(50, 20));
        e.addComponent(
            new RenderStyle(strokeStyle: '#140c1c', fillStyle: fillStyle));
        e.addComponent(new Destroyable());
        e.addToWorld();
        gm.add(e, gameState.getGroup(GROUP_BLOCK));
        gm.add(e, gameState.getGroup(GROUP_GAME));
        gm.add(e, gameState.getGroup(GROUP_DESTROYABLE_BLOCK));
      }
    }
  }
}
