class Thing{
	
	float xPos = 0, yPos = 0;
	boolean active = false;

	void move(int dx, int dy){
	  	xPos += dx;
	  	yPos += dy;
  	}

  	void setPosition(int _x, int _y){
	  	xPos = _x;
	  	yPos = _y;
  	}

	void destroy(){
		active = false;
	}

}