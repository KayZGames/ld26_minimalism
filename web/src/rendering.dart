part of ld26_minimalism;

class BackgroundRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D cq;

  BackgroundRenderingSystem(this.cq);

  processSystem() {
    cq
      ..fillStyle = '#dfefd7'
      ..fillRect(0, 0, WIDTH, HEIGHT);
  }

  begin() => cq.save();
  end() => cq.restore();
}

class GameStateRenderingSystem extends VoidEntitySystem {
  static const LABEL_SCORE = 'Score: ';
  static const LABEL_HIGHSCORE = 'Highscore: ';
  static const LABEL_ACHIEVEMENTS = 'Achievements: ';
  static const LABEL_COUNTDOWN = 'Countdown: ';
  Rectangle scoreLabelBounds, achievementsLabelBounds, countdownLabelBounds;
  TextMetrics highScoreLabelBounds;
  num scoreY, achievementsY, countdownY;
  CanvasRenderingContext2D cq;
  GameState gameState;
  GameStateRenderingSystem(this.cq, this.gameState);

  initialize() {
    scoreLabelBounds = textBoundaries(cq, LABEL_SCORE);
    achievementsLabelBounds = textBoundaries(cq, LABEL_ACHIEVEMENTS);
    highScoreLabelBounds = cq.measureText(LABEL_HIGHSCORE);
    countdownLabelBounds = textBoundaries(cq, LABEL_COUNTDOWN);
    scoreY = HEIGHT - scoreLabelBounds.height;
    achievementsY = scoreY - achievementsLabelBounds.height;
    countdownY = achievementsY - countdownLabelBounds.height;
  }

  processSystem() {
    cq.fillText(LABEL_SCORE, WIDTH - 150 - scoreLabelBounds.width, scoreY);
    cq.fillText(LABEL_ACHIEVEMENTS, WIDTH - 150 - achievementsLabelBounds.width,
        achievementsY);
    cq.fillText(
        LABEL_COUNTDOWN, WIDTH - 150 - countdownLabelBounds.width, countdownY);
    cq.fillText(LABEL_HIGHSCORE, WIDTH - 150 - highScoreLabelBounds.width, 0);
    var text = gameState.score.toStringAsFixed(3);
    var textBounds = cq.measureText(text);
    cq.fillText(text, WIDTH - textBounds.width, scoreY);

    text = gameState.achievementCount.toString();
    textBounds = cq.measureText(text);
    cq.fillText(text, WIDTH - textBounds.width, achievementsY);

    text = gameState.countdown.toString();
    textBounds = cq.measureText(text);
    cq.fillText(text, WIDTH - textBounds.width, countdownY);

    text = gameState.highScore.toStringAsFixed(3);
    textBounds = cq.measureText(text);
    cq.fillText(text, WIDTH - textBounds.width, 0);
  }

  checkProcessing() => gameState.running;
  begin() => cq.save();
  end() => cq.restore();
}

class AchievementRenderingSystem extends EntitySystem {
  static const int ACHIEVEMENT_WIDTH = 200;
  CanvasRenderingContext2D wrapper;
  CanvasRenderingContext2D labelLayer;
  CanvasRenderingContext2D descLayer;
  GameState gameState;
  bool isFirst;
  Mapper<Achievement> am;
  Mapper<ExpirationTimer> tm;
  AchievementRenderingSystem(this.wrapper, this.gameState)
      : super(Aspect.getAspectForAllOf([Achievement, ExpirationTimer]));

  initialize() {
    am = new Mapper<Achievement>(Achievement, world);
    tm = new Mapper<ExpirationTimer>(ExpirationTimer, world);
    CanvasElement labelElement =
        new CanvasElement(width: ACHIEVEMENT_WIDTH + 20, height: HEIGHT);
    labelLayer = labelElement.context2D
      ..textBaseline = 'top'
      ..font = 'bold 16px Verdana'
      ..fillStyle = '#30346d'
      ..lineWidth = 3;
    CanvasElement descElement =
        new CanvasElement(width: ACHIEVEMENT_WIDTH + 20, height: HEIGHT);
    descLayer = descElement.context2D
      ..textBaseline = 'top'
      ..fillStyle = '#140c1c'
      ..font = '14px Verdana';
  }

  processEntities(Iterable<Entity> entities) {
    List<Entity> sorted = new List<Entity>();
    entities.forEach((e) => sorted.add(e));
    sorted.sort((e1, e2) {
      var a1 = am[e1];
      var a2 = am[e2];
      return a1.index - a2.index;
    });
    sorted.forEach((e) => processEntity(e));
  }

  processEntity(Entity e) {
    var achievement = am[e];
    var timer = tm[e];
    var ratio = timer.ratio;
    var labelBounds = textBoundaries(labelLayer, achievement.label);
    var descBounds = textBoundaries(descLayer, achievement.desc);
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

    labelLayer
      ..globalAlpha = ratio
      ..fillStyle = '#597dcf'
      ..strokeStyle = '#d34549'
      ..strokeRect(2, -height, ACHIEVEMENT_WIDTH + 16, height)
      ..fillRect(2, -height, ACHIEVEMENT_WIDTH + 16, height);
    wrappedText(labelLayer, achievement.label, 10, -height, ACHIEVEMENT_WIDTH);
    descLayer..globalAlpha = ratio;
    wrappedText(descLayer, achievement.desc, 10, -height + labelBounds.height,
        ACHIEVEMENT_WIDTH);
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
    labelLayer.clearRect(0, 0, ACHIEVEMENT_WIDTH + 20, HEIGHT);
    descLayer.clearRect(0, 0, ACHIEVEMENT_WIDTH + 20, HEIGHT);
  }

  checkProcessing() => true;
}

class MenuRenderingSystem extends EntityProcessingSystem {
  Mapper<MenuItem> mm;
  CanvasRenderingContext2D cq;
  GameState gameState;
  MenuRenderingSystem(this.cq, this.gameState)
      : super(Aspect.getAspectForAllOf([MenuItem]));

  initialize() {
    mm = new Mapper<MenuItem>(MenuItem, world);
  }

  processEntity(Entity e) {
    var m = mm[e];
    var bounds = textBoundaries(cq, m.label);
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
    cq
      ..fillStyle = fillStyle
      ..strokeStyle = strokeStyle
      ..strokeRect(m.x, m.y, m.width, m.height)
      ..fillRect(m.x, m.y, m.width, m.height)
      ..fillStyle = textColor
      ..fillText(m.label, m.x + m.width / 2 - bounds.width / 2,
          m.y + m.height / 2 - bounds.height / 2);
  }

  begin() {
    cq
      ..save()
      ..fillStyle = '#dfefd7'
      ..fillRect(0, 0, WIDTH, HEIGHT)
      ..lineWidth = 5
      ..fillStyle = '#30346d'
      ..strokeStyle = '#346524'
      ..strokeRect(20, 20, WIDTH - 40, HEIGHT - 40)
      ..fillRect(20, 20, WIDTH - 40, HEIGHT - 40);
  }

  end() {
    cq.restore();
  }

  checkProcessing() => !gameState.running;
}

class RectangleRenderingSystem extends EntityProcessingSystem {
  Mapper<RectangleBody> rbm;
  Mapper<Position> pm;
  Mapper<RenderStyle> sm;
  CanvasRenderingContext2D cq;
  RectangleRenderingSystem(this.cq)
      : super(Aspect.getAspectForAllOf([RectangleBody, Position, RenderStyle]));

  initialize() {
    rbm = new Mapper<RectangleBody>(RectangleBody, world);
    pm = new Mapper<Position>(Position, world);
    sm = new Mapper<RenderStyle>(RenderStyle, world);
  }

  processEntity(Entity e) {
    var pos = pm[e];
    var body = rbm[e];
    var style = sm[e];

    cq
      ..strokeStyle = style.strokeStyle
      ..fillStyle = style.fillStyle
      ..beginPath()
      ..rect(pos.cx - body.width / 2, pos.cy - body.height / 2, body.width,
          body.height)
      ..closePath()
      ..fill()
      ..stroke();
  }

  begin() => cq.save();
  end() => cq.restore();
}

class CircleRenderingSystem extends EntityProcessingSystem {
  Mapper<CircleBody> bm;
  Mapper<Position> pm;
  Mapper<RenderStyle> sm;
  CanvasRenderingContext2D cq;
  CircleRenderingSystem(this.cq)
      : super(Aspect.getAspectForAllOf([CircleBody, Position, RenderStyle]));

  initialize() {
    bm = new Mapper<CircleBody>(CircleBody, world);
    pm = new Mapper<Position>(Position, world);
    sm = new Mapper<RenderStyle>(RenderStyle, world);
  }

  processEntity(Entity e) {
    var pos = pm[e];
    var body = bm[e];
    var style = sm[e];

    cq
      ..save()
      ..fillStyle = style.fillStyle
      ..strokeStyle = style.strokeStyle
      ..arc(pos.cx, pos.cy, body.radius, 0, 2 * PI)
      ..stroke()
      ..fill()
      ..restore();
  }
}

// originally part of CanvasQuery
final Pattern _whitespacePattern = new RegExp((r'\s+'));
/**
 * Writes [text] at [x], [y] and wraps at [maxWidth].
 *
 * The [nlCallback] will be called before a line is written.
 */
void wrappedText(
    CanvasRenderingContext2D ctx, String text, int x, int y, num maxWidth) {
  var regexp = new RegExp(r"(\d+)");
  var h = int.parse(regexp.firstMatch(ctx.font).group(0)) * 2;
  var lines = getLines(ctx, text, maxWidth);

  for (var i = 0; i < lines.length; i++) {
    var oy = (y + i * h * 0.6).toInt();
    var line = lines[i];
    ctx.fillText(line, x, oy);
  }
}

/**
 * Returns a [Rectangle] with the size of a given [text]. If [maxWidth]
 * is given, the [text] will be wrapped.
 */
Rectangle textBoundaries(CanvasRenderingContext2D ctx, String text,
    [num maxWidth]) {
  var regexp = new RegExp(r"(\d+)");
  var h = int.parse(regexp.firstMatch(ctx.font).group(0)) * 2;
  List<String> lines = getLines(ctx, text, maxWidth);
  if (null == maxWidth) {
    maxWidth = ctx.measureText(text).width;
  }
  return new Rectangle(0, 0, maxWidth, (lines.length * h * 0.6).toInt());
}

/**
 * Splits the [text] at [maxWidth] and returns a list of lines.
 */
List<String> getLines(CanvasRenderingContext2D ctx, String text,
    [num maxWidth]) {
  var words = text.split(_whitespacePattern);

  var ox = 0;

  var lines = new List<String>.from([""]);
  var spaceWidth = ctx.measureText(" ").width;
  if (null != maxWidth) {
    maxWidth += spaceWidth;
    var line = 0;
    for (var i = 0; i < words.length; i++) {
      var word = "${words[i]} ";
      var wordWidth = ctx.measureText(word).width;

      if (ox + wordWidth > maxWidth) {
        lines.add("");
        line++;
        ox = 0;
      }
      lines[line] = "${lines[line]}$word";

      ox += wordWidth;
    }
  } else {
    lines = [text];
  }
  return lines;
}
