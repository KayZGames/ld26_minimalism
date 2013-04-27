part of ld26_minimalism;

class TimeIsScoreSystem extends VoidEntitySystem {
  GameState gameState;
  TimeIsScoreSystem(this.gameState);

  processSystem() {
    gameState.score += world.delta / 1000;
  }
}