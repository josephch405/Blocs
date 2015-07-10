class Player extends Thing {
  int HP, HP_max = 10000;
  int regenSpeed = 4;
  int rotate_displacement = 0;     //clockwise
  float xVel, yVel = 0;
  int gold = 0;
  boolean[] movement, shooting, upgrades, abilities;
  int rotate_lock = 0;
  int rotate_speed = 3;
  int rotate_lockFull = 30;

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

  void fire(int[] dir, int _type) {
    missiles.add(new Missile((int)xPos, (int)yPos, dir, _type));
    powerPool -= powerPool_missile;
  }

  //calculates player events during loop
  void calculate() {
    if (HP <= 0) {
      gameEnd();
    }
    calculate_movement();
    calculate_abilities();
    calculate_missileShooting();
    calculate_upgrades();
    calculate_powerPool();
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
    drawSides();
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

  void calculate_abilities(){
    if (abilities[0]){

    }

    //rotation
    if (rotate_lock <= 0){
      if (abilities[1]){
        rotate_displacement = (rotate_displacement+3)%4;
        rotate_lock = rotate_lockFull;
        powerPool *= .8;
      }
      else if (abilities[2]){
        rotate_displacement = (rotate_displacement+1)%4;
        rotate_lock = rotate_lockFull;
        powerPool *= .8;
      }
    }
    else{
      rotate_lock -= rotate_speed;
    }
  }

  void calculate_movement(){
    for (int i = 0; i < 4; i++) {
      if (movement[i]) {
        xVel += moveDirs[i][0];
        yVel += moveDirs[i][1];
      }
    }
    xPos += xVel;
    yPos += yVel;
    xVel *= .8;
    yVel *= .8;
    cap();
  }

  void calculate_missileShooting(){
    if (coolDown > 0) {
      coolDown -= coolDown_rate();
    } else if (coolDown < 0) {
      coolDown = 0;
    }
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
        fire(missileVel, getMissileType(missileVel));
        coolDown = coolDown_interval;
      };
    };
  }

  void calculate_upgrades(){
    if (upgradeCoolDown > 0) {
      upgradeCoolDown -= upgradeCoolDown_rate;
    }
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
      }
    }
  }

  void calculate_powerPool(){
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
  }

  void drawSides(){
    strokeWeight(2);
    fillWithArray(missileColors[rotate_displacement%4]);
    rect(xPos, yPos - playerSize()*3/5, playerSize(), playerSize()/6);
    fillWithArray(missileColors[(1+rotate_displacement)%4]);
    rect(xPos - playerSize()*3/5, yPos, playerSize()/6, playerSize());
    fillWithArray(missileColors[(2+rotate_displacement)%4]);
    rect(xPos, yPos + playerSize()*3/5, playerSize(), playerSize()/6);
    fillWithArray(missileColors[(3+rotate_displacement)%4]);
    rect(xPos + playerSize()*3/5, yPos, playerSize()/6, playerSize());
  }

  int getMissileType(int[] _dir){
    if (_dir[1] == 0){
      if(_dir[0]>0){
        return (3+rotate_displacement)%4;
        //right
      }
      return (1+rotate_displacement)%4;
      //left
    }
    //must have yvel at this point
    if (_dir[1] > 0){
      return (2+rotate_displacement)%4;
      //down
    }
    return (rotate_displacement)%4;
    //up
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

