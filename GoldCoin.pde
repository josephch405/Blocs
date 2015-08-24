class GoldCoin extends Actor{
  int size = 20;

  GoldCoin(int _xPos, int _yPos){
    xPos = _xPos;
    yPos = _yPos;
    active = true;
  }

  void calculate(){
  	xPos *= .9;
  	yPos = .1*sHeight + .9*yPos;
  	if (yPos > sHeight - margin){
  		destroy();
  	}
  }

  void drawOut(){
    strokeWeight(4);
    stroke(0);
    fill(255, 255, 0);
  	ellipse(xPos, yPos, size, size);
  }
}