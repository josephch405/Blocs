class EnemyController {
	
	int[][] releaseZones;

	EnemyController(){
		releaseZones = new int[][]{
			{0,-40,sWidth,-20},
			{-40,0,-20,sHeight},
			{0,sHeight+20,sWidth,sHeight+40},
			{sWidth+20,0,sWidth+40,sHeight}
		};
	}

	void update(){
		if (enemies.size() < floor(maxEnemies)){
			release(floor(random(0,4)));
		}
		if (enemies_sticky.size() < floor(maxEnemies/7)){
			release_sticky(floor(random(0,4)));
		}
	}

	void release(int dir){
		int[] position = randomCoord(dir);
		enemies.add(new Enemy(position[0],position[1],100,dir));
	}

	void release_sticky(int dir){
		int[] position = randomCoord(dir);
		enemies_sticky.add(new Enemy_Sticky(position[0],position[1],100,dir));
	}

	int[] randomCoord(int dir){
		int tempX = floor(random(releaseZones[dir][0],releaseZones[dir][2]));
		int tempY = floor(random(releaseZones[dir][1],releaseZones[dir][3]));
		int[] bob = {tempX, tempY};
		return bob;
	}

}
