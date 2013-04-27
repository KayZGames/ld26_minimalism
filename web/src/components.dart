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