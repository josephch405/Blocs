class Powerup extends Actor{
	int dir, type;
	int[] fillColor;
	boolean stickied = false;
	float dist = 2, angle = 0, dist_vel = 0, dist_vel_max = 0, angle_vel = .1;

	Powerup(int _xPos, int _yPos, int _dir, int _type) {
		size = margin*3/4;
		xPos = _xPos;
		yPos = _yPos;
		dir = _dir;
		type = _type;
		setVels();
		active = true;
		dist_vel_max = random(.1);
		angle_vel = random(0.02, .1) * pow(-1, floor(random(0,2)));
	}

	void calculate(){
		if (!stickied){
			xPos += xVel;
			yPos += yVel;

			if (outOfPlayArea(xPos, yPos)) {
				int[] temp = shufflePosition();
				xPos = temp[0];
				yPos = temp[1];
				dir = temp[2];
				setVels();
			}
			collisionCheck_player();
		}
		else{
			dist_vel -= dist_vel_max/2 * (dist - 1.75);
			dist += dist_vel;
			angle += angle_vel;
			xPos = player.xPos + cos(angle) * dist * 1.2*margin;
			yPos = player.yPos + sin(angle) * dist * 1.2*margin;
		}
	}

	void drawOut() {
		ellipseMode(CENTER);
		strokeWeight(2);
		stroke(0);
		fillWithArray(abilityColors[type]);
		ellipse(xPos, yPos, size, size);
	}

	void setVels() {
		xVel = (-dir+2)%2;
		yVel = (-dir+1)%2;
		if (xVel == 0) {
			yVel *= random(size/8, size/3);
		} else {
			xVel *= random(size/8, size/3);
		}
	}

	boolean collisionCheck_player() {
		if (isCollided(new float[]{player.xPos, player.yPos}, floor(player.playerSize()*2))) {
			stickied = true;
			return true;
		}
		return false;
	}

	boolean isCollided(float[] position, int _width) {
		if (abs(xPos-position[0]) < (_width+size)/2 && abs(yPos-position[1]) < (_width+size)/2) {
			return true;
		}
		return false;
	}

}