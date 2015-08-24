class EnemyController {

  int enemyLimit = 40;
  int stickyTimer = 100;
  int regularTimer = 2;

  EnemyController() {
  }

  void update() {
    if (maxEnemies > enemyLimit) {
      maxEnemies = enemyLimit;
    }

    if (enemies.size() < floor(maxEnemies)) {
      if (regularTimer > 0){
        regularTimer -= 1;
      }
      else{
        release(floor(random(0, 4)));;
        regularTimer = 5;
      }
    }
    if (enemies_sticky.size() < floor((maxEnemies-10)/3)) {
      if (stickyTimer > 0){
        stickyTimer -= 1;
      }
      else{
        release_sticky(floor(random(0, 4)));
        stickyTimer = 100;
      }
    }
    calculateActorArray(enemies);
    calculateActorArray(enemies_sticky);
    calculateActorArray(enemies_kill);
    calculateActorArray(goldCoins);
  }

  void release(int dir) {
    int[] position = randomCoord(dir);
    enemies.add(new Enemy(position[0], position[1], 100, dir));
  }

  void release_sticky(int dir) {
    int[] position = randomCoord(dir);
    enemies_sticky.add(new Enemy_Sticky(position[0], position[1], 100, dir));
  }
}

