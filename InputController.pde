class InputController{
	boolean[] _movementArray = new boolean[6];
	boolean[] _shootingArray = new boolean[4];
	boolean[] _upgradesArray = new boolean[5];
	boolean[] _abilitiesArray = new boolean[3];
	boolean pauseBuffer = false;		//actual state vs released? buffer

	InputController(){
	}

	void update(){
		arrayCopy(downKeys, 0, _movementArray, 0, 6);
		arrayCopy(downKeys, 6, _shootingArray, 0, 4);
		arrayCopy(downKeys, 10, _upgradesArray, 0, 5);
		arrayCopy(downKeys, 15, _abilitiesArray, 0, 3);
		checkPause();
	}

	void connectInputsToPlayer(){
		player.linkControlArrays(_movementArray, _shootingArray, _upgradesArray, _abilitiesArray);
	}

	void checkPause(){
		if (!downKeys[downKeys.length-1]){
			pauseBuffer = false;
		}
		else if (!pauseBuffer){
			togglePause();
			pauseBuffer = true;
		}
	}
}