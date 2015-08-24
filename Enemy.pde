class Enemy extends Actor {
  int type = 0;
  int dir = 0;
  int path = 0;
  int[] fillColor;
  boolean valid = false;
  int size = margin;
  int[] stickyCoords = {
    0, 0
  };
  Enemy_Sticky parent;


  Enemy(int _xPos, int _yPos, int _HP, int _dir) {
    goldWorth = 10;
    xPos = _xPos;
    yPos = _yPos;
    dir = _dir;
    xVel = (-dir+2)%2;
    yVel = (-dir+1)%2;
    xVel *= random(size/20, size/10);
    yVel *= random(size/20, size/10);
    type = floor(random(4));//(dir+1+floor(random(3)))%4;
    fillColor = missileColors[type];
    active = true;
  }

  void calculate() {
    if (isStickied()) {
      xPos = parent.xPos + parent.size/2 + (stickyCoords[0]-.5)*size;
      yPos = parent.yPos + parent.size/2 + (stickyCoords[1]-.5)*size;
      if (!parent.saturated) {
        collisionCheck_enemies();
      }
    } else {
      moveByVel();
      if (outOfPlayArea(xPos, yPos)) {
        destroy();
      }
    }
    if (!collisionCheck_player()) {
      if (!collisionCheck_bombs()){
        collisionCheck_missiles();
      }
    }
  }

  void destroyWithAnim() {
    addGold(goldWorth);
    active = false;
    enemies_kill.add(new Enemy_kill(floor(xPos), floor(yPos), fillColor, size));
    goldCoins.add(new GoldCoin(floor(xPos), floor(yPos)));
    if (isStickied()){
      parent.doCheck = true;
    }
  }

  void unlinkWithParent(){
    parent = null;
    stickyCoords = new int[]{0,0};
  }

  void drawOut() {
    strokeWeight(2);
    stroke(0);
    fill(fillColor[0], fillColor[1], fillColor[2]);
    rect(xPos, yPos, size, size);
  }

  //checks if within contact with a position and distance
  boolean isCollided(float[] position, int _width) {
    if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2) {
      return true;
    }
    return false;
  }

  //checks and handles collision with player
  boolean collisionCheck_player() {
    float[] playerPos = {
      player.xPos, player.yPos
    };
    if (isCollided(playerPos, player.playerSize())) {
      damagePlayer(400);
      destroyWithAnim();
      maxEnemies += .4;
      return true;
    }
    return false;
  }

  //checks and handles collision with missiles
  boolean collisionCheck_missiles() {
    for (int i = 0; i < missiles.size (); i++) {
      Missile missile = (Missile)missiles.get(i);
      float[] missilePos = {
        missile.xPos, missile.yPos
      };
      if (isCollided(missilePos, missile.size) && missile.active) {
        missiles.get(i).destroy();
        if (missile.type == type) {
          destroyWithAnim();
          maxEnemies += .4;
          return true;
        }
      }
    }
    return false;
  }

  boolean collisionCheck_bombs() {
    for (int i = 0; i < bombs.size (); i++) {
      Bomb bomb = (Bomb)bombs.get(i);
      //if (bomb.type == type) {
        if (isCollided_bomb(bomb)) {
          destroyWithAnim();
          maxEnemies += .2;
          return true;
        }
      //}
    }
    return false;
  }

  //checks if enemy if stickied to enemy_sticky
  boolean isStickied() {
    if (stickyCoords[0] == 0 && stickyCoords[1] == 0) {
      return false;
    }
    return true;
  }

  void stickTo(Enemy_Sticky _parent, int[] finalCoords) {
    parent = _parent;
    stickyCoords = finalCoords;
  }

  int collisionCheck_enemies() {
    int counter = 0;
    for (int i = 0; i < enemies.size (); i++) {
      Enemy _minion = (Enemy)enemies.get(i);
      float[] _minion_pos = {
        _minion.xPos, _minion.yPos
      };
      if (isCollided(_minion_pos, _minion.size)) {
        int[] finalCoords = collision_position(round(_minion.xPos), round(_minion.yPos));
        finalCoords[0] += stickyCoords[0];
        finalCoords[1] += stickyCoords[1];
        if(parent.addToGroup(_minion, finalCoords, type)){
          enemies.remove(i);
          i--;
          counter += 1;
        }
      }
    }
    return counter;
  }

  int[] collision_position(int _x, int _y) {
    int[] result = {
      0, 0
    };
    int deltaX = _x - round(xPos);
    int deltaY = _y - round(yPos);
    if (deltaY == 0 && deltaX == 0){
      result[0] = 1;
    }
    else if (abs(deltaY)<abs(deltaX)) {
      result[0] = deltaX/abs(deltaX);
    } else {
      result[1] = deltaY/abs(deltaY);
    }
    return result;
  }

  boolean isCollided_bomb(Bomb bomb) {
    int dist = floor(sqrt(sq(xPos - bomb.xPos) + sq(yPos - bomb.yPos)));
    if (dist < size/2 + bomb.size/2){
      return true;
    }
    return false;
  }
}

