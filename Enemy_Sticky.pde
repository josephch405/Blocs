class Enemy_Sticky extends Actor {
  int dir = 0;
  int path = 0;
  int[] fillColor = {
    0, 0, 0
  };
  int[] stickyCoords = {
    0, 0
  };
  boolean saturated = false;
  boolean doCheck = false;
  ArrayList<Enemy> childList = new ArrayList<Enemy>();

  Enemy_Sticky(int _xPos, int _yPos, int _HP, int _dir) {
    size = margin;
    xPos = _xPos;
    yPos = _yPos;
    dir = _dir;
    setVels();
    active = true;
  }

  void setVels() {
    xVel = (-dir+2)%2;
    yVel = (-dir+1)%2;
    if (xVel == 0) {
      yVel *= random(size/8, size/3);
      //xVel = random(-size/5, size/5);
    } else {
      xVel *= random(size/8, size/3);
      //yVel = random(-size/5, size/5);
    }
  }

  void calculate() {
    //moveByVel();
    moveByVel();
    if (outOfPlayArea(xPos, yPos)) {
      int[] temp = shufflePosition();
      xPos = temp[0];
      yPos = temp[1];
      dir = temp[2];
      setVels();
    }

    if (!collisionCheck_player()) {
      collisionCheck_missiles();
    }
    if (childList.size() > 20 || !active){
      saturated = true;
    }
    else{
      saturated = false;
      collisionCheck_enemies();
    }

    for (int i = 0; i < childList.size(); i++) {
      Enemy child = childList.get(i);
      if (!child.active) {
        childList.remove(i);
        i--;
      } else {
        child.calculate();
        if (!child.active) {
          childList.remove(i);
          i--;
        }
      }
    }

    if (doCheck){
      doCheck = false;
      minionValidCheck();
    }
  }

  void drawOut() {
    strokeWeight(2);
    stroke(0);
    fill(100);
    if (saturated){
      fill(0);
    }
    rect(xPos, yPos, size, size);
    for (int i = 0; i < childList.size (); i++) {
      Enemy child = childList.get(i);
      child.drawOut();
    }
  }

  boolean isCollided(float[] position, int _width) {
    if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2) {
      return true;
    }
    return false;
  }

  boolean collisionCheck_player() {
    float[] playerPos = {
      player.xPos, player.yPos
    };
    if (isCollided(playerPos, player.playerSize())) {
      damagePlayer(200);
      destroy();
      maxEnemies += .2;
      return true;
    }
    return false;
  }

  boolean collisionCheck_missiles() {
    for (int i = 0; i < missiles.size (); i++) {
      Missile missile = (Missile)missiles.get(i);
      float[] missilePos = {
        missile.xPos, missile.yPos
      };
      if (isCollided(missilePos, missile.size) && missile.active) {
        missiles.get(i).destroy();
        addGold(goldWorth);
        destroy();
        maxEnemies += .2;
        return true;
      }
    }
    return false;
  }

  void minionValidCheck() {
    //resets all valid bits
    for (int i = 0; i < childList.size(); i++){
      childList.get(i).valid = false;
    }
    minionValidCheck_shotgun(new int[]{0,0});
    for (int i = 0; i < childList.size(); i++){
      if (childList.get(i).valid == false){
        Enemy temp = childList.get(i);
        enemies.add(temp);
        childList.remove(i);
        temp.unlinkWithParent();
        i--;
      }
    }
  }

  void minionValidCheck_shotgun(int[] coords){
    int counter = 0;
    for (int i = 0; i < childList.size(); i++){
      if (coords_nextTo(childList.get(i).stickyCoords, coords) && !childList.get(i).valid){
        childList.get(i).valid = true;
        minionValidCheck_shotgun(childList.get(i).stickyCoords);
        counter++;
        if (counter == 4){
          return;
        }
      }
    }
  }

  boolean coords_nextTo(int[] _set1, int[] _set2){
    if (abs(_set1[0] - _set2[0]) + abs(_set1[1] - _set2[1]) == 1){
      return true;
    }
    return false;
  }

  void destroy() {
    active = false;
    for (int i = 0; i < childList.size(); i++) {
      Actor child = childList.get(i);
      //child.destroyWithAnim();
      enemies.add(child);
      childList.remove(i);
      Enemy temp = (Enemy)child;
      temp.unlinkWithParent();
      i--;
    }
  }

  int collisionCheck_enemies() {
    int counter = 0;
    for (int i = 0; i < enemies.size (); i++) {
      Enemy _minion = (Enemy)enemies.get(i);
      float[] _minion_pos = {
        _minion.xPos, _minion.yPos
      };
      if (isCollided(_minion_pos, _minion.size)) {
        childList.add((Enemy)enemies.get(i));
        int[] finalCoords = collision_position(round(_minion.xPos), round(_minion.yPos));
        finalCoords[0] += stickyCoords[0];
        finalCoords[1] += stickyCoords[1];

        if (addToGroup(_minion, finalCoords, _minion.type)){
          childList.get(childList.size()-1).stickTo(this, finalCoords);
          enemies.remove(i);
          i--;
        }
        counter += 1;
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
    if (abs(deltaY)<abs(deltaX)) {
      result[0] = deltaX/abs(deltaX);
    } else {
      result[1] = deltaY/abs(deltaY);
    }
    return result;
  }

  boolean isCoordFree(int[] pos){
    for (int i = 0; i < childList.size(); i++){
      int[] coords = childList.get(i).stickyCoords;
      if (coords[0] == pos[0] && coords[1] == pos[1]){
        return false;
      }
    }
    return true;
  }

  boolean addToGroup(Enemy _minion, int[] finalCoords, int type){
    if (isCoordFree(finalCoords)){
      childList.add(_minion);
      _minion.stickTo(this, finalCoords);
      _minion.type = type;
      _minion.fillColor = missileColors[type];
      return true;
    }
    return false;
  }
}

