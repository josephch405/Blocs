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