library ld26_minimalism;

import 'dart:async';
import 'dart:html';

import 'package:dartemis/dartemis.dart';
import 'package:canvas_query/canvas_query.dart';
import 'package:simple_audio/simple_audio.dart';

part 'src/achievements.dart';
part 'src/components.dart';
part 'src/logic.dart';
part 'src/rendering.dart';
part 'src/sound.dart';

const WIDTH = 800;
const HEIGHT = 600;

void main() {
  window.setImmediate(() {
    var wrapper = cq('#gameCanvas');
    wrapper..canvas.height = HEIGHT
           ..canvas.width = WIDTH
           ..textBaseline = 'top'
           ..font = '20px Verdana'
           ..fillStyle = '#140c1c';

    var audioManager = createAudioManager();

    Future.wait([audioManager.makeClip('achievement', 'achievement.ogg').load()]).then((_) {
      new Game(wrapper, audioManager).start();
    });
  });
}

class GameState {
  num score = 0;
  num _waited = 0;
  int achievementCount = 0;
  num get waited => _waited;
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

  Game(this.wrapper, this.audioManager);

  void start() {

    world.addSystem(new TimeIsScoreSystem(gameState));
    world.addSystem(new AchievementSystem(gameState));
    world.addSystem(new ExpirationSystem());
    world.addSystem(new BackgroundRenderingSystem(wrapper));
    world.addSystem(new GameStateRenderingSystem(wrapper, gameState));
    world.addSystem(new AchievementRenderingSystem(wrapper, gameState));
    world.addSystem(new SoundSystem(audioManager));

    world.initialize();

    window.animationFrame.then((time) {
      lastTime = time;
      window.animationFrame.then(gameLoop);
    });
  }


  void gameLoop(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process();
    window.animationFrame.then(gameLoop);
  }
}