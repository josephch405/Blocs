class Enemy_Sticky extends Thing {
  int type = 0;
  int dir = 0;
  int path = 0;
  int[] fillColor = {0, 0, 0};
  int[] stickyCoords = {0,0};
  float xVel = 0, yVel = 0;
  ArrayList<Enemy> childList = new ArrayList<Enemy>();

  Enemy_Sticky(int _xPos, int _yPos, int _HP, int _dir){
    size = 32;
    xPos = _xPos;
    yPos = _yPos;
    dir = _dir;
    xVel = (-dir+2)%2;
    yVel = (-dir+1)%2;
    xVel *= random(2,3);
    yVel *= random(2,3);
    type = (dir+1+floor(random(3)))%4;
    active = true;
  }

  void calculate(){
	  xPos += xVel;
	  yPos += yVel;   

    if (xPos < -50 || xPos > displayWidth + 50 ||yPos < -50 || yPos > displayHeight + 50){
      shufflePosition();
    }
    
    if(!collisionCheck_player()){
      collisionCheck_missiles();
    }
    collisionCheck_enemies();

    for (int i = 0; i < childList.size(); i++){
      Enemy child = childList.get(i);
      if (!child.active){
        childList.remove(i);
        i--;
      }
      else{
        child.calculate();
      }
    }
  }

  void drawOut(){
    strokeWeight(4);
    stroke(0);
    fill(fillColor[0],fillColor[1],fillColor[2]);
  	rect(xPos, yPos, size, size);
    for (int i = 0; i < childList.size(); i++){
      Enemy child = childList.get(i);
      child.drawOut();
    }
  }

  void shufflePosition(){
    int dir = floor(random(0,4));
    int[] temp = enemyController.randomCoord(dir);
    xPos = temp[0];
    yPos = temp[1];
    xVel = (-dir+2)%2;
    yVel = (-dir+1)%2;
    xVel *= random(2,3);
    yVel *= random(2,3);
  }

  boolean isCollided(float[] position, int _width){
    if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2){
      return true;
    }
    return false;
  }

  boolean collisionCheck_player(){
    float[] playerPos = {player.xPos,player.yPos};
    if(isCollided(playerPos,player.playerSize())){
      damagePlayer(10);
      destroy();
      return true;
    }
    return false;
  }

  boolean collisionCheck_missiles(){
    for (int i = 0; i < missiles.size(); i++){
      Missile missile = missiles.get(i);
      float[] missilePos = {missile.xPos,missile.yPos};
      if(isCollided(missilePos,missile.size)){
        missiles.get(i).destroy();
        addGold(goldWorth);
        destroy();
        maxEnemies += .2;
        return true;
      }
    }
    return false;
  }

  void destroy(){
    active = false;
    for (int i = 0; i < childList.size(); i++){
      Enemy child = childList.get(i);
      child.destroyWithAnim();
    }
  }

  int collisionCheck_enemies(){
    int counter = 0;
    for (int i = 0; i < enemies.size(); i++){
      Enemy _minion = enemies.get(i);
      float[] _minion_pos = {_minion.xPos,_minion.yPos};
      if(isCollided(_minion_pos, _minion.size)){
        childList.add(enemies.get(i));
        int[] finalCoords = collision_position(round(_minion.xPos), round(_minion.yPos));
        finalCoords[0] += stickyCoords[0];
        finalCoords[1] += stickyCoords[1];
        childList.get(childList.size()-1).stickTo(this, finalCoords);
        enemies.remove(i);
        i--;
        counter += 1;
      }
    }
    return counter;
  }

  int[] collision_position(int _x, int _y){
    int[] result = {0,0};
    int deltaX = _x - round(xPos);
    int deltaY = _y - round(yPos);
    if(abs(deltaY)<abs(deltaX)){
      result[0] = deltaX/abs(deltaX);
    }
    else{
      result[1] = deltaY/abs(deltaY);
    }
    return result;
  }
}
