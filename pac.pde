float pacDiameter = TILE_SIZE*.9;
float curPacSpeed = PAC_SPEED;

class Pac extends Man {
  int lives;
  float mouthState;
  int mouthDirection;
  float mouthAngle;

  Pac() {
    initialize();
    lives = 3;
    inBox = false;
    isGhost = false;
  }
  
  void initialize() {
    loc = new PVector(10.0,7.0);
    direction = new PVector(1,0);
    moveRequested = 0;
    lastMove = 2;
    moving = false;
    speed = curPacSpeed;
    mouthState = 0.0;
    mouthDirection = 1;
    inTunnel = false;
  }
  
  void update() {
    updateMove();
    
    if (!inTunnel) {
      int curX = round(loc.x);
      int curY = round(loc.y);
      if (!level[curY][curX].eaten && (level[curY][curX].type == 'a' || level[curY][curX].type == 'A')) {
        level[curY][curX].eaten = true;
        dotsEaten++;
        addScore(10);
        if (level[curY][curX].dotType == 2) {
          blinky.frighten();
          pinky.frighten();
          inky.frighten();
          clyde.frighten();
          phaseTimer += frightenedTime;
        }
      }
    }
  }
  
  void drawPac() {
    PVector drawLoc = getLoc(loc.y,loc.x);
    ellipseMode(CENTER);
    stroke(0);
    fill(#FFF708);
    
    // move mouth
    if (lastMove==3) {
      // SOUTH
      mouthAngle = PI/2;
    } else if (lastMove==1) {
      // NORTH
      mouthAngle = 3*PI/2;
    } else if (lastMove==2) {
      // EAST
      mouthAngle = 0;
    } else {
      // WEST
      mouthAngle = PI;
    }
    
    if (mouthState >= 1) {
      mouthDirection = -1;
    } else if (mouthState <= 0) {
      mouthDirection = 1;
    }
    mouthState += 0.04*mouthDirection;
    
    arc(drawLoc.x, drawLoc.y, pacDiameter, pacDiameter, mouthAngle+PI*mouthState/4, mouthAngle+2*PI-PI*mouthState/4);
  }
  
  

}