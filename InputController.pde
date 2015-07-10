class InputController{
	boolean[] _movementArray = new boolean[4];
	boolean[] _shootingArray = new boolean[4];
	boolean[] _upgradesArray = new boolean[4];
	boolean[] _abilitiesArray = new boolean[4];
	boolean pauseBuffer = false;		//actual state vs released? buffer


	InputController(){
		player.updateMovements(_movementArray);
		player.updateShooting(_shootingArray);
		player.updateUpgrades(_upgradesArray);
		player.updateAbilities(_abilitiesArray);
	}

	void update(){
		arrayCopy(downKeys, 0, _movementArray, 0, 4);
		arrayCopy(downKeys, 4, _shootingArray, 0, 4);
		arrayCopy(downKeys, 8, _upgradesArray, 0, 3);
		arrayCopy(downKeys, 11, _abilitiesArray, 0, 3);
		checkPause();
	}

	void checkPause(){
		if (!downKeys[14]){
			pauseBuffer = false;
		}
		else if (!pauseBuffer){
			togglePause();
			pauseBuffer = true;
		}
	}
}