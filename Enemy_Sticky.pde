class Enemy_Sticky extends Thing {
  int type = 0;
  int dir = 0;
  int path = 0;
  int[] fillColor = {255, 255, 255};
  float xVel = 0, yVel = 0;
  int size = 40;
  int goldWorth = 30;

  Enemy_Sticky(int _xPos, int _yPos, int _HP, int _dir){
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
      destroy();
    }
    float[] playerPos = {player.xPos,player.yPos};
    if(isCollided(playerPos,player.playerSize())){
      damagePlayer(10);
      destroy();
    }
    for (int i = 0; i < missiles.size(); i++){
      Missile missile = missiles.get(i);
      float[] missilePos = {missile.xPos,missile.yPos};
      if(isCollided(missilePos,missile.size)){
        missiles.get(i).destroy();
        if (missile.type == type){
          addGold(goldWorth);
          destroy();
          //TEMP
          maxEnemies += .2;
        }
      }
    }
  }

  void drawOut(){
    strokeWeight(4);
    stroke(0);
    fill(fillColor[0],fillColor[1],fillColor[2]);
  	rect(xPos, yPos, size, size);
  }

  boolean isCollided(float[] position, int _width){
    if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2){
      return true;
    }
    return false;
  }
}
