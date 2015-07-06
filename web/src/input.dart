part of ld26_minimalism;

class MenuMouseInputSystem extends EntityProcessingSystem {
  Mapper<MenuItem> mm;
  CanvasElement wrapper;
  GameState gameState;
  Point mousePos;
  int button;

  MenuMouseInputSystem(this.wrapper, this.gameState)
      : super(Aspect.getAspectForAllOf([MenuItem]));

  initialize() {
    mm = new Mapper<MenuItem>(MenuItem, world);
    wrapper
      ..onMouseMove.listen((event) => mousePos = event.offset)
      ..onMouseDown.listen((event) => button = event.button)
      ..onMouseUp.listen((event) => button = null);
  }

  processEntity(Entity e) {
    if (null != mousePos) {
      var m = mm[e];
      if (m.x < mousePos.x &&
          m.x + m.width > mousePos.x &&
          m.y < mousePos.y &&
          m.y + m.height > mousePos.y) {
        m.hover = true;
        if (button != null) {
          m.clickAction(button);
        } else {
          m.hoverAction();
        }
      } else {
        m.hover = false;
        if (button != null) {
          gameState.wrongPositionClicked = true;
        }
      }
    }
  }

  checkProcessing() => !gameState.running;
}

class MouseMovementSystem extends VoidEntitySystem {
  CanvasElement wrapper;
  Point mousePos;
  Position pos;

  MouseMovementSystem(this.wrapper);

  initialize() {
    wrapper..onMouseMove.listen((event) => mousePos = event.offset);
    TagManager tm = world.getManager(TagManager);
    pos = tm.getEntity(TAG_PLAYER).getComponentByClass(Position);
  }

  processSystem() {
    if (null != mousePos) {
      pos.cx = mousePos.x;
      pos.cy = mousePos.y;
    }
  }
}
