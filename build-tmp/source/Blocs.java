import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Blocs extends PApplet {

Player player;
int sWidth, sHeight;
EnemyController enemyController = new EnemyController();
Camera playerCam;
boolean gameIsEnd = false;
char[] keyMapping = {'w','a','s','d','i','j','k','l','z','x','c'};
int[][] moveDirs = {{0,-2},{-2,0},{0,2},{2,0}};
int[][] missileDirs = {{0,-18},{-18,0},{0,18},{18,0}};
int[][] missileColors = {{0,0,255}, {255,0,0}, {255,255,0}, {0,255,0}};
BgSprite[] bgSprites;
boolean[] downKeys;
ArrayList<Missile> missiles = new ArrayList<Missile>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Missile_kill> missiles_kill = new ArrayList<Missile_kill>();
ArrayList<Enemy_kill> enemies_kill = new ArrayList<Enemy_kill>();
int marginSize = 20;
float maxEnemies = 5;

public void setup(){
  sWidth = displayWidth;
  sHeight = displayHeight;
  rectMode(CENTER);
  enemyController = new EnemyController();
  playerCam = new Camera(0,0);
  bgSprites = new BgSprite[40];
  for (int i = 0; i < 40; i++){
    bgSprites[i] = new BgSprite(floor(random(displayWidth)),floor(random(displayHeight)),-floor(1+i/8));
  }
  downKeys = new boolean[11];
  for (int i = 0; i < downKeys.length; i++){
    downKeys[i] = false;
  }
  size(displayWidth, displayHeight);
  strokeWeight(10);
  player = new Player(displayWidth/2, displayHeight/2, 100);
}

public void draw(){
  background(255);
  stroke(120);
  if (!gameIsEnd){
    step();
  }
  drawCanvas();
  fill(255);
}

public void step(){
  playerCam.update(floor(player.xPos)-displayWidth/2, floor(player.yPos)-displayHeight/2);
  enemyController.update();
  player.calculate();
    for (int i = bgSprites.length-1; i >= 0; i--){
    bgSprites[i].wiggle();
  }
  for(int i = 0; i < missiles.size(); i++){
    if (!missiles.get(i).active){
      missiles.remove(i);
      i--;
    }
    else{
      missiles.get(i).calculate();
    }
  }
  for(int i = 0; i < enemies.size(); i++){
    if (!enemies.get(i).active){
      enemies.remove(i);
      i--;
    }
    else{
      enemies.get(i).calculate();
    }
  }

  for(int i = 0; i < enemies_kill.size(); i++){
    if (!enemies_kill.get(i).active){
      enemies_kill.remove(i);
      i--;
    }
    else{
      enemies_kill.get(i).calculate();
    }
  }
}

public void drawCanvas(){
  for (int i = bgSprites.length-1; i >= 0; i--){
    bgSprites[i].paint();
  }
  for(int i = 0; i < enemies_kill.size(); i++){
    enemies_kill.get(i).drawOut();
  }
  for(int i = 0; i < enemies.size(); i++){
    enemies.get(i).drawOut();
  }
  for(int i = 0; i < missiles.size(); i++){
    missiles.get(i).drawOut();
  }
  player.drawOut();
  drawUI();
}

public int findInKeyMapping(char input){
  for (int i = 0; i < keyMapping.length; i++){
    if (keyMapping[i] == input){
      return i;
    }
  }
  return -1;
}


public void keyPressed() {
  if (findInKeyMapping(key) >= 0){
    downKeys[findInKeyMapping(key)] = true;
  }
}

public void keyReleased() {
  if (findInKeyMapping(key) >= 0){
    downKeys[findInKeyMapping(key)] = false;
  }
}

public void gameEnd(){
  gameIsEnd = true;
}

public void damagePlayer(int points){
  player.HP -= points;
}

public void addGold(int addThis){
  player.gold += addThis;
}

public void drawUI(){
  //player health bar
  rectMode(CORNER);
  stroke(0);
  strokeWeight(2);
  fill(255,0,0);
  rect(0,0, sWidth, marginSize);
  fill(0,255,0);
  rect(0,0, sWidth*((float)player.HP/player.HP_max), marginSize);
  
  //
  //upgrades bar
  strokeWeight(2);
  fill(255,255,255);
  rect(0,sHeight-40, sWidth, 2*marginSize);
  fill(0,0,0);

  //gold
  textSize(marginSize);
  fill(255, 255, 0);
  rect(10,sHeight-30, marginSize, marginSize);
  fill(0, 0, 0);
  text(player.gold, 50, sHeight-10);

  //agility status
  String tempText = "LV " + player.agility + " Agility ";
  if (player.agilityCost() > 0){
    tempText += "$" + player.agilityCost();
  }
  text(tempText, 100, sHeight-10);

  //power status
  tempText = "LV " + player.power + " Power ";
  if (player.powerCost() > 0){
    tempText += "$" + player.powerCost();
  }
  text(tempText, 300, sHeight-10);

  rectMode(CENTER);

}
class BgSprite extends Thing {
  float depth = 0, xLength = 100, yLength = 100, initDepth = 1;

  BgSprite(int _xPos, int _yPos, int _depth){
    xPos = _xPos;
    yPos = _yPos;
    depth = _depth;
    initDepth = _depth;
  }
  
  BgSprite(){}
  
  public void paint(){
    int displayX = (int)xPos;
    int displayY = (int)yPos;
    displayX += (playerCam.xPos - (xPos - displayWidth/2))/(depth-1);
    displayY += (playerCam.yPos- (yPos - displayHeight/2))/(depth-1);
    strokeWeight(10/-depth);
    rect(displayX, displayY, 2*xLength/sqrt(-depth+1),2*yLength/sqrt(-depth+1));
  }
  
  public void wiggle(){
    xPos -= 2;
    if (xPos < -xLength*2){
      xPos = displayWidth + random(3*xLength);
      yPos = random(displayHeight);
    }
  }
}
class Camera extends Thing{
  
  Camera (int _xPos, int _yPos){
    xPos = _xPos;
    yPos = _yPos;
  }
  
  Camera(){}
  
  public void update (int _xPos, int _yPos){
    xPos = (_xPos - displayWidth)/3;
    yPos = (_yPos - displayWidth)/3;;
  }
}
class Enemy extends Thing {
  int type = 0;
  int dir = 0;
  int path = 0;
  int[] fillColor;
  float xVel = 0, yVel = 0;
  int size = 40;
  int goldWorth = 10;

  Enemy(int _xPos, int _yPos, int _HP, int _dir){
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

  public void calculate(){
	  xPos += xVel;
	  yPos += yVel;
    if (xPos < -50 || xPos > displayWidth + 50 ||yPos < -50 || yPos > displayHeight + 50){
      destroy();
    }
    float[] playerPos = {player.xPos,player.yPos};
    if(isCollided(playerPos,player.playerSize())){
      damagePlayer(10);
      destroyWithAnim();
    }
    for (int i = 0; i < missiles.size(); i++){
      Missile missile = missiles.get(i);
      float[] missilePos = {missile.xPos,missile.yPos};
      if(isCollided(missilePos,missile.size)){
        missiles.get(i).destroy();
        if (missile.type == type){
          addGold(goldWorth);
          destroyWithAnim();
          //TEMP
          maxEnemies += .2f;
        }
      }
    }
  }

  public void destroyWithAnim(){
    active = false;
    enemies_kill.add(new Enemy_kill(floor(xPos), floor(yPos), fillColor, size));
  }

  public void drawOut(){
    strokeWeight(4);
    stroke(0);
    fill(fillColor[0],fillColor[1],fillColor[2]);
  	rect(xPos, yPos, size, size);
  }

  public boolean isCollided(float[] position, int _width){
    if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2){
      return true;
    }
    return false;
  }
}
class EnemyController {
	
	int[][] releaseZones;

	EnemyController(){
		releaseZones = new int[][]{
			{0,-40,sWidth,-20},
			{-40,0,-20,sHeight},
			{0,sHeight+20,sWidth,sHeight+40},
			{sWidth+20,0,sWidth+40,sHeight}
		};
	}

	public void update(){
		if (enemies.size() < floor(maxEnemies)){
			release(floor(random(0,4)));
		}
	}

	public void release(int dir){
		int[] position = randomCoord(dir);
		enemies.add(new Enemy(position[0],position[1],100,dir));
	}

	public int[] randomCoord(int dir){
		int tempX = floor(random(releaseZones[dir][0],releaseZones[dir][2]));
		int tempY = floor(random(releaseZones[dir][1],releaseZones[dir][3]));
		int[] bob = {tempX, tempY};
		return bob;
	}

}
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

  public void calculate(){
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
          maxEnemies += .2f;
        }
      }
    }
  }

  public void drawOut(){
    strokeWeight(4);
    stroke(0);
    fill(fillColor[0],fillColor[1],fillColor[2]);
  	rect(xPos, yPos, size, size);
  }

  public boolean isCollided(float[] position, int _width){
    if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2){
      return true;
    }
    return false;
  }
}
class Enemy_kill extends Thing {
  int[] fillColor;
  int size = 40;
  int timer = 10;

  Enemy_kill(int _xPos, int _yPos, int[] _fillColor, int _size){
    xPos = _xPos;
    yPos = _yPos;
    fillColor = _fillColor;
    active = true;
    size = _size;
  }

  public void calculate(){
    timer -= 1;
    size += 4;
    if(timer <= 0){
      destroy();
    }
  }

  public void drawOut(){
    strokeWeight(4);
    stroke(0, 255*timer/10);
    fill(fillColor[0],fillColor[1],fillColor[2], timer*255/10);
  	rect(xPos, yPos, size, size);
  }
}
class Layer{
  
  
  
  Layer(){
    
  }
}
class Missile extends Thing{

	int type = 0;
	int[] dir;
	int size = 20;
	int[] fillColor;
	//dir: up, left, down, right

	Missile(int _xPos, int _yPos, int[] _dir){
  		xPos = _xPos;
		yPos = _yPos;
		dir = _dir;
  		active = true;
  		setType();
	}

	public void drawOut(){
		strokeWeight(2);
		stroke(0);
		fill(fillColor[0], fillColor[1], fillColor[2]);
		if (active){
  			rect(xPos, yPos, size, size);
  		}
	}

	public void calculate(){
		if (active){
			xPos += dir[0];
			yPos += dir[1];
		}
		if (xPos < -10 || xPos > displayWidth + 10 ||yPos < -10 || yPos > displayHeight + 10){
			destroy();
		}
	}

	public void destroy(){
		active = false;
	}

	public void setType(){
		type = 3;
		if (dir[1] == 0 && dir[0] < 0){
			type = 1;
		}
		else if (dir[1] > 0){
			type = 2;
		}
		else if (dir[1] < 0){
			type = 0;
		}
		fillColor = missileColors[type];
	}
}
class Missile_kill extends Thing{

	int type = 0;
	int[] dir;
	int size = 20;
	int[] fillColor;
	//dir: up, left, down, right

	Missile_kill(int _xPos, int _yPos, int[] _dir){
  		xPos = _xPos;
		yPos = _yPos;
		dir = _dir;
  		active = true;
  		setType();
	}

	public void drawOut(){
		strokeWeight(2);
		stroke(0);
		fill(fillColor[0], fillColor[1], fillColor[2]);
		if (active){
  			rect(xPos, yPos, size, size);
  		}
	}

	public void calculate(){
		if (active){
			xPos += dir[0];
			yPos += dir[1];
		}
		if (xPos < -10 || xPos > displayWidth + 10 ||yPos < -10 || yPos > displayHeight + 10){
			destroy();
		}
	}

	public void destroy(){
		active = false;
	}

	public void setType(){
		type = 3;
		if (dir[1] == 0 && dir[0] < 0){
			type = 1;
		}
		else if (dir[1] > 0){
			type = 2;
		}
		else if (dir[1] < 0){
			type = 0;
		}
		fillColor = missileColors[type];
	}
}
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

  public void fire(int[] dir){
    missiles.add(new Missile((int)xPos, (int)yPos, dir));
    powerPool -= powerPool_missile;
  }

  public void calculate(){
    if (HP <= 0){
      gameEnd();
    }
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

    if (upgradeCoolDown == 0){
      for (int i = 0; i < 3; i++){
        if (downKeys[i+8]){
          //pseudocode for upgrade
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
	  xVel *= .8f;
	  yVel *= .8f;
   }

  public void drawOut(){
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

    strokeWeight(2);
    fill(missileColors[0][0],missileColors[0][1],missileColors[0][2]);
    rect(xPos, yPos - playerSize()*3/5, playerSize(), playerSize()/6);
    fill(missileColors[1][0],missileColors[1][1],missileColors[1][2]);
    rect(xPos - playerSize()*3/5, yPos, playerSize()/6, playerSize());
    fill(missileColors[2][0],missileColors[2][1],missileColors[2][2]);
    rect(xPos, yPos + playerSize()*3/5, playerSize(), playerSize()/6);
    fill(missileColors[3][0],missileColors[3][1],missileColors[3][2]);
    rect(xPos + playerSize()*3/5, yPos, playerSize()/6, playerSize());

    fill(255);
    int temp = playerSize()*powerPool / powerPool_max();
    rect(xPos, yPos, temp, temp);
  }

  public void cap(){
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

  public int maxVel(){
    return maxVel[agility];
  }
  public int playerSize(){
    return playerSize[agility];
  }
  public int powerPool_restore(){
    return powerPool_restore[power];
  }
  public int powerPool_max(){
    return powerPool_max[power];
  }
  public int coolDown_rate(){
    return coolDown_rate[power];
  }
  public int agilityCost(){
    return agilityCost[agility];
  }
  public int powerCost(){
    return powerCost[power];
  }
}
class Thing{
	
	float xPos = 0, yPos = 0;
	boolean active = false;

	public void move(int dx, int dy){
	  	xPos += dx;
	  	yPos += dy;
  	}

  	public void setPosition(int _x, int _y){
	  	xPos = _x;
	  	yPos = _y;
  	}

	public void destroy(){
		active = false;
	}

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Blocs" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
