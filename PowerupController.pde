class PowerupController {

  int[] powerUpLimits;
  int releaseTimer = 100;
  int tempCounter = 0;

  PowerupController() {
    powerUpLimits = new int[]{0, 0, 0};
  }

  void update() {
    for (int i = 0; i < 3; i ++){
      if (numOfThisType(i) < powerUpLimits[i]){
        release(floor(random(1, 3)), i);
      }
    }
    calculateActorArray(powerups);
  }

  void release(int dir, int type) {
    int[] position = randomCoord(dir);
    powerups.add(new Powerup(position[0], position[1], dir, type));
  }

  int numOfThisType(int _type){
    int counter = 0;
    for (int i = 0; i < powerups.size(); i++){
      if (((Powerup)powerups.get(i)).type == _type){
        counter += 1;
      }
    }
    return counter;
  }

  boolean removeThisType(int _type){
    for (int i = 0; i < powerups.size(); i++){
      if (((Powerup)powerups.get(i)).type == _type && ((Powerup)powerups.get(i)).stickied){
        powerups.remove(i);
        return true;
      }
    }
    return false;
  }

  void setTypeLimit(int _type, int _limit){
    powerUpLimits[_type] = _limit;
  }

}