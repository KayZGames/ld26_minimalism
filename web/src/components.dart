part of ld26_minimalism;

class Achievement extends Component {
  final String label, desc;
  final int index;
  Achievement(this.label, this.desc, this.index);
}

class ExpirationTimer extends Component {
  final int max;
  double current;
  ExpirationTimer(this.max) {
    current = max.toDouble();
  }
  double get ratio => current <= 0.0 ? 0.0 : current / max;
}

class Sound extends Component {
  final String clipName;
  Sound(this.clipName);
}

class MenuItem extends Component {
  final int x, y, width, height;
  final String label;
  final Function hoverAction, clickAction;
  bool hover = false;
  MenuItem(this.x, this.y, this.width, this.height, this.label, this.hoverAction, this.clickAction);
}

class RectangleBody extends Component {
  num width, height;
  RectangleBody(this.width, this.height);
}

class CircleBody extends Component {
  num radius;
  CircleBody(this.radius);
}

class Position extends Component {
  num cx, cy;
  Position(this.cx, this.cy);
}

class PlayerFollower extends Component {
  num minX, maxX, minY, maxY, maxVelocity;
  bool horizontal, vertical;
  PlayerFollower(this.minX, this.maxX, this.minY, this.maxY, this.maxVelocity, {this.horizontal: true, this.vertical: true});
}

class RenderStyle extends Component {
  String strokeStyle, fillStyle;
  RenderStyle({this.strokeStyle, this.fillStyle});
}

class Velocity extends Component {
  num amount, _angle;
  Velocity(this.amount, this._angle);
  set angle(num value) => _angle = value % FastMath.TWO_PI;
  get angle => _angle;
}

class Destroyable extends Component {}
class Speedup extends Component {}