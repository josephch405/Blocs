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
ArrayList<Enemy_Sticky> enemies_sticky = new ArrayList<Enemy_Sticky>();
ArrayList<Missile_kill> missiles_kill = new ArrayList<Missile_kill>();
ArrayList<Enemy_kill> enemies_kill = new ArrayList<Enemy_kill>();
int marginSize = 20;
float maxEnemies = 20;

void setup(){
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

void draw(){
  background(255);
  stroke(120);
  if (!gameIsEnd){
    step();
  }
  drawCanvas();
  fill(255);
}

void step(){
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
  for(int i = 0; i < enemies_sticky.size(); i++){
    if (!enemies_sticky.get(i).active){
      enemies_sticky.remove(i);
      i--;
    }
    else{
      enemies_sticky.get(i).calculate();
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

void drawCanvas(){
  fill(255);
  for (int i = bgSprites.length-1; i >= 0; i--){
    bgSprites[i].paint();
  }
  for(int i = 0; i < enemies_kill.size(); i++){
    enemies_kill.get(i).drawOut();
  }
  for(int i = 0; i < enemies.size(); i++){
    enemies.get(i).drawOut();
  }
  for(int i = 0; i < enemies_sticky.size(); i++){
    enemies_sticky.get(i).drawOut();
  }
  for(int i = 0; i < missiles.size(); i++){
    missiles.get(i).drawOut();
  }
  player.drawOut();
  drawUI();
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
  gameIsEnd = true;
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

  rectMode(CENTER);

}