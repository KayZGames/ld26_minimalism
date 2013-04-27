part of ld26_minimalism;

class BackgroundRenderingSystem extends VoidEntitySystem {
  CqWrapper wrapper;

  BackgroundRenderingSystem(this.wrapper);

  processSystem() {
    wrapper.clear();
  }
}