library ld26_minimalism;

import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:dartemis/dartemis.dart';
import 'package:canvas_query/canvas_query.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:lawndart/lawndart.dart';

part 'src/achievements.dart';
part 'src/components.dart';
part 'src/games.dart';
part 'src/input.dart';
part 'src/logic.dart';
part 'src/rendering.dart';
part 'src/sound.dart';
part 'src/storage.dart';

const WIDTH = 800;
const HEIGHT = 600;

const TAG_PLAYER = 'player';

void main() {
  window.setImmediate(() {
    var wrapper = cq('#gameCanvas');
    wrapper..canvas.height = HEIGHT
           ..canvas.width = WIDTH
           ..textBaseline = 'top'
           ..font = '20px Verdana'
           ..fillStyle = '#140c1c';

    var audioManager = createAudioManager();
    var store = createStore();

    Future.wait([audioManager.makeClip('achievement', 'achievement.ogg').load(),
                 store.open()]).then((_) {
      new Game(wrapper, audioManager, store).start();
    });
  });
}

class GameState {
  final maxGames = 2;
  num _score = 0, highScore = 0;
  num _waited = 0;
  int achievementCount = 0;
  int gameId = 0;
  bool running = false, hoverStart = false, wrongButton = false,
      wrongPositionClicked = false;
  num get waited => _waited;
  GameState();

  set score(num score) {
    _score = score;
    if (score > highScore) {
      highScore = score;
    }
  }
  get score => _score;

  void addWaited(num time) {
    _waited += time;
    score += time;
  }
  void achievementEarned() {
    achievementCount++;
    score += 100;
  }
}

class Game {
  GameState gameState = new GameState();
  World world = new World();
  num lastTime;
  CqWrapper wrapper;
  AudioManager audioManager;
  Store store;

  Game(this.wrapper, this.audioManager, this.store);

  void start() {
    var tm = new TagManager();
    world.addManager(tm);

    var e = world.createEntity();
    e.addComponent(createStartButtonMenuItem());
    e.addToWorld();

    e = world.createEntity();
    e.addComponent(new Position(0, 0));
    e.addToWorld();
    tm.register(e, TAG_PLAYER);

    world.addSystem(new MenuMouseInputSystem(wrapper, gameState));
    world.addSystem(new MouseMovementSystem(wrapper));
    world.addSystem(new TimeIsScoreSystem(gameState));
    world.addSystem(new AchievementSystem(gameState));
    world.addSystem(new ExpirationSystem());
    world.addSystem(new PlayerFollowingMovementSystem());
    world.addSystem(new BackgroundRenderingSystem(wrapper));
    world.addSystem(new RectangleRenderingSystem(wrapper));
    world.addSystem(new MenuRenderingSystem(wrapper, gameState));
    world.addSystem(new GameStateRenderingSystem(wrapper, gameState));
    world.addSystem(new AchievementRenderingSystem(wrapper, gameState));
    world.addSystem(new SoundSystem(audioManager));
    world.addSystem(new HighScoreSavingSystem(store, gameState));
    world.addSystem(new GameSwitchingSystem(gameState));

    world.initialize();

    window.animationFrame.then((time) {
      lastTime = time;
      window.animationFrame.then(gameLoop);
    });
  }

  MenuItem createStartButtonMenuItem() {
    var onHover = () => gameState.hoverStart = true;
    var onClick = (int button) {
      if (button == 0) {
        gameState.running = true;
      } else {
        gameState.wrongButton = true;
      }
    };
    return new MenuItem(WIDTH~/2 - 100, HEIGHT~/2 - 50, 250, 100, 'START GAME', onHover, onClick);
  }

  void gameLoop(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process();
    window.animationFrame.then(gameLoop);
  }
}

typedef void GameInitializer();