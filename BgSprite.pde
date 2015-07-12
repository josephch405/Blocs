class BgSprite extends Actor {
  float depth = 0, xLength = 100, yLength = 100, initDepth = 1;

  BgSprite(int _depth){
    shuffle();
    xPos = floor(random(sWidth));
    depth = _depth;
    initDepth = _depth;
  }
  
  BgSprite(){}
  
  void paint(){
    int displayX = (int)xPos;
    int displayY = (int)yPos;
    displayX += (playerCam.xPos - (xPos - sWidth/2))/(depth-1);
    displayY += 2*(playerCam.yPos- (yPos - sHeight/2))/(depth-1);
    strokeWeight(10/-depth);
    rect(displayX, displayY, 2*xLength/(-depth+1),2*yLength/(-depth+1));
  }
  
  void wiggle(){
    xPos -= 2;
    if (xPos < -xLength*2){
      shuffle();
    }
  }

  void shuffle(){
    xPos = sWidth + random(3*xLength);
    yPos = random(sHeight);
  }
}
