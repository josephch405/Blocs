class UIManager{
	UIComponent[] components = new UIComponent[6];
	boolean[] active = {false, false, false, false, false, false};
	int activeIndex = -1;
	int overIndex = -1;
	boolean tutorialOpen = false;
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
		components[2] = new UIComponent(new int[]{sWidth/2 - margin,sHeight/2 + 4*margin} , new int[]{margin*2, margin*2}, 5);
		components[3] = new UIComponent(new int[]{(sWidth - 600)/2, (sHeight - 400)/2} , new int[]{600, 400}, 10);
		components[4] = new UIComponent();
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
				active = new boolean[]{true, false, true, false, false, false};
				break;
			//pause
			case 2:
				active = new boolean[]{false, false, false, false, false, true};
				break;
			//end
			case -1:
				active = new boolean[]{true, false, true, false, false, false};
				break;
			//menu
		}
		if (tutorialOpen){
			active[3] = true;
		}
		//processes active UI requests
		switch (activeIndex){
			case 0:
				if (status == -1){
					tutorialOpen = true;
					gameInit();
					status = 1;
					break;
				}
				status = 0;
				break;
			case 1:
				status = 1;
				break;
			case 2:
				tutorialOpen = true;
				break;
			case 3:
				tutorialOpen = false;
				if (status == 1){
					status = 0;
				}
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
			//fill(0);
			//text(maxEnemies, 20,20);
		}
		if (active[0]){
			drawPlayButton(components[0]);
		}
		if (active[1]){
			drawPauseButton(components[1]);
		}
		if (active[2]){
			drawTutorialButton(components[2]);
		}
		if (active[3]){
			drawTutorial(components[3]);
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
		rect(0,0, sWidth, margin);
		fill(0,255,0);
		rect(0,0, sWidth*((float)player.HP/player.HP_max), margin);

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
		float factor = 1;
		String tempText = "LV " + level + " ";
		fill(255);
		if (cost > 0){
			tempText += "$" + cost;
			if(player.gold >= cost){
				factor = 1.5;
				fill(0,255, 0);
			}
		}
		stroke(0);
		rect(offset + margin*3.5, sHeight-margin*factor, margin*5 ,margin*factor);
		fill(0);
		image(powerupImages[s_index], offset + margin*3.7, sHeight-margin*factor, margin, margin);
		text(tempText, offset + margin*5, sHeight-(factor - (float)2/3)*margin);
		if (player.gold >= cost && cost > 0){
			fill(255);
			rect(offset + margin*3.5, sHeight-margin*(factor*3/2), margin*5 ,margin*factor/2);
			fill(0);
			text("Press " + (s_index+1) + " to upgrade", offset + margin*3.7, sHeight-(factor + .1)*margin);
		}
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
		textSize(32);
		text("Score = " + score + "\nClick to restart", _compo.xPos+margin, _compo.yPos+margin, _compo.xSize, _compo.ySize);
		fill(255);
	}

	void drawTutorialButton(UIComponent _compo){
		ellipseMode(CORNER);
		strokeWeight(margin/14);
		fill(255);
		stroke(0);
		ellipse(_compo.xPos, _compo.yPos, _compo.xSize, _compo.ySize);
		fill(0);
		textSize(30);
		text("?", _compo.xPos + _compo.xSize*.4, _compo.yPos + _compo.ySize*.6);
	}

	void drawTutorial(UIComponent _compo){
		imageMode(CORNER);
		image(tutorial_pic, _compo.xPos, _compo.yPos, _compo.xSize, _compo.ySize);
	}
}
