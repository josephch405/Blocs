class Player extends Actor {
  int HP, HP_max = 10000;
  int regenSpeed = 4;
  int rotate_displacement = 0;     //clockwise
  int gold = 10000;
  boolean[] movement, shooting, upgrades, abilities;
  int maxAbilityLevel = 6;
  int[] stats = {0,0,0,0,0}; //agility, power, bomb, beserk, slowmo
  int[] upgradeCosts = {100, 140, 200, 280, 380, 500, -1};
  int rotate_lock = 0;
  int rotate_speed = 1;
  int rotate_lockFull = 3;

  //agility traits
  int[] maxVels = {
    2, 3, 4, 5, 6, 8, 10
  };
  int[] playerSizes = {
    66, 64, 61, 57, 52, 46, 40, 
  };

  //power traits
  int powerPool = 300;          //
  int[] powerPool_restores = {
    3, 3, 4, 4, 5, 7, 9
  };    //UPGRADABLE
  int powerPool_missile = 50;
  int[] powerPool_maxs = {
    300, 330, 370, 440, 530, 630, 740
  };           //UPGRADABLE

  //shooting vars
  boolean locked = false;
  int coolDown = 200;            //UPGRADABLE?
  int[] coolDown_rates = {
    20, 24, 30, 38, 48, 60, 74
  };
  int coolDown_interval = 200;
  int upgradeCoolDown = 2;            //UPGRADABLE?
  int upgradeCoolDown_rate = 1;
  int upgradeCoolDown_interval = 2;

  //bomb
  int[] bomb_sizes = new int[]{0, 6, 6, 8, 10, 12, 16};
  boolean bombPrimed = false, bombSwitch = false;

  //slowMo
  int[] slowMo_sizes = new int[]{0, 60, 70, 90, 110, 130, 160};
  float[] slowMo_rates = new float[]{1, .8, .7, .6, .4, .2, .05};
  int slowMo_counter = 0;
  boolean slowMo_switch = false;

  int[][] powerupLimits = new int[][]{{0, 1, 2, 2, 2, 3, 3},{0, 1, 2, 2, 2, 3, 3},{0, 1, 2, 2, 2, 3, 3}};

  Player(int _xPos, int _yPos, int _HP) {
    xPos = _xPos;
    yPos = _yPos;
    HP = _HP;
  }

  void fire(int[] dir, int _type) {
    missiles.add(new Missile((int)xPos, (int)yPos, dir, _type));
    powerPool -= powerPool_missile;
  }

  void fire_bomb(int _type) {
    bombs.add(new Bomb((int)xPos, (int)yPos, _type, bomb_size() * margin, 30));
    //powerPool -= powerPool_missile;
  }

  //calculates player events during loop
  void calculate() {
    if (HP <= 0) {
      gameEnd();
    }
    calculate_movement();
    if (!calculate_abilities()){
      calculate_missileShooting();}
      calculate_upgrades();
      calculate_powerPool();
    }

  //draws out player square
  void drawOut() {
    //drawing main square - red if locked, black if not
    pushMatrix();
    translate(xPos, yPos);
    if (rotate_lock != 0){
      pushMatrix();
      rotate(rotate_lock * PI/6);
    }
    strokeWeight(playerSize()/8);
    if (!locked) {
      stroke(0);
      fill(0, 0, 0);
    } else {
      stroke(255, 0, 0);
      fill(255, 0, 0);
    }
    rect(0, 0, playerSize(), playerSize());
    drawSides();
    //drawing power pool
    fill(255);
    int temp = playerSize()*powerPool / powerPool_max();
    rect(0, 0, temp, temp);
    if (rotate_lock != 0){
      popMatrix();
    }
    popMatrix();
    if (bombPrimed){
      stroke(0);
      fill(255);
      triangle(xPos, yPos+size/10, xPos+size/6, yPos + size/3, xPos-size/6, yPos + size/3);  
      rect(xPos, yPos - size/7, size/3, size/1.8, size/10);    
    }
  }

  //caps player within display boundaries, considering UI clipping
  void cap() {
    if (xPos > sWidth - playerSize()/2) {
      xPos = sWidth - playerSize()/2;
    } else if (xPos < playerSize()/2) {
      xPos = playerSize()/2;
    };

    if (yPos > sHeight - margin - playerSize()/2) {
      yPos = sHeight - margin - playerSize()/2;
    } else if (yPos < margin/2 + playerSize()/2) {
      yPos = margin/2 + playerSize()/2;
    };

    if (abs(xVel) > maxVel()) {
      xVel = maxVel()*xVel/abs(xVel);
    }
    if (abs(yVel) > maxVel()) {
      yVel = maxVel()*yVel/abs(yVel);
    }
  }

/*
**CALCULATE FUNCTIONS
**
*/

  boolean calculate_abilities(){
    //if bomb button state is PRESSED
    if(calculate_bomb()){
      return true;
    }

    //calculating slowmo counter
    if (slowMo_counter > 0){
      slowMo_counter -= 1;
      slowMoModifier = slowMo_rate();
    }
    else{
      slowMo_counter = 0;
      slowMoModifier = 1;
    }

    if (abilities[2]){
     if(!slowMo_switch){
        //execute slowmo
        if (powerupController.removeThisType(2) == true){
          slowMo_counter += slowMo_size();
        }
      }
      slowMo_switch = true;
    }
    else {
      slowMo_switch = false;
    }

    
    return false;
  }

  boolean calculate_bomb(){
    if (abilities[0]){
      if(!bombSwitch){
        bombPrimed = !bombPrimed;
      }
      bombSwitch = true;
    }
    else {
      bombSwitch = false;
    }
    if (bombPrimed){
      int dir = -1;
      for (int i = 0; i < 4; i++) {
        if (shooting[i]) {
          dir = i;
        }
      }
      if (dir >= 0 && powerupController.removeThisType(0)){
        fire_bomb((dir+rotate_displacement)%4);
        bombPrimed = false;
        return true;
      }
    }
    return false;
  }

  void calculate_movement(){
    //rotation
    if (rotate_lock == 0){
      if (movement[4]){
        rotate_displacement = (rotate_displacement+3)%4;
        rotate_lock = rotate_lockFull;
        powerPool *= .8;
      }
      else if (movement[5]){
        rotate_displacement = (rotate_displacement+1)%4;
        rotate_lock = -rotate_lockFull;
        powerPool *= .8;
      }
    }
    else{
      rotate_lock -= rotate_speed * (rotate_lock/abs(rotate_lock));
    }
    for (int i = 0; i < 4; i++) {
      if (movement[i]) {
        xVel += moveDirs[i][0];
        yVel += moveDirs[i][1];
      }
    }
    xPos += xVel;
    yPos += yVel;
    xVel *= .4;
    yVel *= .4;
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
    if (upgradeCoolDown <= 0) {
      for (int i = 0; i < 5; i++) {
        if (upgrades[i]) {
          if (stats[i] < maxAbilityLevel && gold >= upgradeCosts[stats[i]]) {
            gold -= upgradeCosts[stats[i]];
            stats[i] += 1;
            if (i > 1){
              powerupController.setTypeLimit(i-2, powerupLimits[i-2][stats[i]]);
            }
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
    rect(0, 0 - playerSize()*3/5, playerSize(), playerSize()/6);
    fillWithArray(missileColors[(1+rotate_displacement)%4]);
    rect(0 - playerSize()*3/5, 0, playerSize()/6, playerSize());
    fillWithArray(missileColors[(2+rotate_displacement)%4]);
    rect(0, 0 + playerSize()*3/5, playerSize(), playerSize()/6);
    fillWithArray(missileColors[(3+rotate_displacement)%4]);
    rect(0 + playerSize()*3/5, 0, playerSize()/6, playerSize());
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

/*
**STAT BASED FUNCTIONS
**
*/

  int s_agility(){
    return stats[0];
  }

  int s_power(){
    return stats[1];
  }

  int s_bomb(){
    return stats[2];
  }

  int s_beserk(){
    return stats[3];
  }

  int s_slowmo(){
    return stats[4];
  }

  int s_byIndex(int index){
    switch (index){
      case 0: 
        return s_agility();
      case 1: 
        return s_power();
      case 2: 
        return s_bomb();
      case 3: 
        return s_beserk();
      case 4: 
        return s_slowmo();
    }
    return -1;
  }

  int maxVel() {
    return maxVels[s_agility()];
  }
  int playerSize() {
    return playerSizes[s_agility()]*margin/40;
  }
  int powerPool_restore() {
    return powerPool_restores[s_power()];
  }
  int powerPool_max() {
    return powerPool_maxs[s_power()];
  }
  int coolDown_rate() {
    return coolDown_rates[s_power()];
  }
  int agilityCost() {
    return upgradeCosts[s_agility()];
  }
  int powerCost() {
    return upgradeCosts[s_power()];
  }
  int bombCost() {
    return upgradeCosts[s_bomb()];
  }
  int beserkCost() {
    return upgradeCosts[s_beserk()];
  }
  int slowmoCost() {
    return upgradeCosts[s_slowmo()];
  }
  int costByIndex(int index){
    switch (index){
      case 0: 
        return agilityCost();
      case 1: 
        return powerCost();
      case 2: 
        return bombCost();
      case 3: 
        return beserkCost();
      case 4: 
        return slowmoCost();
    }
    return -1;
  }
  int bomb_size() {
    return bomb_sizes[s_bomb()];
  }

  float slowMo_rate() {
    return slowMo_rates[s_slowmo()];
  }
  int slowMo_size() {
    return slowMo_sizes[s_slowmo()];
  }

  void linkControlArrays(boolean[] _movement, boolean [] _shooting, boolean[] _upgrades, boolean[] _abilities) {
    movement = _movement;
    shooting = _shooting;
    upgrades = _upgrades;
    abilities = _abilities;
  }
}

