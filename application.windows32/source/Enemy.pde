class Enemy extends Thing {
  int type = 0;
  int dir = 0;
  int path = 0;
  int[] fillColor;
  float xVel = 0, yVel = 0;
  int size = 32;
  int[] stickyCoords = {0,0};
  Enemy_Sticky parent;


  Enemy(int _xPos, int _yPos, int _HP, int _dir){
    goldWorth = 10;
    xPos = _xPos;
    yPos = _yPos;
    dir = _dir;
    xVel = (-dir+2)%2;
    yVel = (-dir+1)%2;
    xVel *= random(2,3);
    yVel *= random(2,3);
    type = (dir+1+floor(random(3)))%4;
    fillColor = missileColors[type];
    active = true;
  }

  void calculate(){
    if(isStickied()){
      xPos = parent.xPos + parent.size/2 + (stickyCoords[0]-.5)*size;
      yPos = parent.yPos + parent.size/2 + (stickyCoords[1]-.5)*size;
      collisionCheck_enemies();
    }
    else{
	     xPos += xVel;
	     yPos += yVel;
      //destroy on leaving active area
      if (xPos < -50 || xPos > sWidth + 50 ||yPos < -50 || yPos > sHeight + 50){
        destroy();
      }
    }
    if(!collisionCheck_player()){
      collisionCheck_missiles();
    }
  }

  void destroyWithAnim(){
    active = false;
    enemies_kill.add(new Enemy_kill(floor(xPos), floor(yPos), fillColor, size));
  }

  void drawOut(){
    strokeWeight(4);
    stroke(0);
    fill(fillColor[0],fillColor[1],fillColor[2]);
  	rect(xPos, yPos, size, size);
  }

  //checks if within contact with a position and distance
  boolean isCollided(float[] position, int _width){
    if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2){
      return true;
    }
    return false;
  }

  //checks and handles collision with player
  boolean collisionCheck_player(){
    float[] playerPos = {player.xPos,player.yPos};
    if(isCollided(playerPos,player.playerSize())){
      damagePlayer(10);
      destroyWithAnim();
      return true;
    }
    return false;
  }

  //checks and handles collision with missiles
  boolean collisionCheck_missiles(){
    for (int i = 0; i < missiles.size(); i++){
      Missile missile = missiles.get(i);
      float[] missilePos = {missile.xPos,missile.yPos};
      if(isCollided(missilePos,missile.size)){
        missiles.get(i).destroy();
        if (missile.type == type){
          addGold(goldWorth);
          destroyWithAnim();
          maxEnemies += .4;
          return true;
        }
      }
    }
    return false;
  }

  //checks if enemy if stickied to enemy_sticky
  boolean isStickied(){
    if (stickyCoords[0] == 0 && stickyCoords[1] == 0){
      return false;
    }
    return true;
  }
  
  void stickTo(Enemy_Sticky _parent, int[] finalCoords){
    parent = _parent;
    stickyCoords = finalCoords;
  }

  int collisionCheck_enemies(){
    int counter = 0;
    for (int i = 0; i < enemies.size(); i++){
      Enemy _minion = enemies.get(i);
      float[] _minion_pos = {_minion.xPos,_minion.yPos};
      if(isCollided(_minion_pos, _minion.size)){
        parent.childList.add(enemies.get(i));
        int[] finalCoords = collision_position(round(_minion.xPos), round(_minion.yPos));
        finalCoords[0] += stickyCoords[0];
        finalCoords[1] += stickyCoords[1];
        parent.childList.get(parent.childList.size()-1).stickTo(parent, finalCoords);
        //parent.childList.get(parent.childList.size()-1).type = type;
        //parent.childList.get(parent.childList.size()-1).fillColor = missileColors[type];;
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
