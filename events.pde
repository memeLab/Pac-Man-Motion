//color textC = #F6FF00; // yellow
color textC = #FF035F; // pink
int pauseTimer;
boolean dyingAnimation = false;
int dyingTimer;
float dyingState, dyingAngle;
boolean levelCompleteAnimation = false;
float levelCompleteAngle = 0;
boolean gameOver = false;

boolean deadGhostAnimation = false;
int deadGhostTimer, ghostScore;
PVector ghostScoreLoc;
Ghost deadGhost;

int readyTimer;

void addScore(int d) {
  int lastScore = score;
  score += d;
  if ((score % 50000) < (lastScore % 50000)) {
    pac.lives++;
  }
}

void levelCompleteSequence() {
  levelStarted = false;
  
  fill(0);
  rectMode(CENTER);
  rect(width/2, height/2, 40, 30);
  
  fill(textC); // yellow
  textFont(font,20);
  textAlign(CENTER);
  text("Level Complete!", width/2, height/2);
  
  setupLevel();
}


void startLevel() {
  levelStarted = true;
  timer = millis();
  phaseTimer = timer;
  pac.moving = true;
  blinky.moving = true;
}

void reset() {
  // when new level starts or pacman dies
  pac.initialize();
  blinky.initialize();
  pinky.initialize();
  inky.initialize();
  clyde.initialize();
  
  ghostMult = 1;
  
  readyTimer = millis();
  levelStarted = false;
  
}

void pacDie() {
  if (!invincible) {
//    deathSound.trigger();
    pac.lives--;
    dyingState = pac.mouthState;
    dyingAngle = pac.mouthAngle;
    dyingTimer = millis();
    animation = true;
    dyingAnimation = true;
  }
}

int ghostMult = 1;
void killGhost(Ghost g) {
  int bonus = ghostMult * 200;
  ghostMult *= 2;
  ghostScore = bonus;
  addScore(bonus);
  deadGhost = g;
  
  PVector drawLoc = getLoc(pac.loc.y,pac.loc.x);
  float ran = random(0,1);
  int offSetx = round(ran);
  if (offSetx == 0) { offSetx = -1; }
  ran = random(0,1);
  int offSety = round(ran);
  if (offSety == 0) { offSety = -1; }
  
  ghostScoreLoc = new PVector(drawLoc.x + 20*offSetx, drawLoc.y + 20*offSety);
  
  deadGhostAnimation = true;
  animation = true;
  deadGhostTimer = millis();
  
}

//************//
// ANIMATIONS //
//************//

void runAnimation() {
  if (!gameStarted) {
    runTitleScreen();
  } else if (levelCompleteAnimation) {
    runLevelCompleteAnimation();
  } else if (dyingAnimation) {
    runDyingAnimation();
  } else if (deadGhostAnimation) {
    killGhostAnimation();
  } else if (gameOver) {
    runGameOver();
  }
}

void killGhostAnimation() {
  
  pac.drawPac();
  if (deadGhost != blinky)
    blinky.drawGhost();
  if (deadGhost != pinky)
    pinky.drawGhost();
  if (deadGhost != inky)
    inky.drawGhost();
  if (deadGhost != clyde)
    clyde.drawGhost();
  
  fill(255);
  stroke(0);
  textFont(font, 16);
  text(ghostScore, ghostScoreLoc.x, ghostScoreLoc.y);
  
  if (millis() - deadGhostTimer > 1000) {
    // end animation
    frightenedTimer += 1000; // must add a second back to the timer
    animation = false;
    deadGhostAnimation = false;
    deadGhost.dead = true;
    deadGhost.frightened = false;
    
    // reset multiplier if we've killed all possible ghosts
    if (!blinky.frightened && !pinky.frightened && !inky.frightened && !clyde.frightened) {
      ghostMult = 1;
    }
  }
}

void runTitleScreen() {
  strokeWeight(1);
  
  if (keyPressed && key==' ') {
    animation = false;
    gameStarted = true;
    setupGame();
  } else if (startGame == true) { // test: start game with proximity
    animation = false;
    gameStarted = true;
    setupGame();
  }
  paused = 1;
   
}

void runLevelCompleteAnimation() {
  
  pac.drawPac();
  blinky.drawGhost();
  pinky.drawGhost();
  inky.drawGhost();
  clyde.drawGhost();
  
  levelCompleteAngle += PI/12;
  
  pushMatrix();
    
  float angle = levelCompleteAngle;  
  if (angle > 4*2*PI) {
    angle = 4*2*PI;
  }
  int tSize = int(angle*50/(8*PI));
  
  translate(width/2, height/2);
  rotate(angle);
  
  textFont(font2, tSize);
  fill(#FC0505);
  stroke(255);
  text("Level Complete", 0, 0);
  
  popMatrix();
  
  if (levelCompleteAngle > 6*2*PI) {
    animation = false;
    levelCompleteAnimation = false;
    setupLevel();
  }
}

void runDyingAnimation() {
  
  blinky.drawGhost();
  pinky.drawGhost();
  inky.drawGhost();
  clyde.drawGhost();
  
  // draw dying pacman
  
  PVector drawLoc = getLoc(pac.loc.y, pac.loc.x);
  ellipseMode(CENTER);
  stroke(0);
  fill(yellow);
  
  arc(drawLoc.x, drawLoc.y, pacDiameter, pacDiameter, dyingAngle+PI*dyingState/4, dyingAngle+2*PI-PI*dyingState/4);
  
  if (millis() - dyingTimer > 600)
    dyingState += 0.04;
  
  if (dyingState >= 4) {
    // animation complete
    dyingAnimation = false;
    animation = false;
    
    if (pac.lives >= 0) {
      reset();
    } else {
      // GAME OVER :(
      gameOver = true;
      animation = true;
      startGame = false;
    }
  }
  
}

void runGameOver() {
  /*rectMode(CENTER);
  fill(0,150);
  stroke(255);
  strokeWeight(4);
  rect(width/2, height/2, 400, 60);
  strokeWeight(1);
  
  textFont(font2, 50);
  fill(#FC0505);
  text("GAME OVER", width/2, height/2+17);*/
  
  runTitleScreen();
  if (animation == false)
    gameOver = false;
}
