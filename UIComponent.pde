class UIComponent {
	int xPos, yPos;
	int xSize, ySize;
	int zLevel;
	boolean active = false;
	int counter;

	UIComponent(int[] pos, int[] size, int _zLevel){
		xPos = pos[0];
		yPos = pos[1];
		xSize = size[0];
		ySize = size[1];
		zLevel = _zLevel;
		active = true;
	}

	UIComponent(){
		xPos = 0;
		yPos = 0;
		xSize = 0;
		ySize = 0;
		zLevel = 0;
		active = true;
	}

	int isOnComponent(int _zLevel, int[] _pos){
		if (active){
			if (zLevel > _zLevel){
				if (inBounds(_pos)){
					return zLevel;
				}
			}
		}
		return -1;
	}

	void fire(){
		
	}

	void updateCounter(int _num){
		counter = _num;
	}

	void drawOut(){

	}

	boolean inBounds(int[] _pos){
		if (_pos[0] > xPos && _pos[0] < xPos + xSize){
			if (_pos[1] > yPos && _pos[1] < yPos + ySize){
				return true;
			}
		}
		return false;
	}

}