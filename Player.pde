class Player extends Thing {
  int HP = 10000;                 //health of player, restorable?
  int HP_max = 10000;             //health of player, UPGRADABLE
  int regenSpeed = 2;
  float xVel = 0, yVel = 0;
  int gold = 0;
  boolean[] movement;
  boolean[] shooting;
  boolean[] upgrades;
  boolean[] abilities;

  //agility traits
  int agility = 0;
  int[] agilityCosts = {
    100, 120, 140, 180, 220, 260, 300, -1
  };
  int[] maxVels = {
    7, 8, 9, 11, 13, 15, 19, 23
  };
  int[] playerSizes = {
    60, 56, 52, 48, 43, 37, 30, 20
  };

  //power traits
  int power = 0;
  int[] powerCosts = {
    100, 120, 140, 180, 220, 260, 300, -1
  };
  int powerPool = 300;          //
  int[] powerPool_restores = {
    3, 3, 4, 4, 5, 5, 6, 7
  };    //UPGRADABLE
  int powerPool_missile = 60;
  int[] powerPool_maxs = {
    300, 340, 380, 440, 500, 560, 620, 680
  };           //UPGRADABLE

  //shooting vars
  boolean locked = false;
  int coolDown = 200;            //UPGRADABLE?
  int[] coolDown_rates = {
    20, 20, 30, 30, 30, 40, 40, 50
  };
  int coolDown_interval = 200;
  int upgradeCoolDown = 10;            //UPGRADABLE?
  int upgradeCoolDown_rate = 1;
  int upgradeCoolDown_interval = 10;

  Player(int _xPos, int _yPos, int _HP) {
    xPos = _xPos;
    yPos = _yPos;
    HP = _HP;
  }

  void fire(int[] dir) {
    missiles.add(new Missile((int)xPos, (int)yPos, dir));
    powerPool -= powerPool_missile;
  }

  //calculates player events during loop
  void calculate() {
    if (HP <= 0) {
      gameEnd();
    }
    //incrementing cooldowns
    if (coolDown > 0) {
      coolDown -= coolDown_rate();
    } else if (coolDown < 0) {
      coolDown = 0;
    }
    if (upgradeCoolDown > 0) {
      upgradeCoolDown -= upgradeCoolDown_rate;
    }
    //movement
    for (int i = 0; i < 4; i++) {
      if (movement[i]) {
        xVel += moveDirs[i][0];
        yVel += moveDirs[i][1];
      }
    }

    //fire
    if (powerPool <= 0) {
      locked = true;
    }
    if (coolDown == 0 && !locked) {
      int[] missileVel = {
        0, 0
      };
      for (int i = 0; i < 4; i++) {
        if (shooting[i]) {
          missileVel[0] += missileDirs[i][0];
          missileVel[1] += missileDirs[i][1];
        }
      }

      if (missileVel[0] != 0 || missileVel [1] != 0) {
        fire(missileVel);
        coolDown = coolDown_interval;
      };
    };

    //upgrading handler
    if (upgradeCoolDown == 0) {
      for (int i = 0; i < 3; i++) {
        if (upgrades[i]) {
          //TODO: pseudocode for upgrade
          if (agility < 7) {
            agility += 1;
          }
          if (power < 7) {
            power += 1;
          }
          upgradeCoolDown = upgradeCoolDown_interval;
        }
      };
    };

    //powerpool handling
    if (powerPool<powerPool_max()) {
      powerPool += powerPool_restore();
    }
    if (powerPool >= powerPool_max()) {
      if (HP < HP_max){
        HP += regenSpeed;
      }
      if (locked) {
        locked = false;
      }
    }
    cap();
    xPos += xVel;
    yPos += yVel;
    xVel *= .8;
    yVel *= .8;
  }

  //draws out player square
  void drawOut() {
    //drawing main square - red if locked, black if not
    strokeWeight(playerSize()/8);
    if (!locked) {
      stroke(0);
      fill(0, 0, 0);
    } else {
      stroke(255, 0, 0);
      fill(255, 0, 0);
    }
    rect(xPos, yPos, playerSize(), playerSize());

    //drawing four colored sides
    strokeWeight(2);
    fillWithArray(missileColors[0]);
    rect(xPos, yPos - playerSize()*3/5, playerSize(), playerSize()/6);
    fillWithArray(missileColors[1]);
    rect(xPos - playerSize()*3/5, yPos, playerSize()/6, playerSize());
    fillWithArray(missileColors[2]);
    rect(xPos, yPos + playerSize()*3/5, playerSize(), playerSize()/6);
    fillWithArray(missileColors[3]);
    rect(xPos + playerSize()*3/5, yPos, playerSize()/6, playerSize());

    //drawing power pool
    fill(255);
    int temp = playerSize()*powerPool / powerPool_max();
    rect(xPos, yPos, temp, temp);
  }

  //caps player within display boundaries, considering UI clipping
  void cap() {
    if (xPos > sWidth - playerSize()/2) {
      xPos = sWidth - playerSize()/2;
    } else if (xPos < playerSize()/2) {
      xPos = playerSize()/2;
    };
    if (yPos > sHeight - 2*marginSize - playerSize()/2) {
      yPos = sHeight - 2*marginSize - playerSize()/2;
    } else if (yPos < marginSize + playerSize()/2) {
      yPos = marginSize + playerSize()/2;
    };

    if (abs(xVel) > maxVel()) {
      xVel = maxVel()*xVel/abs(xVel);
    }
    if (abs(yVel) > maxVel()) {
      yVel = maxVel()*yVel/abs(yVel);
    }
  }

  //functions that return stats based on agl, pow etc.
  int maxVel() {
    return maxVels[agility];
  }
  int playerSize() {
    return playerSizes[agility]*sHeight/800;
  }
  int powerPool_restore() {
    return powerPool_restores[power];
  }
  int powerPool_max() {
    return powerPool_maxs[power];
  }
  int coolDown_rate() {
    return coolDown_rates[power];
  }
  int agilityCost() {
    return agilityCosts[agility];
  }
  int powerCost() {
    return powerCosts[power];
  }
  void updateMovements(boolean[] input) {
    movement = input;
  }
  void updateShooting(boolean[] input) {
    shooting = input;
  }
  void updateUpgrades(boolean[] input) {
    upgrades = input;
  }
  void updateAbilities(boolean[] input) {
    abilities = input;
  }
}

