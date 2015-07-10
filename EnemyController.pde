class EnemyController {

  int[][] releaseZones;
  int enemyLimit = 30;

  EnemyController() {
    releaseZones = new int[][] {
      {
        0, -40, sWidth, -20
      }
      , 
      {
        -40, 0, -20, sHeight
      }
      , 
      {
        0, sHeight+20, sWidth, sHeight+40
      }
      , 
      {
        sWidth+20, 0, sWidth+40, sHeight
      }
    };
  }

  void update() {
    if (maxEnemies > enemyLimit) {
      maxEnemies = enemyLimit;
    }

    if (enemies.size() < floor(maxEnemies)) {
      release(floor(random(0, 4)));
    }
    if (enemies_sticky.size() < floor((maxEnemies-10)/3)) {
      release_sticky(floor(random(0, 4)));
    }
    for (int i = 0; i < enemies.size (); i++) {
      if (!enemies.get(i).active) {
        enemies.remove(i);
        i--;
      } else {
        enemies.get(i).calculate();
      }
    }
    for (int i = 0; i < enemies_sticky.size (); i++) {
      if (!enemies_sticky.get(i).active) {
        enemies_sticky.remove(i);
        i--;
      } else {
        enemies_sticky.get(i).calculate();
      }
    }

    for (int i = 0; i < enemies_kill.size (); i++) {
      if (!enemies_kill.get(i).active) {
        enemies_kill.remove(i);
        i--;
      } else {
        enemies_kill.get(i).calculate();
      }
    }
  }

  void release(int dir) {
    int[] position = randomCoord(dir);
    enemies.add(new Enemy(position[0], position[1], 100, dir));
  }

  void release_sticky(int dir) {
    int[] position = randomCoord(dir);
    enemies_sticky.add(new Enemy_Sticky(position[0], position[1], 100, dir));
  }

  int[] randomCoord(int dir) {
    int tempX = floor(random(releaseZones[dir][0], releaseZones[dir][2]));
    int tempY = floor(random(releaseZones[dir][1], releaseZones[dir][3]));
    int[] bob = {
      tempX, tempY
    };
    return bob;
  }
}

