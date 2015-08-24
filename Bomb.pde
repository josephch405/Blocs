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

	void drawOut(){
		strokeWeight(size/50);
		stroke(0, timeOut*255/30);
		fill(fillColor[0], fillColor[1], fillColor[2], timeOut*255/30);
		if (active){
			ellipseMode(CENTER);
  			ellipse(xPos, yPos, size, size);
  		}
	}

	void calculate(){
		if (active){
			size *= .98;
			timeOut -= 1;
		}
		if (timeOut <= 0){
			destroy();
		}
	}

	void setType(int _type){
		type = _type;
		fillColor = new int[]{255, 255, 255};//missileColors[type];
	}
}
