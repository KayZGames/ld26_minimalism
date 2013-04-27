part of ld26_minimalism;

class MenuMouseInputSystem extends EntityProcessingSystem {
  ComponentMapper<MenuItem> mm;
  CqWrapper wrapper;
  GameState gameState;
  Point mousePos;
  int button;

  MenuMouseInputSystem(this.wrapper, this.gameState) : super(Aspect.getAspectForAllOf([MenuItem]));

  initialize() {
    mm = new ComponentMapper<MenuItem>(MenuItem, world);
    wrapper.canvas..onMouseMove.listen((event) => mousePos = CqTools.mousePosition(event))
                  ..onMouseDown.listen((event) {
                    button = event.button;
                    event.preventDefault();
                  })
                  ..onMouseUp.listen((event) => button = null);

  }

  processEntity(Entity e) {
    if (null != mousePos) {
      var m = mm.get(e);
      if (m.x < mousePos.x && m.x + m.width > mousePos.x
          && m.y < mousePos.y && m.y + m.height > mousePos.y) {
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
}