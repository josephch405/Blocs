class Missile extends Thing{

	int type = 0;
	int[] dir;
	int size = 16;
	int[] fillColor;
	//dir: up, left, down, right

	Missile(int _xPos, int _yPos, int[] _dir){
  		xPos = _xPos;
		yPos = _yPos;
		dir = _dir;
  		active = true;
  		setType();
	}

	void drawOut(){
		strokeWeight(2);
		stroke(0);
		fill(fillColor[0], fillColor[1], fillColor[2]);
		if (active){
  			rect(xPos, yPos, size, size);
  		}
	}

	void calculate(){
		if (active){
			xPos += dir[0];
			yPos += dir[1];
		}
		if (xPos < -10 || xPos > sWidth + 10 ||yPos < -10 || yPos > sHeight + 10){
			destroy();
		}
	}

	void destroy(){
		active = false;
	}

	void setType(){
		type = 3;
		if (dir[1] == 0 && dir[0] < 0){
			type = 1;
		}
		else if (dir[1] > 0){
			type = 2;
		}
		else if (dir[1] < 0){
			type = 0;
		}
		fillColor = missileColors[type];
	}
}
