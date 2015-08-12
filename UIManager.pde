class UIManager{
	UIComponent[] components = new UIComponent[6];
	boolean[] active = {false, false, false, false, false, false};
	int activeIndex = -1;
	int overIndex = -1;
	/*
	**Components:
	**	0: play button
	**	1: pause button
	**	2: help button
	**  3: help panel
	**	4: pause panel
	**  5: game over panel
	**
	*/

	UIManager(){
		components[0] = new UIComponent(new int[]{sWidth/2 - 3*margin,sHeight/2 - 3*margin} , new int[]{margin*6, margin*6}, 5);
		components[1] = new UIComponent(new int[]{sWidth - floor(1.2*margin), floor(.2*margin)} , new int[]{margin, margin}, 5);
		//placeholder for components
		for (int i = 2; i < components.length; i++){
			components[i] = new UIComponent();
		}
		components[5] = new UIComponent(new int[]{sWidth/2 - 5*margin,sHeight/2 - 3*margin} , new int[]{margin*10, margin*6}, 5);
	}

	void clickEvent(int[] _pos){
		int greatestLevel = 0;
		for (int i = 0; i < components.length; i++){
			int _temp = components[i].isOnComponent(greatestLevel, _pos);
			if (_temp > greatestLevel && active[i]){
				greatestLevel = _temp;
				activeIndex = i;
			}
		}
	}

	void overEvent(int[] _pos){
		int greatestLevel = 0;
		for (int i = 0; i < components.length; i++){
			int _temp = components[i].isOnComponent(greatestLevel, _pos);
			if (_temp > greatestLevel && active[i]){
				greatestLevel = _temp;
				overIndex = i;
			}
		}
	}

	void calculate(){
		//toggling active component array
		switch (status){
			case 0:
				active = new boolean[]{false, true, false, false, false, false};
				break;
			//game
			case 1:
				active = new boolean[]{true, false, false, false, false, false};
				break;
			//pause
			case 2:
				active = new boolean[]{false, false, false, false, false, true};
				break;
			//end
			case -1:
				active = new boolean[]{true, false, false, false, false, false};
				break;
			//menu
		}
		//processes active UI requests
		switch (activeIndex){
			case 0:
				if (status == -1){
					gameInit();
				}
				status = 0;
				break;
			case 1:
				status = 1;
				break;
			case 5:
				gameInit();
				status = 0;
				break;
		}
		//processes mouseover UI requests
		switch (overIndex){
			case 0:
		}
		activeIndex = -1;
		overIndex = -1;
	}

	void draw_ui(){
		if (status > -1){
			drawBars();
		}
		if (active[0]){
			drawPlayButton(components[0]);
		}
		if (active[1]){
			drawPauseButton(components[1]);
		}
		if (active[5]){
			drawEndgame(components[5]);
		}
	}

	void drawBars(){
		rectMode(CORNER);
		stroke(0);
		strokeWeight(2);
		fill(255,0,0);
		rect(0,0, sWidth, margin/2);
		fill(0,255,0);
		rect(0,0, sWidth*((float)player.HP/player.HP_max), margin/2);

		strokeWeight(2);
		fill(255,255,255);
		rect(0,sHeight-margin, sWidth, margin);
		fill(0,0,0);

		textSize(margin/2);
		fill(255, 255, 0);
		rect(10,sHeight-margin*3/4, margin/2, margin/2);
		fill(0, 0, 0);
		text(player.gold, margin*5/3, sHeight-margin/3);

		drawUpgradeButton(0, "Agility", 0);
		drawUpgradeButton(1, "Power", 5*margin);
		drawUpgradeButton(2, "Bomb", 10*margin);
		drawUpgradeButton(3, "Beserk", 15*margin);
		drawUpgradeButton(4, "Slowmo", 20*margin);

		//text("framrate: " + frameRate, 40, 80);
		//text("bomb lock: " + player.bombLock, 40, 120);
		//text("rot lock: " + player.rotate_lock, 40, 160);

		rectMode(CENTER);
	}

	void drawUpgradeButton(int s_index, String label, int offset){
		//offsets are spaced by 5 margins
		int level = player.s_byIndex(s_index);
		int cost = player.costByIndex(s_index);
		String tempText = "LV " + level + " " + label;
		fill(255);
		if (cost > 0){
			tempText += "$" + cost;
			if(player.gold >= cost){
				fill(0,255, 0);
			}
		}
		stroke(0);
		rect(offset + margin*3.5, sHeight-margin, margin*5 ,margin);
		fill(0);
		text(tempText, offset + margin*4, sHeight-margin/3);
	}

	void drawPlayButton(UIComponent _compo){
		ellipseMode(CORNER);
		strokeWeight(margin/10);
		fill(255);
		stroke(0);
		ellipse(_compo.xPos, _compo.yPos, _compo.xSize, _compo.ySize);
		fill(0);
      	triangle(sWidth/2 - margin, sHeight/2 - margin*1.73, sWidth/2 - margin, sHeight/2 + margin*1.73, sWidth/2 + 2*margin, sHeight/2);  
	}

	void drawPauseButton(UIComponent _compo){
		rectMode(CORNER);
		strokeWeight(margin/10);
		fill(255);
		rect(_compo.xPos, _compo.yPos, _compo.xSize, _compo.ySize);
		fill(0);
      	rect(_compo.xPos + margin * .2, _compo.yPos + margin*.2, margin * .2, margin * .6);  
      	rect(_compo.xPos + margin * .6, _compo.yPos + margin*.2, margin * .2, margin * .6);  
	}

	void drawEndgame(UIComponent _compo){
		strokeWeight(margin/10);
		fill(255);
		rectMode(CORNER);
		rect(_compo.xPos, _compo.yPos, _compo.xSize, _compo.ySize);
		fill(0);
		textSize(20);
		text("HP == 0;\nRestart?", _compo.xPos+margin, _compo.yPos+margin, _compo.xSize, _compo.ySize);
		fill(255);
	}
}
