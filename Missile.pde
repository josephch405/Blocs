class Missile extends Actor{
	int type = 0;
	int[] dir;
	int size = sHeight/40;
	int[] fillColor;
	//dir: up, left, down, right

	Missile(int _xPos, int _yPos, int[] _dir, int _type){
  		xPos = _xPos;
		yPos = _yPos;
		dir = _dir;
		xVel = dir[0]*size*2;
		yVel = dir[1]*size*2;
  		active = true;
  		setType(_type);
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
			xPos += xVel;
			yPos += yVel;
		}
		if (xPos < -10 || xPos > sWidth + 10 ||yPos < -10 || yPos > sHeight + 10){
			destroy();
		}
	}

	void setType(int _type){
		type = _type;
		fillColor = missileColors[type];
		/*	old type generation, didn't take player rotation into account
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
		fillColor = missileColors[type];*/
	}
}
