class Player extends Thing {
  int HP = 100;                 //health of player, restorable?
  int HP_max = 100;             //health of player, UPGRADABLE
  float xVel = 0, yVel = 0;
  int gold = 0;
  
  //agility traits
  int agility = 0;
  int[] agilityCost = {100, 120, 140, 180, 220, 260, 300, -1};
  int[] maxVel = {4, 5, 6, 8, 10, 12, 16, 20};
  int[] playerSize = {70, 66, 62, 58, 53, 47, 40, 30};

  int power = 0;
  int[] powerCost = {100, 120, 140, 180, 220, 260, 300, -1};
  int powerPool = 200;          //
  int[] powerPool_restore = {2, 2, 3, 3, 4, 4, 5, 6};    //UPGRADABLE
  int powerPool_missile = 60;
  int[] powerPool_max = {200, 240, 280, 340, 400, 460, 520, 580};           //UPGRADABLE

  boolean locked = false;
  int coolDown = 20;            //UPGRADABLE?
  int[] coolDown_rate = {1, 1, 2, 2, 2, 3, 3, 4};
  int coolDown_interval = 20;
  int upgradeCoolDown = 10;            //UPGRADABLE?
  int upgradeCoolDown_rate = 1;
  int upgradeCoolDown_interval = 10;

  Player(int _xPos, int _yPos, int _HP){
    xPos = _xPos;
    yPos = _yPos;
    HP = _HP;
  }

  void fire(int[] dir){
    missiles.add(new Missile((int)xPos, (int)yPos, dir));
    powerPool -= powerPool_missile;
  }

  //calculates player events during loop
  void calculate(){
    if (HP <= 0){
      gameEnd();
    }
    //incrementing cooldowns
    if (coolDown > 0){
      coolDown -= coolDown_rate();
    }
    else if(coolDown < 0){
      coolDown = 0;
    }
    if (upgradeCoolDown > 0){
      upgradeCoolDown -= upgradeCoolDown_rate;
    }
  	//movement
  	for (int i = 0; i < 4; i++){
     if (downKeys[i]){
       xVel += moveDirs[i][0];
       yVel += moveDirs[i][1];
     }
    }

    //fire
    if (powerPool <= 0){
      locked = true;
    }
    if (coolDown == 0 && !locked){
      int[] missileVel = {0,0};
      for (int i = 0; i < 4; i++){
        if (downKeys[i+4]){
          missileVel[0] += missileDirs[i][0];
          missileVel[1] += missileDirs[i][1];
        }
      }

      if (missileVel[0] != 0 || missileVel [1] != 0){
        fire(missileVel);
        coolDown = coolDown_interval;
      };
    };

    //upgrading handler
    if (upgradeCoolDown == 0){
      for (int i = 0; i < 3; i++){
        if (downKeys[i+8]){
          //TODO: pseudocode for upgrade
          if(agility < 7){
            agility += 1;
          }
          if(power < 7){
            power += 1;
          }
          upgradeCoolDown = upgradeCoolDown_interval;
        }
      };
    };

    if (powerPool<powerPool_max()){
      powerPool += powerPool_restore();
    }
    if (powerPool >= powerPool_max()){
      locked = false;
    }
    cap();
    xPos += xVel;
    yPos += yVel;
    xVel *= .8;
    yVel *= .8;
  }

  //draws out player square
  void drawOut(){
    //drawing main square - red if locked, black if not
    strokeWeight(playerSize()/8);
    if (!locked){
      stroke(0);
      fill(0,0,0);
    }
    else{
      stroke(255,0,0);
      fill(255,0,0);
    }
    rect(xPos, yPos, playerSize(), playerSize());

    //drawing four colored sides
    strokeWeight(2);
    fill(missileColors[0][0],missileColors[0][1],missileColors[0][2]);
    rect(xPos, yPos - playerSize()*3/5, playerSize(), playerSize()/6);
    fill(missileColors[1][0],missileColors[1][1],missileColors[1][2]);
    rect(xPos - playerSize()*3/5, yPos, playerSize()/6, playerSize());
    fill(missileColors[2][0],missileColors[2][1],missileColors[2][2]);
    rect(xPos, yPos + playerSize()*3/5, playerSize(), playerSize()/6);
    fill(missileColors[3][0],missileColors[3][1],missileColors[3][2]);
    rect(xPos + playerSize()*3/5, yPos, playerSize()/6, playerSize());

    //drawing power pool
    fill(255);
    int temp = playerSize()*powerPool / powerPool_max();
    rect(xPos, yPos, temp, temp);
  }

  //caps player within display boundaries, considering UI clipping
  void cap(){
  	if (xPos > displayWidth - playerSize()/2){
  		xPos = displayWidth - playerSize()/2;
  	}
  	else if (xPos < playerSize()/2){
  		xPos = playerSize()/2;
  	};
  	if (yPos > displayHeight - 2*marginSize - playerSize()/2){
  		yPos = displayHeight - 2*marginSize - playerSize()/2;
  	}
  	else if (yPos < marginSize + playerSize()/2){
  		yPos = marginSize + playerSize()/2;
  	};

  	if (abs(xVel) > maxVel()){
  		xVel = maxVel()*xVel/abs(xVel);
  	}
  	if (abs(yVel) > maxVel()){
  		yVel = maxVel()*yVel/abs(yVel);
  	}
  }

  //functions that return stats based on agl, pow etc.
  int maxVel(){
    return maxVel[agility];
  }
  int playerSize(){
    return playerSize[agility];
  }
  int powerPool_restore(){
    return powerPool_restore[power];
  }
  int powerPool_max(){
    return powerPool_max[power];
  }
  int coolDown_rate(){
    return coolDown_rate[power];
  }
  int agilityCost(){
    return agilityCost[agility];
  }
  int powerCost(){
    return powerCost[power];
  }
}
