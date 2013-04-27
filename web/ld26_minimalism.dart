library ld26_minimalism;

import 'dart:html';

import 'package:dartemis/dartemis.dart';
import 'package:canvas_query/canvas_query.dart';

part 'src/achievements.dart';
part 'src/components.dart';
part 'src/logic.dart';
part 'src/rendering.dart';

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

    new Game(wrapper).start();
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

  Game(this.wrapper);

  void start() {

    world.addSystem(new TimeIsScoreSystem(gameState));
    world.addSystem(new AchievementSystem(gameState));
    world.addSystem(new ExpirationSystem());
    world.addSystem(new BackgroundRenderingSystem(wrapper));
    world.addSystem(new GameStateRenderingSystem(wrapper, gameState));
    world.addSystem(new AchievementRenderingSystem(wrapper, gameState));

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