part of ld26_minimalism;

class BackgroundRenderingSystem extends VoidEntitySystem {
  CqWrapper wrapper;

  BackgroundRenderingSystem(this.wrapper);

  processSystem() {
    wrapper.clear();
  }
}


class GameStateRenderingSystem extends VoidEntitySystem {
  const LABEL_SCORE = 'Score: ';
  const LABEL_ACHIEVEMENTS = 'Achievements: ';
  Rect scoreLabelBounds, achievementsLabelBounds;
  num scoreY, achievementsY;
  CqWrapper wrapper;
  GameState gameState;
  GameStateRenderingSystem(this.wrapper, this.gameState);

  initialize() {
    scoreLabelBounds = wrapper.textBoundaries(LABEL_SCORE);
    achievementsLabelBounds = wrapper.textBoundaries(LABEL_ACHIEVEMENTS);
    scoreY = HEIGHT - scoreLabelBounds.height;
    achievementsY = scoreY - achievementsLabelBounds.height;
  }

  processSystem() {
    wrapper.fillText(LABEL_SCORE, WIDTH - 150 - scoreLabelBounds.width, scoreY);
    wrapper.fillText(LABEL_ACHIEVEMENTS, WIDTH - 150 - achievementsLabelBounds.width, achievementsY);
    var text = gameState.score.toStringAsFixed(3);
    var textBounds = wrapper.textBoundaries(text);
    wrapper.fillText(text, WIDTH - textBounds.width, scoreY);

    text = gameState.achievementCount.toString();
    textBounds = wrapper.textBoundaries(text);
    wrapper.fillText(text, WIDTH - textBounds.width, achievementsY);
  }
}

class AchievementRenderingSystem extends EntitySystem {
  const int ACHIEVEMENT_WIDTH = 200;
  CqWrapper wrapper;
  CqWrapper labelLayer;
  CqWrapper descLayer;
  GameState gameState;
  bool isFirst;
  ComponentMapper<Achievement> am;
  ComponentMapper<ExpirationTimer> tm;
  AchievementRenderingSystem(this.wrapper, this.gameState) : super(Aspect.getAspectForAllOf([Achievement, ExpirationTimer]));

  initialize() {
    am = new ComponentMapper<Achievement>(Achievement, world);
    tm = new ComponentMapper<ExpirationTimer>(ExpirationTimer, world);
    labelLayer = cq(ACHIEVEMENT_WIDTH + 20, HEIGHT)..textBaseline = 'top'
        ..font = 'bold 16px Verdana'
        ..fillStyle = '#30346d'
        ..lineWidth = 3;
    descLayer = cq(ACHIEVEMENT_WIDTH + 20, HEIGHT)..textBaseline = 'top'
        ..fillStyle = '#140c1c'
        ..font = '14px Verdana';
  }

  processEntities(ReadOnlyBag<Entity> entities) {
    List<Entity> sorted = new List<Entity>();
    entities.forEach((e) => sorted.add(e));
    sorted.sort((e1, e2) {
      var a1 = am.get(e1);
      var a2 = am.get(e2);
      return a1.index - a2.index;
    });
    sorted.forEach((e) => processEntity(e));
  }

  processEntity(Entity e) {
    var achievement = am.get(e);
    var timer = tm.get(e);
    var ratio = timer.ratio;
    var labelBounds = labelLayer.textBoundaries(achievement.label, ACHIEVEMENT_WIDTH);
    var descBounds = descLayer.textBoundaries(achievement.desc, ACHIEVEMENT_WIDTH);
    var height = (descBounds.height + labelBounds.height) + 5;

    if (isFirst) {
      isFirst = false;
      if (ratio < 0.1) {
        labelLayer.translate(0, -height * ((0.1 - ratio) / 0.1));
        descLayer.translate(0, -height * ((0.1 - ratio) / 0.1));
      }
    }
    labelLayer.translate(0, height + 2);
    descLayer.translate(0, height + 2);

    labelLayer..globalAlpha = ratio
        ..roundRect(2, -height, ACHIEVEMENT_WIDTH + 16, height, 10, fillStyle: '#597dcf', strokeStyle: '#d34549')
        ..wrappedText(achievement.label, 10, -height, ACHIEVEMENT_WIDTH);
    descLayer..globalAlpha = ratio
        ..wrappedText(achievement.desc, 10, -height + labelBounds.height, ACHIEVEMENT_WIDTH);
  }

  begin() {
    labelLayer.save();
    descLayer.save();
    isFirst = true;
  }

  end() {
    labelLayer.restore();
    descLayer.restore();
    wrapper.drawImage(labelLayer.canvas, 0, 0);
    wrapper.drawImage(descLayer.canvas, 0, 0);
    labelLayer.clear();
    descLayer.clear();
  }

  checkProcessing() => true;
}