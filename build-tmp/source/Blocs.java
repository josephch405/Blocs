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

//variables
int sWidth = 960;
int sHeight = 600;
int margin = floor(sHeight * .05f);
int status = 0;
//status: -1 -> main menu, 0 -> playing, 1 -> paused, 2 -> endgame, 3 -> help
boolean gameIsEnd = false;
int spritesPerLayer = 10;
float maxEnemies, slowMoModifier;
int[][] releaseZones;

//objects
Player player;
UIManager uiManager = new UIManager();
EnemyController enemyController;
PowerupController powerupController;
InputController inputController;// = new InputController();
Camera playerCam;

//lists of objects
ArrayList<Actor> missiles, bombs, enemies, enemies_sticky, enemies_kill, powerups;
BgSprite[] bgSprites;

//lists of variables
char[] keyMapping = {'w','a','s','d', 'q', 'e', //movement 6x
                     'i','j','k','l',           //shooting 4x
                     'z','x','c','v','b',       //upgrade 5x
                     ' ','f','r',               //abilities 3x
                     'p'};                      //pause
int[][] moveDirs = {{0,-4},{-4,0},{0,4},{4,0}};                                 //for player
int[][] missileDirs = {{0,-1},{-1,0},{0,1},{1,0}};                              //for missiles
int[][] missileColors = {{0,0,255}, {255,0,0}, {255,255,0}, {0,255,0}};         //for missiles
int[][] abilityColors = {{255,165,0}, {139,0,139}, {150,0,0}};         //for abilities
boolean[] downKeys;

public void setup(){
  frameRate(30);
  //size(sWidth,sHeight);
  size(960 ,600);

  //init background
  bgSprites = new BgSprite[40];
  for (int i = 0; i < bgSprites.length; i++){
    bgSprites[i] = new BgSprite(-floor(1+i/spritesPerLayer));
  }
  //init downkeys, based on keymapping
  downKeys = new boolean[keyMapping.length];
  for (int i = 0; i < downKeys.length; i++){
    downKeys[i] = false;
  }
  //init objects
  playerCam = new Camera(0,0);
  inputController = new InputController();
  //init lists
  status = -1;
  releaseZones = new int[][] {
    {margin, -margin*4, sWidth - margin, -margin*2}, 
    {-margin*4, margin, -margin*2, sHeight - margin}, 
    {margin, sHeight+2*margin, sWidth - margin, sHeight+4*margin}, 
    {sWidth+2*margin, margin, sWidth+4*margin, sHeight - margin}
  };
}

public void draw(){
  background(255);
  inputController.update();
  uiManager.calculate();
  switch (status){
    case 0:
      calculate_all();
      break;
    case 1:
      break;
    case 2:
      break;
    case -1:
      calculate_bg();
      break;
  }
  draw_all();
}

public void gameInit(){
  missiles = new ArrayList<Actor>();
  bombs = new ArrayList<Actor>();
  enemies = new ArrayList<Actor>();
  enemies_sticky = new ArrayList<Actor>();
  enemies_kill = new ArrayList<Actor>();
  powerups = new ArrayList<Actor>();
  enemyController = new EnemyController();
  powerupController = new PowerupController();
  status = 0;
  maxEnemies = 10;
  slowMoModifier = 1;
  player = new Player(sWidth/2, sHeight/2, 10000);
  inputController.connectInputsToPlayer();
}

/*
**CALCULATION FUNCTIONS
**
*/

public void calculate_all(){
  powerupController.update();
  player.calculate();
  //calculate distance from center of player, feeds to camera thus updating bgsprites
  playerCam.update(floor(player.xPos)-sWidth/2, floor(player.yPos)-sHeight/2);
  calculate_bg();
  enemyController.update();
  calculateActorArray(missiles);
  calculateActorArray(bombs);
}

public void calculate_bg(){
  for (int i = bgSprites.length-1; i >= 0; i--){
    bgSprites[i].wiggle();
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

/*
**DRAW FUNCTIONS
**
*/

public void draw_all(){
  fill(255);
  stroke(120);
  rectMode(CENTER);
  for (int i = bgSprites.length-1; i >= 0; i--){
    bgSprites[i].paint();
  }
  switch (status){
    case 0:
      draw_gameObjects();
      break;
    case 1:
      draw_gameObjects();
      break;
    case 2:
      draw_gameObjects();
      break;
    case -1:
      break;
  }  
  uiManager.draw_ui();
}

public void draw_gameObjects(){
  drawActorArray(enemies_kill);
  drawActorArray(enemies);
  drawActorArray(enemies_sticky);
  drawActorArray(missiles);
  drawActorArray(bombs);
  drawActorArray(powerups);
  player.drawOut();
}

public void drawActorArray(ArrayList<Actor> _array){
  for(int i = 0; i < _array.size(); i++){
    _array.get(i).drawOut();
  }
}

/*
**TRIGGER FUNCTIONS
**
*/

public void keyPressed() {
  if (findKeyIndex(key) >= 0){
    downKeys[findKeyIndex(key)] = true;
  }
}

public void keyReleased() {
  if (findKeyIndex(key) >= 0){
    downKeys[findKeyIndex(key)] = false;
  }
}

public void mousePressed(){
  uiManager.clickEvent(new int[]{mouseX, mouseY});
}

public void mouseMoved(){
  uiManager.overEvent(new int[]{mouseX, mouseY});
}

/*
**UTILITY FUNCTIONS
**
*/

public int findKeyIndex(char input){
  for (int i = 0; i < keyMapping.length; i++){
    if (keyMapping[i] == input){
      return i;
    }
  }
  return -1;
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

public boolean outOfPlayArea(float xPos, float yPos){
  if (xPos < -5*margin || xPos > sWidth + 5*margin ||yPos < -5*margin || yPos > sHeight + 5*margin) {
    return true;
  }
  return false;
}

public int[] shufflePosition() {
  int dir = floor(random(0, 4));
  int[] temp = new int[3];
  int[] temp2 = randomCoord(dir);
  temp[0] = temp2[0];
  temp[1] = temp2[1];
  temp[2] = dir;
  return temp;
}

public int[] randomCoord(int dir) {
  int tempX = floor(random(releaseZones[dir][0], releaseZones[dir][2]));
  int tempY = floor(random(releaseZones[dir][1], releaseZones[dir][3]));
  int[] temp = {
    tempX, tempY
  };
  return temp;
}
abstract class Actor{
	float xPos, yPos, xVel, yVel = 0;
	boolean active = false;
	int goldWorth = 30;
	int size = 40;

	Actor(){
		active = true;
	}

	public void calculate(){}
	public void drawOut(){}
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
  float depth = 0;

  BgSprite(int _depth){
    shuffle();
    xPos = floor(random(sWidth));
    size = 100;
    depth = _depth;
  }

  public void paint(){
    int displayX = (int)xPos;
    int displayY = (int)yPos;
    displayX += (playerCam.xPos - (xPos - sWidth/2))/(depth-1);
    displayY += (playerCam.yPos - (yPos - sHeight/2))/(depth-1);
    strokeWeight(10/-depth);
    rect(displayX, displayY, 2*size/(-depth+1),2*size/(-depth+1));
  }
  
  public void wiggle(){
    xPos -= 2;
    if (xPos < -size*2){
      shuffle();
    }
  }

  public void shuffle(){
    xPos = sWidth + random(3*size);
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
	}
}
class Camera extends Actor{
  
  Camera (int _xPos, int _yPos){
    xPos = _xPos;
    yPos = _yPos;
  }
  
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

  public void calculate() {
    if (isStickied()) {
      xPos = parent.xPos + parent.size/2 + (stickyCoords[0]-.5f)*size;
      yPos = parent.yPos + parent.size/2 + (stickyCoords[1]-.5f)*size;
      if (!parent.saturated) {
        collisionCheck_enemies();
      }
    } else {
      xPos += xVel * slowMoModifier;
      yPos += yVel * slowMoModifier;
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

  public void destroyWithAnim() {
    addGold(goldWorth);
    active = false;
    enemies_kill.add(new Enemy_kill(floor(xPos), floor(yPos), fillColor, size));
    if (isStickied()){
      parent.doCheck = true;
    }
  }

  public void unlinkWithParent(){
    parent = null;
    stickyCoords = new int[]{0,0};
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
      maxEnemies += .4f;
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
      if (isCollided(missilePos, missile.size) && missile.active) {
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

  public int[] collision_position(int _x, int _y) {
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

  public boolean isCollided_bomb(Bomb bomb) {
    int dist = floor(sqrt(sq(xPos - bomb.xPos) + sq(yPos - bomb.yPos)));
    if (dist < size/2 + bomb.size/2){
      return true;
    }
    return false;
  }
}

class EnemyController {

  int enemyLimit = 40;
  int stickyTimer = 100;

  EnemyController() {
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
    calculateActorArray(enemies);
    calculateActorArray(enemies_sticky);
    calculateActorArray(enemies_kill);
  }

  public void release(int dir) {
    int[] position = randomCoord(dir);
    enemies.add(new Enemy(position[0], position[1], 100, dir));
  }

  public void release_sticky(int dir) {
    int[] position = randomCoord(dir);
    enemies_sticky.add(new Enemy_Sticky(position[0], position[1], 100, dir));
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
    if (childList.size() > 20){
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

  public void drawOut() {
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
      maxEnemies += .2f;
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
      if (isCollided(missilePos, missile.size) && missile.active) {
        missiles.get(i).destroy();
        addGold(goldWorth);
        destroy();
        maxEnemies += .2f;
        return true;
      }
    }
    return false;
  }

  public void minionValidCheck() {
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

  public void minionValidCheck_shotgun(int[] coords){
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

  public boolean coords_nextTo(int[] _set1, int[] _set2){
    if (abs(_set1[0] - _set2[0]) + abs(_set1[1] - _set2[1]) == 1){
      return true;
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

  public boolean isCoordFree(int[] pos){
    for (int i = 0; i < childList.size(); i++){
      int[] coords = childList.get(i).stickyCoords;
      if (coords[0] == pos[0] && coords[1] == pos[1]){
        return false;
      }
    }
    return true;
  }

  public boolean addToGroup(Enemy _minion, int[] finalCoords, int type){
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
	boolean[] _movementArray = new boolean[6];
	boolean[] _shootingArray = new boolean[4];
	boolean[] _upgradesArray = new boolean[5];
	boolean[] _abilitiesArray = new boolean[3];
	boolean pauseBuffer = false;		//actual state vs released? buffer

	InputController(){
	}

	public void update(){
		arrayCopy(downKeys, 0, _movementArray, 0, 6);
		arrayCopy(downKeys, 6, _shootingArray, 0, 4);
		arrayCopy(downKeys, 10, _upgradesArray, 0, 5);
		arrayCopy(downKeys, 15, _abilitiesArray, 0, 3);
		checkPause();
	}

	public void connectInputsToPlayer(){
		player.linkControlArrays(_movementArray, _shootingArray, _upgradesArray, _abilitiesArray);
	}

	public void checkPause(){
		if (!downKeys[downKeys.length-1]){
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
	int size = sHeight/40;
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
  int maxAbilityLevel = 6;
  int[] stats = {0,0,0,0,0}; //agility, power, bomb, beserk, slowmo
  int[] upgradeCosts = {100, 120, 160, 220, 300, 400, -1};
  int rotate_lock = 0;
  int rotate_speed = 1;
  int rotate_lockFull = 3;

  //agility traits
  int[] maxVels = {
    4, 6, 8, 11, 14, 17, 20
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
  boolean bombPrimed = false;
  int bombTimeout = 10;

  int[][] powerupLimits = new int[][]{{0, 1, 2, 2, 2, 3, 3},{0, 1, 2, 2, 2, 3, 3},{0, 1, 2, 2, 2, 3, 3}};

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
    bombs.add(new Bomb((int)xPos, (int)yPos, _type, bomb_size() * margin, 30));
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

  public boolean calculate_abilities(){
    if (bombTimeout > 0){
      bombTimeout -= 1;
    }
    bombPrimed = false;
    if (abilities[0] && bombTimeout <= 0){
      int dir = -1;
      for (int i = 0; i < 4; i++) {
        if (shooting[i]) {
          dir = i;
        }
      }
      bombPrimed = true;
      if (dir >= 0 && powerupController.removeThisType(0) == true){
        fire_bomb((dir+rotate_displacement)%4);
        bombTimeout = 10;
        return true;
      }
    }
    return false;
  }

  public void calculate_movement(){
    //rotation
    if (rotate_lock == 0){
      if (movement[4]){
        rotate_displacement = (rotate_displacement+3)%4;
        rotate_lock = rotate_lockFull;
        powerPool *= .8f;
      }
      else if (movement[5]){
        rotate_displacement = (rotate_displacement+1)%4;
        rotate_lock = -rotate_lockFull;
        powerPool *= .8f;
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
    xVel *= .6f;
    yVel *= .6f;
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
    if (upgradeCoolDown <= 0) {
      for (int i = 0; i < 5; i++) {
        if (upgrades[i]) {
          if (stats[i] < maxAbilityLevel && gold >= upgradeCosts[stats[i]]) {
            gold -= upgradeCosts[stats[i]];
            stats[i] += 1;
            if (i > 1){
              powerupController.setTypeLimit(i-2, powerupLimits[i][stats[i]]);
            }
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

/*
**STAT BASED FUNCTIONS
**
*/

  public int s_agility(){
    return stats[0];
  }

  public int s_power(){
    return stats[1];
  }

  public int s_bomb(){
    return stats[2];
  }

  public int s_beserk(){
    return stats[3];
  }

  public int s_slowmo(){
    return stats[4];
  }

  public int maxVel() {
    return maxVels[s_agility()];
  }
  public int playerSize() {
    return playerSizes[s_agility()]*margin/40;
  }
  public int powerPool_restore() {
    return powerPool_restores[s_power()];
  }
  public int powerPool_max() {
    return powerPool_maxs[s_power()];
  }
  public int coolDown_rate() {
    return coolDown_rates[s_power()];
  }
  public int agilityCost() {
    return upgradeCosts[s_agility()];
  }
  public int powerCost() {
    return upgradeCosts[s_power()];
  }
  public int bombCost() {
    return upgradeCosts[s_bomb()];
  }
  public int bomb_size() {
    return bomb_sizes[s_bomb()];
  }

  public void linkControlArrays(boolean[] _movement, boolean [] _shooting, boolean[] _upgrades, boolean[] _abilities) {
    movement = _movement;
    shooting = _shooting;
    upgrades = _upgrades;
    abilities = _abilities;
  }
}

class Powerup extends Actor{
	int dir, type;
	int[] fillColor;
	boolean stickied = false;
	float dist = 2, angle = 0, dist_vel = 0, dist_vel_max = 0, angle_vel = .1f;

	Powerup(int _xPos, int _yPos, int _dir, int _type) {
		size = margin*3/4;
		xPos = _xPos;
		yPos = _yPos;
		dir = _dir;
		type = _type;
		setVels();
		active = true;
		dist_vel_max = random(.1f);
		angle_vel = random(0.02f, .1f) * pow(-1, floor(random(0,2)));
	}

	public void calculate(){
		if (!stickied){
			xPos += xVel;
			yPos += yVel;

			if (outOfPlayArea(xPos, yPos)) {
				int[] temp = shufflePosition();
				xPos = temp[0];
				yPos = temp[1];
				dir = temp[2];
				setVels();
			}
			collisionCheck_player();
		}
		else{
			dist_vel -= dist_vel_max/2 * (dist - 1.75f);
			dist += dist_vel;
			angle += angle_vel;
			xPos = player.xPos + cos(angle) * dist * 1.2f*margin;
			yPos = player.yPos + sin(angle) * dist * 1.2f*margin;
		}
	}

	public void drawOut() {
		ellipseMode(CENTER);
		strokeWeight(2);
		stroke(0);
		fillWithArray(abilityColors[type]);
		ellipse(xPos, yPos, size, size);
	}

	public void setVels() {
		xVel = (-dir+2)%2;
		yVel = (-dir+1)%2;
		if (xVel == 0) {
			yVel *= random(size/8, size/3);
		} else {
			xVel *= random(size/8, size/3);
		}
	}

	public boolean collisionCheck_player() {
		if (isCollided(new float[]{player.xPos, player.yPos}, floor(player.playerSize()*2))) {
			stickied = true;
			return true;
		}
		return false;
	}

	public boolean isCollided(float[] position, int _width) {
		if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2) {
			return true;
		}
		return false;
	}

}
class PowerupController {

  int[] powerUpLimits;
  int releaseTimer = 100;
  int tempCounter = 0;

  PowerupController() {
    powerUpLimits = new int[]{0, 0, 0};
  }

  public void update() {
    for (int i = 0; i < 3; i ++){
      if (numOfThisType(i) < powerUpLimits[i]){
        release(floor(random(1, 3)), i);
      }
    }
    calculateActorArray(powerups);
  }

  public void release(int dir, int type) {
    int[] position = randomCoord(dir);
    powerups.add(new Powerup(position[0], position[1], dir, type));
  }

  public int numOfThisType(int _type){
    int counter = 0;
    for (int i = 0; i < powerups.size(); i++){
      if (((Powerup)powerups.get(i)).type == _type){
        counter += 1;
      }
    }
    return counter;
  }

  public boolean removeThisType(int _type){
    for (int i = 0; i < powerups.size(); i++){
      if (((Powerup)powerups.get(i)).type == _type && ((Powerup)powerups.get(i)).stickied){
        powerups.remove(i);
        return true;
      }
    }
    return false;
  }

  public void setTypeLimit(int _type, int _limit){
    powerUpLimits[_type] = _limit;
  }

}
class UIComponent {
	int xPos, yPos;
	int xSize, ySize;
	int zLevel;
	boolean active = false;
	int counter;

	UIComponent(int[] pos, int[] size, int _zLevel){
		xPos = pos[0];
		yPos = pos[1];
		xSize = size[0];
		ySize = size[1];
		zLevel = _zLevel;
		active = true;
	}

	UIComponent(){
		xPos = 0;
		yPos = 0;
		xSize = 0;
		ySize = 0;
		zLevel = 0;
		active = true;
	}

	public int isOnComponent(int _zLevel, int[] _pos){
		if (active){
			if (zLevel > _zLevel){
				if (inBounds(_pos)){
					return zLevel;
				}
			}
		}
		return -1;
	}

	public void fire(){
		
	}

	public void updateCounter(int _num){
		counter = _num;
	}

	public void drawOut(){

	}

	public boolean inBounds(int[] _pos){
		if (_pos[0] > xPos && _pos[0] < xPos + xSize){
			if (_pos[1] > yPos && _pos[1] < yPos + ySize){
				return true;
			}
		}
		return false;
	}

}
class UIManager{
	UIComponent[] components = new UIComponent[6];
	boolean[] active = {false, false, false, false, false, false};
	int activeIndex = -1;
	int overIndex = -1;
	/*
	**Components:
	**	0: play button
	**	1: pause button
	**	2: help button
	**  3: help panel
	**	4: pause panel
	**  5: game over panel
	**
	*/

	UIManager(){
		components[0] = new UIComponent(new int[]{sWidth/2 - 3*margin,sHeight/2 - 3*margin} , new int[]{margin*6, margin*6}, 5);
		components[1] = new UIComponent(new int[]{sWidth - floor(1.2f*margin), floor(.2f*margin)} , new int[]{margin, margin}, 5);
		//placeholder for components
		for (int i = 2; i < components.length; i++){
			components[i] = new UIComponent();
		}
		components[5] = new UIComponent(new int[]{sWidth/2 - 5*margin,sHeight/2 - 3*margin} , new int[]{margin*10, margin*6}, 5);
	}

	public void clickEvent(int[] _pos){
		int greatestLevel = 0;
		for (int i = 0; i < components.length; i++){
			int _temp = components[i].isOnComponent(greatestLevel, _pos);
			if (_temp > greatestLevel && active[i]){
				greatestLevel = _temp;
				activeIndex = i;
			}
		}
	}

	public void overEvent(int[] _pos){
		int greatestLevel = 0;
		for (int i = 0; i < components.length; i++){
			int _temp = components[i].isOnComponent(greatestLevel, _pos);
			if (_temp > greatestLevel && active[i]){
				greatestLevel = _temp;
				overIndex = i;
			}
		}
	}

	public void calculate(){
		//toggling active component array
		switch (status){
			case 0:
				active = new boolean[]{false, true, false, false, false, false};
				break;
			//game
			case 1:
				active = new boolean[]{true, false, false, false, false, false};
				break;
			//pause
			case 2:
				active = new boolean[]{false, false, false, false, false, true};
				break;
			//end
			case -1:
				active = new boolean[]{true, false, false, false, false, false};
				break;
			//menu
		}
		//processes active UI requests
		switch (activeIndex){
			case 0:
				if (status == -1){
					gameInit();
				}
				status = 0;
				break;
			case 1:
				status = 1;
				break;
			case 5:
				gameInit();
				status = 0;
				break;
		}
		//processes mouseover UI requests
		switch (overIndex){
			case 0:
		}
		activeIndex = -1;
		overIndex = -1;
	}

	public void draw_ui(){
		if (status > -1){
			drawBars();
		}
		if (active[0]){
			drawPlayButton(components[0]);
		}
		if (active[1]){
			drawPauseButton(components[1]);
		}
		if (active[5]){
			drawEndgame(components[5]);
		}
	}

	public void drawBars(){
		rectMode(CORNER);
		stroke(0);
		strokeWeight(2);
		fill(255,0,0);
		rect(0,0, sWidth, margin/2);
		fill(0,255,0);
		rect(0,0, sWidth*((float)player.HP/player.HP_max), margin/2);

		strokeWeight(2);
		fill(255,255,255);
		rect(0,sHeight-margin, sWidth, margin);
		fill(0,0,0);

		textSize(margin/2);
		fill(255, 255, 0);
		rect(10,sHeight-margin*3/4, margin/2, margin/2);
		fill(0, 0, 0);
		text(player.gold, margin*5/3, sHeight-margin/3);

		String tempText = "LV " + player.s_agility() + " Agility ";
		if (player.agilityCost() > 0){
			tempText += "$" + player.agilityCost();
		}
		text(tempText, margin*4, sHeight-margin/3);

		tempText = "LV " + player.s_power() + " Power ";
		if (player.powerCost() > 0){
			tempText += "$" + player.powerCost();
		}
		text(tempText, margin*9, sHeight-margin/3);

		tempText = "LV " + player.s_bomb() + " Bomb ";
		if (player.bombCost() > 0){
			tempText += "$" + player.bombCost();
		}
		text(tempText, margin*14, sHeight-margin/3);

		//text("framrate: " + frameRate, 40, 80);
		//text("bomb lock: " + player.bombLock, 40, 120);
		//text("rot lock: " + player.rotate_lock, 40, 160);

		rectMode(CENTER);
	}

	public void drawPlayButton(UIComponent _compo){
		ellipseMode(CORNER);
		strokeWeight(margin/10);
		fill(255);
		stroke(0);
		ellipse(_compo.xPos, _compo.yPos, _compo.xSize, _compo.ySize);
		fill(0);
      	triangle(sWidth/2 - margin, sHeight/2 - margin*1.73f, sWidth/2 - margin, sHeight/2 + margin*1.73f, sWidth/2 + 2*margin, sHeight/2);  
	}

	public void drawPauseButton(UIComponent _compo){
		rectMode(CORNER);
		strokeWeight(margin/10);
		fill(255);
		rect(_compo.xPos, _compo.yPos, _compo.xSize, _compo.ySize);
		fill(0);
      	rect(_compo.xPos + margin * .2f, _compo.yPos + margin*.2f, margin * .2f, margin * .6f);  
      	rect(_compo.xPos + margin * .6f, _compo.yPos + margin*.2f, margin * .2f, margin * .6f);  
	}

	public void drawEndgame(UIComponent _compo){
		strokeWeight(margin/10);
		fill(255);
		rectMode(CORNER);
		rect(_compo.xPos, _compo.yPos, _compo.xSize, _compo.ySize);
		fill(0);
		textSize(20);
		text("HP == 0;\nRestart?", _compo.xPos+margin, _compo.yPos+margin, _compo.xSize, _compo.ySize);
		fill(255);
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
