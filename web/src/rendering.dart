part of ld26_minimalism;

class BackgroundRenderingSystem extends VoidEntitySystem {
  CqWrapper wrapper;

  BackgroundRenderingSystem(this.wrapper);

  processSystem() {
    wrapper.clear(color: '#dfefd7');
  }

  begin() => wrapper.save();
  end() => wrapper.restore();
}

class GameStateRenderingSystem extends VoidEntitySystem {
  const LABEL_SCORE = 'Score: ';
  const LABEL_HIGHSCORE = 'Highscore: ';
  const LABEL_ACHIEVEMENTS = 'Achievements: ';
  Rect scoreLabelBounds, achievementsLabelBounds, highScoreLabelBounds;
  num scoreY, achievementsY;
  CqWrapper wrapper;
  GameState gameState;
  GameStateRenderingSystem(this.wrapper, this.gameState);

  initialize() {
    scoreLabelBounds = wrapper.textBoundaries(LABEL_SCORE);
    achievementsLabelBounds = wrapper.textBoundaries(LABEL_ACHIEVEMENTS);
    highScoreLabelBounds = wrapper.textBoundaries(LABEL_HIGHSCORE);
    scoreY = HEIGHT - scoreLabelBounds.height;
    achievementsY = scoreY - achievementsLabelBounds.height;
  }

  processSystem() {
    wrapper.fillText(LABEL_SCORE, WIDTH - 150 - scoreLabelBounds.width, scoreY);
    wrapper.fillText(LABEL_ACHIEVEMENTS, WIDTH - 150 - achievementsLabelBounds.width, achievementsY);
    wrapper.fillText(LABEL_HIGHSCORE, WIDTH - 150 - highScoreLabelBounds.width, 0);
    var text = gameState.score.toStringAsFixed(3);
    var textBounds = wrapper.textBoundaries(text);
    wrapper.fillText(text, WIDTH - textBounds.width, scoreY);

    text = gameState.achievementCount.toString();
    textBounds = wrapper.textBoundaries(text);
    wrapper.fillText(text, WIDTH - textBounds.width, achievementsY);

    text = gameState.highScore.toStringAsFixed(3);
    textBounds = wrapper.textBoundaries(text);
    wrapper.fillText(text, WIDTH - textBounds.width, 0);
  }

  checkProcessing() => gameState.running;
  begin() => wrapper.save();
  end() => wrapper.restore();
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

class MenuRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<MenuItem> mm;
  CqWrapper wrapper;
  GameState gameState;
  MenuRenderingSystem(this.wrapper, this.gameState) : super(Aspect.getAspectForAllOf([MenuItem]));

  initialize() {
    mm = new ComponentMapper<MenuItem>(MenuItem, world);
  }

  processEntity(Entity e) {
    var m = mm.get(e);
    var bounds = wrapper.textBoundaries(m.label);
    var fillStyle, strokeStyle, textColor;
    if (m.hover) {
      fillStyle = '#d37d2c';
      strokeStyle = '#6daa2c';
      textColor = '#dfefd7';
    } else {
      fillStyle = '#d34549';
      strokeStyle = '#346524';
      textColor = '#dbd75d';
    }
    wrapper..roundRect(m.x, m.y, m.width, m.height, 20, strokeStyle: strokeStyle, fillStyle: fillStyle)
           ..fillStyle = textColor
           ..fillText(m.label, m.x + m.width / 2 - bounds.width / 2,
                               m.y + m.height / 2 - bounds.height / 2);
  }

  begin() {
    wrapper..save()
           ..clear(color: '#dfefd7')
           ..lineWidth = 5
           ..roundRect(20, 20, WIDTH - 40, HEIGHT - 40, 20, strokeStyle: '#346524', fillStyle: '#30346d');

  }

  end() {
    wrapper.restore();
  }

  checkProcessing() => !gameState.running;
}

class RectangleRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<RectangleBody> rbm;
  ComponentMapper<Position> pm;
  ComponentMapper<RenderStyle> sm;
  CqWrapper wrapper;
  RectangleRenderingSystem(this.wrapper) : super(Aspect.getAspectForAllOf([RectangleBody, Position, RenderStyle]));

  initialize() {
    rbm = new ComponentMapper<RectangleBody>(RectangleBody, world);
    pm = new ComponentMapper<Position>(Position, world);
    sm = new ComponentMapper<RenderStyle>(RenderStyle, world);
  }

  processEntity(Entity e) {
    var pos = pm.get(e);
    var body = rbm.get(e);
    var style = sm.get(e);

    wrapper..strokeStyle = style.strokeStyle
        ..fillStyle = style.fillStyle
        ..beginPath()
        ..rect(pos.cx - body.width/2, pos.cy - body.height/2, body.width, body.height)
        ..closePath()
        ..fill()
        ..stroke();
  }

  begin() => wrapper.save();
  end() => wrapper.restore();
}

class CircleRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<CircleBody> bm;
  ComponentMapper<Position> pm;
  ComponentMapper<RenderStyle> sm;
  CqWrapper wrapper;
  CircleRenderingSystem(this.wrapper) : super(Aspect.getAspectForAllOf([CircleBody, Position, RenderStyle]));

  initialize() {
    bm = new ComponentMapper<CircleBody>(CircleBody, world);
    pm = new ComponentMapper<Position>(Position, world);
    sm = new ComponentMapper<RenderStyle>(RenderStyle, world);
  }

  processEntity(Entity e) {
    var pos = pm.get(e);
    var body = bm.get(e);
    var style = sm.get(e);

    wrapper.circle(pos.cx, pos.cy, body.radius, strokeStyle: style.strokeStyle, fillStyle: style.fillStyle);
  }
}