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

//objects
int sWidth = 960;
int sHeight = 600;
Player player;// = new Player(sWidth/2, sHeight/2, 100);;
EnemyController enemyController = new EnemyController();
InputController inputController;// = new InputController();
Camera playerCam;

//lists of objects
ArrayList<Actor> missiles = new ArrayList<Actor>();
ArrayList<Actor> bombs = new ArrayList<Actor>();
ArrayList<Actor> enemies = new ArrayList<Actor>();
ArrayList<Actor> enemies_sticky = new ArrayList<Actor>();
ArrayList<Actor> enemies_kill = new ArrayList<Actor>();
BgSprite[] bgSprites;

//variables
int status = 0; //status: 0 is playing, 1 is paused, 2 is endgame, -1 is main menu?
boolean gameIsEnd = false;
int spritesPerLayer = 10;
int marginSize = 20;
float maxEnemies = 10;

//lists of variables
char[] keyMapping = {'w','a','s','d','i','j','k','l','z','x','c',' ', 'q', 'e', 'p'};    //movement 4x, shooting 4x, upgrade 3x, bomb(alt 1), pause
int[][] moveDirs = {{0,-4},{-4,0},{0,4},{4,0}};
int[][] missileDirs = {{0,-1},{-1,0},{0,1},{1,0}};
int[][] missileColors = {{0,0,255}, {255,0,0}, {255,255,0}, {0,255,0}};
boolean[] downKeys;

public void setup(){
  //init variables
  frameRate(30);
  size(960,600);
  rectMode(CENTER);
  strokeWeight(10);
  //init objects
  playerCam = new Camera(0,0);
  player = new Player(sWidth/2, sHeight/2, 10000);
  inputController = new InputController();
  //init lists
  bgSprites = new BgSprite[40];
  for (int i = 0; i < bgSprites.length; i++){
    bgSprites[i] = new BgSprite(-floor(1+i/spritesPerLayer));
  }
  downKeys = new boolean[keyMapping.length];
  for (int i = 0; i < downKeys.length; i++){
    downKeys[i] = false;
  }
}

public void draw(){
  background(255);
  stroke(120);
  inputController.update();
  if (status < 1){
    calculations();
  }
  drawCanvas();
  fill(255);
}

public void calculations(){
  player.calculate();

  //calculate distance from center of player, feeds to camera thus updating bgsprites
  playerCam.update(floor(player.xPos)-sWidth/2, floor(player.yPos)-sHeight/2);
  for (int i = bgSprites.length-1; i >= 0; i--){
    bgSprites[i].wiggle();
  }
  
  enemyController.update();

  calculateActorArray(missiles);
  calculateActorArray(bombs);
}

public void drawCanvas(){
  fill(255);
  for (int i = bgSprites.length-1; i >= 0; i--){
    bgSprites[i].paint();
  }
  drawActorArray(enemies_kill);
  drawActorArray(enemies);
  drawActorArray(enemies_sticky);
  drawActorArray(missiles);
  drawActorArray(bombs);
  player.drawOut();
  drawUI();
}

public void drawActorArray(ArrayList<Actor> _array){
  for(int i = 0; i < _array.size(); i++){
    _array.get(i).drawOut();
  }
}

public void calculateActorArray(ArrayList<Actor> _array){
  for (int i = 0; i < _array.size(); i++) {
    if (!_array.get(i).active) {
      _array.remove(i);
      i--;
    } else {
      _array.get(i).calculate();
    }
  }
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
  status = 2;
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

  //paused
  if (status == 1){
    fill(0);
    text("PAUSED", 40, 40);
  }
  text("framrate: " + frameRate, 40, 80);
  text("bomb lock: " + player.bombLock, 40, 120);
  text("rot lock: " + player.rotate_lock, 40, 160);

  rectMode(CENTER);
}

public void pause(){
  status = 1;
}

public void unpause(){
  status = 0;
}

public void togglePause(){
  if (status == 0 || status == 1){
    status = (status + 1) %2;
  }
}

public void fillWithArray(int[] temp){
  fill(temp[0], temp[1], temp[2]);
}
abstract class Actor{
	float xPos, yPos, xVel, yVel = 0;
	boolean active = false;
  	int goldWorth = 30;
  	int size = 40;


  	Actor(){
  		active = true;
  	}

  	public void calculate(){

  	}

  	public void drawOut(){

  	}

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
class BgSprite extends Actor {
  float depth = 0, xLength = 100, yLength = 100, initDepth = 1;

  BgSprite(int _depth){
    shuffle();
    xPos = floor(random(sWidth));
    depth = _depth;
    initDepth = _depth;
  }
  
  BgSprite(){}
  
  public void paint(){
    int displayX = (int)xPos;
    int displayY = (int)yPos;
    displayX += (playerCam.xPos - (xPos - sWidth/2))/(depth-1);
    displayY += 2*(playerCam.yPos- (yPos - sHeight/2))/(depth-1);
    strokeWeight(10/-depth);
    rect(displayX, displayY, 2*xLength/(-depth+1),2*yLength/(-depth+1));
  }
  
  public void wiggle(){
    xPos -= 2;
    if (xPos < -xLength*2){
      shuffle();
    }
  }

  public void shuffle(){
    xPos = sWidth + random(3*xLength);
    yPos = random(sHeight);
  }
}
class Bomb extends Actor{
	int type = 0;
	int[] dir;
	int size = 0;
	int[] fillColor;
	int timeOut = 30;
	//could alternatively use levels that controlled size and timeout

	Bomb(int _xPos, int _yPos, int _type, int _size, int _timeOut){
  		xPos = _xPos;
		yPos = _yPos;
		size = _size;
		timeOut = _timeOut;
  		active = true;
  		setType(_type);
	}

	public void drawOut(){
		strokeWeight(size/50);
		stroke(0, timeOut*255/30);
		fill(fillColor[0], fillColor[1], fillColor[2], timeOut*255/30);
		if (active){
			ellipseMode(CENTER);
  			ellipse(xPos, yPos, size, size);
  		}
	}

	public void calculate(){
		if (active){
			size *= .98f;
			timeOut -= 1;
		}
		if (timeOut <= 0){
			destroy();
		}
	}

	public void setType(int _type){
		type = _type;
		fillColor = missileColors[type];
		/*	old type generation, didn't take player rotation into account
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
		fillColor = missileColors[type];*/
	}
}
class Camera extends Actor{
  
  Camera (int _xPos, int _yPos){
    xPos = _xPos;
    yPos = _yPos;
  }
  
  Camera(){}
  
  public void update (int _xPos, int _yPos){
    xPos = (_xPos - sWidth)/3;
    yPos = (_yPos - sWidth)/3;;
  }
}
class Enemy extends Actor {
  int type = 0;
  int dir = 0;
  int path = 0;
  int[] fillColor;
  int size = sHeight/24;
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

  public void calculate() {
    if (isStickied()) {
      xPos = parent.xPos + parent.size/2 + (stickyCoords[0]-.5f)*size;
      yPos = parent.yPos + parent.size/2 + (stickyCoords[1]-.5f)*size;
      if (!parent.saturated) {
        collisionCheck_enemies();
      }
    } else {
      xPos += xVel;
      yPos += yVel;
      //destroy on leaving active area
      if (xPos < -50 || xPos > sWidth + 50 ||yPos < -50 || yPos > sHeight + 50) {
        destroy();
      }
    }
    if (!collisionCheck_player()) {
      if (!collisionCheck_bombs()){
        collisionCheck_missiles();
      }
    }
  }

  public void destroyWithAnim() {
    addGold(goldWorth);
    active = false;
    enemies_kill.add(new Enemy_kill(floor(xPos), floor(yPos), fillColor, size));
  }

  public void drawOut() {
    strokeWeight(2);
    stroke(0);
    fill(fillColor[0], fillColor[1], fillColor[2]);
    rect(xPos, yPos, size, size);
  }

  //checks if within contact with a position and distance
  public boolean isCollided(float[] position, int _width) {
    if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2) {
      return true;
    }
    return false;
  }

  //checks and handles collision with player
  public boolean collisionCheck_player() {
    float[] playerPos = {
      player.xPos, player.yPos
    };
    if (isCollided(playerPos, player.playerSize())) {
      damagePlayer(200);
      destroyWithAnim();
      return true;
    }
    return false;
  }

  //checks and handles collision with missiles
  public boolean collisionCheck_missiles() {
    for (int i = 0; i < missiles.size (); i++) {
      Missile missile = (Missile)missiles.get(i);
      float[] missilePos = {
        missile.xPos, missile.yPos
      };
      if (isCollided(missilePos, missile.size)) {
        missiles.get(i).destroy();
        if (missile.type == type) {
          destroyWithAnim();
          maxEnemies += .4f;
          return true;
        }
      }
    }
    return false;
  }

  public boolean collisionCheck_bombs() {
    for (int i = 0; i < bombs.size (); i++) {
      Bomb bomb = (Bomb)bombs.get(i);
      if (bomb.type == type) {
        if (isCollided_bomb(bomb)) {
          destroyWithAnim();
          maxEnemies += .2f;
          return true;
        }
      }
    }
    return false;
  }

  //checks if enemy if stickied to enemy_sticky
  public boolean isStickied() {
    if (stickyCoords[0] == 0 && stickyCoords[1] == 0) {
      return false;
    }
    return true;
  }

  public void stickTo(Enemy_Sticky _parent, int[] finalCoords) {
    parent = _parent;
    stickyCoords = finalCoords;
  }

  public int collisionCheck_enemies() {
    int counter = 0;
    for (int i = 0; i < enemies.size (); i++) {
      Enemy _minion = (Enemy)enemies.get(i);
      float[] _minion_pos = {
        _minion.xPos, _minion.yPos
      };
      if (isCollided(_minion_pos, _minion.size)) {
        parent.childList.add((Enemy)enemies.get(i));
        int[] finalCoords = collision_position(round(_minion.xPos), round(_minion.yPos));
        finalCoords[0] += stickyCoords[0];
        finalCoords[1] += stickyCoords[1];
        parent.childList.get(parent.childList.size()-1).stickTo(parent, finalCoords);
        parent.childList.get(parent.childList.size()-1).type = type;
        parent.childList.get(parent.childList.size()-1).fillColor = missileColors[type];;
        enemies.remove(i);
        i--;
        counter += 1;
      }
    }
    return counter;
  }

  public int[] collision_position(int _x, int _y) {
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

  public boolean isCollided_bomb(Bomb bomb) {
    int dist = floor(sqrt(sq(xPos - bomb.xPos) + sq(yPos - bomb.yPos)));
    if (dist < size/2 + bomb.size/2){
      return true;
    }
    return false;
  }
}

class EnemyController {

  int[][] releaseZones;
  int enemyLimit = 30;
  int stickyTimer = 100;

  EnemyController() {
    releaseZones = new int[][] {
      {
        0, -40, sWidth, -20
      }
      , 
      {
        -40, 0, -20, sHeight
      }
      , 
      {
        0, sHeight+20, sWidth, sHeight+40
      }
      , 
      {
        sWidth+20, 0, sWidth+40, sHeight
      }
    };
  }

  public void update() {
    if (maxEnemies > enemyLimit) {
      maxEnemies = enemyLimit;
    }

    if (enemies.size() < floor(maxEnemies)) {
      release(floor(random(0, 4)));
    }
    if (enemies_sticky.size() < floor((maxEnemies-10)/3)) {
      if (stickyTimer > 0){
        stickyTimer -= 1;
      }
      else{
        release_sticky(floor(random(0, 4)));
        stickyTimer = 100;
      }
    }
    for (int i = 0; i < enemies.size (); i++) {
      if (!enemies.get(i).active) {
        enemies.remove(i);
        i--;
      } else {
        enemies.get(i).calculate();
      }
    }
    for (int i = 0; i < enemies_sticky.size (); i++) {
      if (!enemies_sticky.get(i).active) {
        enemies_sticky.remove(i);
        i--;
      } else {
        enemies_sticky.get(i).calculate();
      }
    }

    for (int i = 0; i < enemies_kill.size (); i++) {
      if (!enemies_kill.get(i).active) {
        enemies_kill.remove(i);
        i--;
      } else {
        enemies_kill.get(i).calculate();
      }
    }
  }

  public void release(int dir) {
    int[] position = randomCoord(dir);
    enemies.add(new Enemy(position[0], position[1], 100, dir));
  }

  public void release_sticky(int dir) {
    int[] position = randomCoord(dir);
    enemies_sticky.add(new Enemy_Sticky(position[0], position[1], 100, dir));
  }

  public int[] randomCoord(int dir) {
    int tempX = floor(random(releaseZones[dir][0], releaseZones[dir][2]));
    int tempY = floor(random(releaseZones[dir][1], releaseZones[dir][3]));
    int[] bob = {
      tempX, tempY
    };
    return bob;
  }
}

class Enemy_Sticky extends Actor {
  int dir = 0;
  int path = 0;
  int[] fillColor = {
    0, 0, 0
  };
  int[] stickyCoords = {
    0, 0
  };
  float xVel = 0, yVel = 0;
  boolean saturated = false;
  ArrayList<Enemy> childList = new ArrayList<Enemy>();

  Enemy_Sticky(int _xPos, int _yPos, int _HP, int _dir) {
    size = sHeight/24;
    xPos = _xPos;
    yPos = _yPos;
    dir = _dir;
    setVels();
    active = true;
  }

  public void setVels() {
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

  public void calculate() {
    xPos += xVel;
    yPos += yVel;   

    if (xPos < -50 || xPos > sWidth + 50 ||yPos < -50 || yPos > sHeight + 50) {
      shufflePosition();
    }

    if (!collisionCheck_player()) {
      collisionCheck_missiles();
    }
    if (childList.size() > 20){
      saturated = true;
    }
    else{
      collisionCheck_enemies();
    }

    for (int i = 0; i < childList.size(); i++) {
      Enemy child = childList.get(i);
      if (!child.active) {
        childList.remove(i);
        i--;
      } else {
        child.calculate();
      }
    }
  }

  public void drawOut() {
    strokeWeight(2);
    stroke(0);
    fill(fillColor[0], fillColor[1], fillColor[2]);
    rect(xPos, yPos, size, size);
    for (int i = 0; i < childList.size (); i++) {
      Enemy child = childList.get(i);
      child.drawOut();
    }
  }

  public void shufflePosition() {
    dir = floor(random(0, 4));
    int[] temp = enemyController.randomCoord(dir);
    xPos = temp[0];
    yPos = temp[1];
    setVels();
  }

  public boolean isCollided(float[] position, int _width) {
    if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2) {
      return true;
    }
    return false;
  }

  public boolean collisionCheck_player() {
    float[] playerPos = {
      player.xPos, player.yPos
    };
    if (isCollided(playerPos, player.playerSize())) {
      damagePlayer(1000);
      destroy();
      return true;
    }
    return false;
  }

  public boolean collisionCheck_missiles() {
    for (int i = 0; i < missiles.size (); i++) {
      Missile missile = (Missile)missiles.get(i);
      float[] missilePos = {
        missile.xPos, missile.yPos
      };
      if (isCollided(missilePos, missile.size)) {
        missiles.get(i).destroy();
        addGold(goldWorth);
        destroy();
        maxEnemies += .2f;
        return true;
      }
    }
    return false;
  }

  public void destroy() {
    active = false;
    for (int i = 0; i < childList.size (); i++) {
      Enemy child = childList.get(i);
      child.destroyWithAnim();
    }
  }

  public int collisionCheck_enemies() {
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
        childList.get(childList.size()-1).stickTo(this, finalCoords);
        enemies.remove(i);
        i--;
        counter += 1;
      }
    }
    return counter;
  }

  public int[] collision_position(int _x, int _y) {
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
}

class Enemy_kill extends Actor {
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
class InputController{
	boolean[] _movementArray = new boolean[4];
	boolean[] _shootingArray = new boolean[4];
	boolean[] _upgradesArray = new boolean[4];
	boolean[] _abilitiesArray = new boolean[4];
	boolean pauseBuffer = false;		//actual state vs released? buffer


	InputController(){
		player.updateMovements(_movementArray);
		player.updateShooting(_shootingArray);
		player.updateUpgrades(_upgradesArray);
		player.updateAbilities(_abilitiesArray);
	}

	public void update(){
		arrayCopy(downKeys, 0, _movementArray, 0, 4);
		arrayCopy(downKeys, 4, _shootingArray, 0, 4);
		arrayCopy(downKeys, 8, _upgradesArray, 0, 3);
		arrayCopy(downKeys, 11, _abilitiesArray, 0, 3);
		checkPause();
	}

	public void checkPause(){
		if (!downKeys[14]){
			pauseBuffer = false;
		}
		else if (!pauseBuffer){
			togglePause();
			pauseBuffer = true;
		}
	}
}
class Layer{
  
  
  
  Layer(){
    
  }
}
class Missile extends Actor{
	int type = 0;
	int[] dir;
	int size = sHeight/55;
	int[] fillColor;
	//dir: up, left, down, right

	Missile(int _xPos, int _yPos, int[] _dir, int _type){
  		xPos = _xPos;
		yPos = _yPos;
		dir = _dir;
		xVel = dir[0]*size*2;
		yVel = dir[1]*size*2;
  		active = true;
  		setType(_type);
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
			xPos += xVel;
			yPos += yVel;
		}
		if (xPos < -10 || xPos > sWidth + 10 ||yPos < -10 || yPos > sHeight + 10){
			destroy();
		}
	}

	public void setType(int _type){
		type = _type;
		fillColor = missileColors[type];
		/*	old type generation, didn't take player rotation into account
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
		fillColor = missileColors[type];*/
	}
}

class Player extends Actor {
  int HP, HP_max = 10000;
  int regenSpeed = 4;
  int rotate_displacement = 0;     //clockwise
  int gold = 0;
  boolean[] movement, shooting, upgrades, abilities;
  int rotate_lock = 0;
  int rotate_speed = 1;
  int rotate_lockFull = 3;
  boolean bombPrimed = false;

  //agility traits
  int agility = 0;
  int[] agilityCosts = {
    100, 120, 140, 180, -1
  };
  int[] maxVels = {
    7, 8, 9, 11, 13
  };
  int[] playerSizes = {
    60, 56, 52, 48, 43
  };

  //power traits
  int power = 0;
  int[] powerCosts = {
    100, 120, 140, 180, 220, 260, 300, -1
  };
  int powerPool = 300;          //
  int[] powerPool_restores = {
    3, 4, 5, 5, 6, 6, 7, 7
  };    //UPGRADABLE
  int powerPool_missile = 50;
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

  //bomb
  int bombLock = 60;

  Player(int _xPos, int _yPos, int _HP) {
    xPos = _xPos;
    yPos = _yPos;
    HP = _HP;
  }

  public void fire(int[] dir, int _type) {
    missiles.add(new Missile((int)xPos, (int)yPos, dir, _type));
    powerPool -= powerPool_missile;
  }

  public void fire_bomb(int _type) {
    bombs.add(new Bomb((int)xPos, (int)yPos, _type, size*5, 30));
    //powerPool -= powerPool_missile;
  }

  //calculates player events during loop
  public void calculate() {
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
  public void drawOut() {
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
      rect(xPos, yPos - size/7, size/3, size/1.8f, size/10);    
    }

  }

  //caps player within display boundaries, considering UI clipping
  public void cap() {
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

  public boolean calculate_abilities(){
    bombPrimed = false;
    if (bombLock > 0){
      bombLock -= 1;
    }
    if (abilities[0]){
      int dir = -1;
      for (int i = 0; i < 4; i++) {
        if (shooting[i]) {
          dir = i;
        }
      }
      if (bombLock == 0){
        bombPrimed = true;
        if (dir >= 0){
          fire_bomb((dir+rotate_displacement)%4);
          bombLock = 60;
        }
      }
      return true;
    }

    //rotation
    if (rotate_lock == 0){
      if (abilities[1]){
        rotate_displacement = (rotate_displacement+3)%4;
        rotate_lock = rotate_lockFull;
        powerPool *= .8f;
        return true;
      }
      else if (abilities[2]){
        rotate_displacement = (rotate_displacement+1)%4;
        rotate_lock = -rotate_lockFull;
        powerPool *= .8f;
        return true;
      }
    }
    else{
      rotate_lock -= rotate_speed * (rotate_lock/abs(rotate_lock));
    }
    return false;
  }

  public void calculate_movement(){
    for (int i = 0; i < 4; i++) {
      if (movement[i]) {
        xVel += moveDirs[i][0];
        yVel += moveDirs[i][1];
      }
    }
    xPos += xVel;
    yPos += yVel;
    xVel *= .8f;
    yVel *= .8f;
    cap();
  }

  public void calculate_missileShooting(){
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

  public void calculate_upgrades(){
    if (upgradeCoolDown > 0) {
      upgradeCoolDown -= upgradeCoolDown_rate;
    }
    if (upgradeCoolDown == 0) {
      for (int i = 0; i < 3; i++) {
        if (upgrades[i]) {
          //TODO: pseudocode for upgrade
          if (agility < 4) {
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

  public void calculate_powerPool(){
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

  public void drawSides(){
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

  public int getMissileType(int[] _dir){
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
  public int maxVel() {
    return maxVels[agility];
  }
  public int playerSize() {
    return playerSizes[agility]*sHeight/800;
  }
  public int powerPool_restore() {
    return powerPool_restores[power];
  }
  public int powerPool_max() {
    return powerPool_maxs[power];
  }
  public int coolDown_rate() {
    return coolDown_rates[power];
  }
  public int agilityCost() {
    return agilityCosts[agility];
  }
  public int powerCost() {
    return powerCosts[power];
  }
  public void updateMovements(boolean[] input) {
    movement = input;
  }
  public void updateShooting(boolean[] input) {
    shooting = input;
  }
  public void updateUpgrades(boolean[] input) {
    upgrades = input;
  }
  public void updateAbilities(boolean[] input) {
    abilities = input;
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "Blocs" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
