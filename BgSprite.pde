class BgSprite extends Actor {
  float depth = 0;

  BgSprite(int _depth){
    shuffle();
    xPos = floor(random(sWidth));
    size = 100;
    depth = _depth;
  }

  void paint(){
    int displayX = (int)xPos;
    int displayY = (int)yPos;
    displayX += (playerCam.xPos - (xPos - sWidth/2))/(depth-1);
    displayY += (playerCam.yPos - (yPos - sHeight/2))/(depth-1);
    strokeWeight(10/-depth);
    rect(displayX, displayY, 2*size/(-depth+1),2*size/(-depth+1));
  }
  
  void wiggle(){
    xPos -= 2*slowMoModifier;
    if (xPos < -size*2){
      shuffle();
    }
  }

  void shuffle(){
    xPos = sWidth + random(3*size);
    yPos = random(sHeight);
  }
}
