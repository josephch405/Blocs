abstract class Actor{
	float xPos, yPos, xVel, yVel = 0;
	boolean active = false;
	int goldWorth = 30;
	int size = 40;

	Actor(){
		active = true;
	}

	void calculate(){}
	void drawOut(){}
	void move(float dx, float dy){
		xPos += dx;
		yPos += dy;
	}
	void moveByVel(){
		move(xVel*slowMoModifier, yVel*slowMoModifier);
	}
	void setPosition(int _x, int _y){
		xPos = _x;
		yPos = _y;
	}
	void destroy(){
		active = false;
	}
}