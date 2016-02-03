//variables
int sWidth = 960;
int sHeight = 600;
int margin = floor(sHeight * .05);
int status = 0;
int score = 0;
//status: -1 -> main menu, 0 -> playing, 1 -> paused, 2 -> endgame, 3 -> help
boolean gameIsEnd = false;
int spritesPerLayer = 10;
float maxEnemies, slowMoModifier = 1;
int[][] releaseZones;
int[] bgColor = {255, 255, 255};
float slowMoFraction = 0;

//objects
Player player;
UIManager uiManager = new UIManager();
EnemyController enemyController;
PowerupController powerupController;
InputController inputController;// = new InputController();
Camera playerCam;
PImage[] powerupImages = new PImage[5];
PImage tutorial_pic;

//lists of objects
ArrayList<Actor> missiles, bombs, enemies, enemies_sticky, enemies_kill, powerups, goldCoins;
BgSprite[] bgSprites;

//lists of variables
char[] keyMapping = {'w','a','s','d', 'q', 'e', //movement 6x
                     'i','j','k','l',           //shooting 4x
                     '1','2','3','4','5',       //upgrade 5x
                     ' ','f','r',               //abilities 3x
                     'p'};                      //pause
int[][] moveDirs = {{0,-10},{-10,0},{0,10},{10,0}};                                 //for player
int[][] missileDirs = {{0,-1},{-1,0},{0,1},{1,0}};                              //for missiles
int[][] missileColors = {{0,0,255}, {255,0,0}, {255,255,0}, {0,255,0}};         //for missiles
int[][] abilityColors = {{255,165,0}, {139,0,139}, {150,0,0}};         //for abilities
boolean[] downKeys;

void setup(){
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
    {margin, -margin*8, sWidth - margin, -margin*4}, 
    {-margin*8, margin, -margin*4, sHeight - margin}, 
    {margin, sHeight+4*margin, sWidth - margin, sHeight+8*margin}, 
    {sWidth+4*margin, margin, sWidth+8*margin, sHeight - margin}
  };
  powerupImages[0] = loadImage("agility.png");
  powerupImages[1] = loadImage("power.png");
  powerupImages[2] = loadImage("bomb.png");
  powerupImages[3] = loadImage("berserk.png");
  powerupImages[4] = loadImage("slowmo.png");
  tutorial_pic = loadImage("tutorial.png");
}

void draw(){
  background(bgColor[0], bgColor[1], bgColor[2]);
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

void gameInit(){
  missiles = new ArrayList<Actor>();
  bombs = new ArrayList<Actor>();
  enemies = new ArrayList<Actor>();
  enemies_sticky = new ArrayList<Actor>();
  enemies_kill = new ArrayList<Actor>();
  goldCoins = new ArrayList<Actor>();
  powerups = new ArrayList<Actor>();
  enemyController = new EnemyController();
  powerupController = new PowerupController();
  status = 0;
  score = 0;
  maxEnemies = 10;
  slowMoModifier = 1;
  player = new Player(sWidth/2, sHeight/2, 10000);
  inputController.connectInputsToPlayer();
}

/*
**CALCULATION FUNCTIONS
**
*/

void calculate_all(){
  powerupController.update();
  player.calculate();
  //calculate distance from center of player, feeds to camera thus updating bgsprites
  playerCam.update(floor(player.xPos)-sWidth/2, floor(player.yPos)-sHeight/2);
  calculate_bg();
  enemyController.update();
  calculateActorArray(missiles);
  calculateActorArray(bombs);
}

void calculate_bg(){
  for (int i = bgSprites.length-1; i >= 0; i--){
    bgSprites[i].wiggle();
  }
  for (int i = 0; i < bgColor.length; i++){
    bgColor[i] = ceil(bgColor[i]*1.05);
  }
  if (slowMoModifier != 1){
    bgColor = new int[]{220 - floor(55*slowMoFraction), 255, 255};
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

/*
**DRAW FUNCTIONS
**
*/

void draw_all(){
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

void draw_gameObjects(){
  drawActorArray(goldCoins);
  drawActorArray(enemies_kill);
  drawActorArray(enemies);
  drawActorArray(enemies_sticky);
  drawActorArray(missiles);
  drawActorArray(bombs);
  drawActorArray(powerups);
  player.drawOut();
}

void drawActorArray(ArrayList<Actor> _array){
  for(int i = 0; i < _array.size(); i++){
    _array.get(i).drawOut();
  }
}

/*
**TRIGGER FUNCTIONS
**
*/

void keyPressed() {
  if (findKeyIndex(key) >= 0){
    downKeys[findKeyIndex(key)] = true;
  }
}

void keyReleased() {
  if (findKeyIndex(key) >= 0){
    downKeys[findKeyIndex(key)] = false;
  }
}

void mousePressed(){
  uiManager.clickEvent(new int[]{mouseX, mouseY});
}

void mouseMoved(){
  uiManager.overEvent(new int[]{mouseX, mouseY});
}

/*
**UTILITY FUNCTIONS
**
*/

int findKeyIndex(char input){
  for (int i = 0; i < keyMapping.length; i++){
    if (keyMapping[i] == input){
      return i;
    }
  }
  return -1;
}

void gameEnd(){
  status = 2;
}

void damagePlayer(int points){
  if(player.berserk_counter <= 0){
    player.HP -= points;
    bgColor = new int[]{255, 180, 180};
  }
}

void addGold(int addThis){
  player.gold += addThis;
  score += addThis;
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

boolean outOfPlayArea(float xPos, float yPos){
  if (xPos < -5*margin || xPos > sWidth + 5*margin ||yPos < -5*margin || yPos > sHeight + 5*margin) {
    return true;
  }
  return false;
}

int[] shufflePosition() {
  int dir = floor(random(0, 4));
  int[] temp = new int[3];
  int[] temp2 = randomCoord(dir);
  temp[0] = temp2[0];
  temp[1] = temp2[1];
  temp[2] = dir;
  return temp;
}

int[] randomCoord(int dir) {
  int tempX = floor(random(releaseZones[dir][0], releaseZones[dir][2]));
  int tempY = floor(random(releaseZones[dir][1], releaseZones[dir][3]));
  int[] temp = {
    tempX, tempY
  };
  return temp;
}