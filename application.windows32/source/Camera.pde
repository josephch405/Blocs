class Camera extends Thing{
  
  Camera (int _xPos, int _yPos){
    xPos = _xPos;
    yPos = _yPos;
  }
  
  Camera(){}
  
  void update (int _xPos, int _yPos){
    xPos = (_xPos - sWidth)/3;
    yPos = (_yPos - sWidth)/3;;
  }
}
