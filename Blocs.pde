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

void setup(){
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

void draw(){
  background(255);
  stroke(120);
  inputController.update();
  if (status < 1){
    calculations();
  }
  drawCanvas();
  fill(255);
}

void calculations(){
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

void drawCanvas(){
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

void drawActorArray(ArrayList<Actor> _array){
  for(int i = 0; i < _array.size(); i++){
    _array.get(i).drawOut();
  }
}

void calculateActorArray(ArrayList<Actor> _array){
  for (int i = 0; i < _array.size(); i++) {
    if (!_array.get(i).active) {
      _array.remove(i);
      i--;
    } else {
      _array.get(i).calculate();
    }
  }
}

int findInKeyMapping(char input){
  for (int i = 0; i < keyMapping.length; i++){
    if (keyMapping[i] == input){
      return i;
    }
  }
  return -1;
}

void keyPressed() {
  if (findInKeyMapping(key) >= 0){
    downKeys[findInKeyMapping(key)] = true;
  }
}

void keyReleased() {
  if (findInKeyMapping(key) >= 0){
    downKeys[findInKeyMapping(key)] = false;
  }
}

void gameEnd(){
  status = 2;
}

void damagePlayer(int points){
  player.HP -= points;
}

void addGold(int addThis){
  player.gold += addThis;
}

void drawUI(){
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

void pause(){
  status = 1;
}

void unpause(){
  status = 0;
}

void togglePause(){
  if (status == 0 || status == 1){
    status = (status + 1) %2;
  }
}

void fillWithArray(int[] temp){
  fill(temp[0], temp[1], temp[2]);
}
