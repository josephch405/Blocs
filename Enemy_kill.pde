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

  void calculate(){
    timer -= 1;
    size += 4;
    if(timer <= 0){
      destroy();
    }
  }

  void drawOut(){
    strokeWeight(4);
    stroke(0, 255*timer/10);
    fill(fillColor[0],fillColor[1],fillColor[2], timer*255/10);
  	rect(xPos, yPos, size, size);
  }
}
