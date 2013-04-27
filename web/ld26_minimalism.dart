library ld26_minimalism;

import 'dart:html';

import 'package:dartemis/dartemis.dart';
import 'package:canvas_query/canvas_query.dart';

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
           ..font = '20px Verdana';

    new Game(wrapper).start();
  });
}

class GameState {
  num score = 0;
}

class Game {
  GameState gameState = new GameState();
  World world = new World();
  num lastTime;
  CqWrapper wrapper;

  Game(this.wrapper);

  void start() {

    world.addSystem(new TimeIsScoreSystem(gameState));
    world.addSystem(new BackgroundRenderingSystem(wrapper));
    world.addSystem(new GameStateRenderingSystem(wrapper, gameState));

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
class GameStateRenderingSystem extends VoidEntitySystem {
  const LABEL_SCORE = 'Score: ';
  Rect scoreLabelBounds;
  num scoreY;
  CqWrapper wrapper;
  GameState gameState;
  GameStateRenderingSystem(this.wrapper, this.gameState);

  initialize() {
    scoreLabelBounds = wrapper.textBoundaries(LABEL_SCORE);
    scoreY = HEIGHT - scoreLabelBounds.height;
  }

  processSystem() {
    wrapper.fillText(LABEL_SCORE, WIDTH - 150 - scoreLabelBounds.width, scoreY);
    var score = gameState.score.toStringAsFixed(3);
    var scoreBounds = wrapper.textBoundaries(score);
    wrapper.fillText(score, WIDTH - scoreBounds.width, scoreY);
  }
}