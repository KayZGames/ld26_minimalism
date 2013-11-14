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

const GAME_WAIT = 0;
const GAME_NOT_PONG = 4;
const GAME_MULTIPONG = 2;
const GAME_BREAKOUT = 3;
const GAME_DODGEBALL = 1;

const TAG_PLAYER = 'player';
const TAG_DODGEBALLPLAYER = 'dodgeballplayer';

const GROUP_PONG_BALL = 'pongball';
const GROUP_BLOCK = 'block';
const GROUP_DESTROYABLE_BLOCK = 'destroyableblock';
const GROUP_GAME = 'gamegroup';

Random random = new Random();

void main() {
  var wrapper = cq('#gameCanvas');
  wrapper..canvas.height = HEIGHT
         ..canvas.width = WIDTH
         ..textBaseline = 'top'
         ..font = '20px Verdana'
         ..fillStyle = '#140c1c';

  var audioManager = createAudioManager();
  var store = createStore();

  Future.wait([audioManager.makeClip('achievement', 'achievement.ogg').load(),
               audioManager.makeClip('dodgeballhit', 'dodgeballhit.ogg').load(),
               audioManager.makeClip('blockdestroyed', 'blockdestroyed.ogg').load(),
               audioManager.makeClip('paddlehit', 'paddlehit.ogg').load(),
               store.open()]).then((_) {
    new Game(wrapper, audioManager, store).start();
  });
}

class GameState {
  final maxGames = 2;
  num _score = 0, highScore = 0;
  num _waited = 0, moved = 0;
  int dodged = 0, notDodged = 0, ponged = 0, pongLost = 0, blocks = 0;
  int achievementCount = 0, countdown = 0;
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
  String getGroup(String name) => '${name}_${gameId}';

  void addWaited(num time) {
    _waited += time;
    score += time;
  }
  void achievementEarned(int value) {
    achievementCount++;
    score += value;
  }
}

class Game {
  GameState gameState = new GameState();
  World world = new World();
  num lastTime;
  CanvasQuery cq;
  AudioManager audioManager;
  Store store;

  Game(this.cq, this.audioManager, this.store);

  void start() {
    var tm = new TagManager();
    var gm = new GroupManager();
    world.addManager(tm);
    world.addManager(gm);

    var e = world.createEntity();
    e.addComponent(createStartButtonMenuItem());
    e.addToWorld();

    e = world.createEntity();
    e.addComponent(new Position(0, 0));
    e.addToWorld();
    tm.register(e, TAG_PLAYER);

    world.addSystem(new MenuMouseInputSystem(cq, gameState));
    world.addSystem(new MouseMovementSystem(cq));
    world.addSystem(new TimeIsScoreSystem(gameState));
    world.addSystem(new AchievementSystem(gameState));
    world.addSystem(new ExpirationSystem(gameState));
    world.addSystem(new PlayerFollowingMovementSystem(gameState));
    world.addSystem(new MovementSystem(gameState));
    world.addSystem(new PongCollisionDetectionSystem(gameState));
    world.addSystem(new DodgeballScoringSystem(gameState));
    world.addSystem(new BackgroundRenderingSystem(cq));
    world.addSystem(new RectangleRenderingSystem(cq));
    world.addSystem(new CircleRenderingSystem(cq));
    world.addSystem(new MenuRenderingSystem(cq, gameState));
    world.addSystem(new GameStateRenderingSystem(cq, gameState));
    world.addSystem(new AchievementRenderingSystem(cq, gameState));
    world.addSystem(new SoundSystem(audioManager));
    world.addSystem(new HighScoreSavingSystem(store, gameState));
    world.addSystem(new GameSwitchingSystem(gameState));
    world.addSystem(new DodgeballSpawningSystem(gameState));

    world.initialize();

    GameSwitchingSystem gss = world.getSystem(GameSwitchingSystem);
    gss.startGame(GAME_BREAKOUT);

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