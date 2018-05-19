import japplemenubar.*;

/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/40274*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */

import ddf.minim.*;
Minim minim;
AudioSample deathSound, introSound;

//import org.openkinect.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// Showing how we can farm all the kinect stuff out to a separate class
KinectTracker tracker;
// Kinect Library object
Kinect kinect;

//import fullscreen.*;
//FullScreen fs; 

int paused = 1;

Pac pac;
Blinky blinky;
Pinky pinky;
Inky inky;
Clyde clyde;
color yellow = #FFF708;
boolean levelStarted = false;
int timer, phaseTimer;
int phaseTimes[] = {6000,14000,6000,14000,4000,999999};
int phaseModes[] = {0,1,0,1,0,1};
int curLevel = 1, curPhase = 0;
float PAC_SPEED = 4.5/60.0;
int inkyDots, clydeDots;
PFont font,font2;
int score = 0, hiscore = 0;
boolean animation = true;
boolean gameStarted = false;
boolean invincible = false;
boolean enableHiscore = false;
boolean startGame = false;

void setup() {
  //fullScreen();
  size(640,480);
  //frame.setBackground(new java.awt.Color(0,0,0));
  frameRate(30);
  
  // create the fullscreen object
  //fs = new FullScreen(this); 
  // enter fullscreen mode
  //fs.enter();
  
  smooth();
  readMapFile();
  font = loadFont("GungsuhChe-20.vlw");
  font2 = loadFont("ARDESTINE-50.vlw");
  
  minim = new Minim(this);
  deathSound = minim.loadSample("pacman_death.wav");
  introSound = minim.loadSample("pacman_beginning.wav");

  kinect = new Kinect(this);
  tracker = new KinectTracker(); 
  
  setupGame();  
  
}

void setupGame() {
  pac = new Pac();
  blinky = new Blinky();
  pinky = new Pinky();
  inky = new Inky();
  clyde = new Clyde();
  score = 0;
  setupLevel();
  curLevel = 1;
}

void setupLevel() {
  curPhase = 0;
  curLevel++;
  
  initializeDots();
  dotsEaten = 0;
  
  // set level parameters
  if (curLevel < 4) {
    curPacSpeed = .8*PAC_SPEED;
    curGhostSpeed = .7*PAC_SPEED;
    frightenedTime = 9000;
    inkyDots = 90;
    clydeDots = 130;
  } else if (curLevel >= 4 && curLevel < 7) {
    curPacSpeed = .9*PAC_SPEED;
    curGhostSpeed = .82*PAC_SPEED;
    frightenedTime = 8000;
    inkyDots = 70;
    clydeDots = 110;
  } else if (curLevel >= 7 && curLevel < 10) {
    curPacSpeed = PAC_SPEED;
    curGhostSpeed = .95*PAC_SPEED;
    frightenedTime = 7000;
    inkyDots = 50;
    clydeDots = 90;
  } else {
    curPacSpeed = .9*PAC_SPEED;
    curGhostSpeed = .92*PAC_SPEED;
    frightenedTime = 5000;
    inkyDots = 30;
    clydeDots = 70;
  }
  
  reset();
  
}


void draw() {
  background(0);
  
  fill(yellow);
  
  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();
  move();
  
  if (key=='g') {
    startLevel();
  }
  
  drawLevel();
  drawHeader();
  
  if (!animation)
    runGame();
  else
    runAnimation();
    
  if (paused == 0) {
        loop();
  } else if (paused == 1) {
        noLoop();
        fill(yellow);
        textAlign(CENTER);
        text("CLICK TO START!", width/2, height/2 + 20);
  }
 
}

void runGame() {
  
  if (levelStarted) {
    pac.update();
    
    blinky.updateCondition();
    pinky.updateCondition();
    inky.updateCondition();
    clyde.updateCondition();
  } else {
    textFont(font,20);
    fill(yellow);
    text("Get ready!", width/2, 100);
    
    if (millis() - readyTimer > 2000) {
      startLevel();
    }
  }
  
  pac.drawPac();
  
  blinky.drawGhost();
  pinky.drawGhost();
  inky.drawGhost();
  clyde.drawGhost();
  
  drawTunnel();
  
  gameUpdate();
  
}

void gameUpdate() {
  if (levelStarted) {
    if (millis() - phaseTimer > phaseTimes[curPhase] && curPhase < 5) {
      // change phase
      phaseTimer = millis();
      curPhase++;
      blinky.mode = phaseModes[curPhase];
      blinky.reverseGhost = true;
      pinky.mode = phaseModes[curPhase];
      pinky.reverseGhost = true;
      inky.mode = phaseModes[curPhase];
      inky.reverseGhost = true;
      clyde.mode = phaseModes[curPhase];
      clyde.reverseGhost = true;
    }
    if (millis() - timer > 1000) {
      // release pinky
      pinky.moving = true;
    }
    if (dotsEaten >= inkyDots) {
      // release inky
      inky.moving = true;
    }
    if (dotsEaten >= clydeDots) {
      // release clyde
      clyde.moving = true;
    }
    
    // did we finish the level??
    if (dotsEaten >= totalDots) {
//    if (dotsEaten >= 3) {
      animation = true;
      levelCompleteAnimation = true;
      levelCompleteAngle = 0;
    }
    
  }
  
}


void drawHeader() {
  fill(textC);
  textFont(font,30);
  textAlign(CENTER);
  
  // score
  text("SCORE", 50, 30);
  textFont(font,25);
  text(score,50,62);

  // level
  textFont(font,30);
  text ("LEVEL " + curLevel, width/2, 30);
  
  // lives
  text("LIVES", width - 50, 30);
  int offSet = 0;
  for (int i=0; i<pac.lives; i++) {
    // yellow circle
    fill(#FFF708);
    noStroke();
    arc(width-22-offSet, 55, 20, 20, PI/4, 2*PI-PI/4);
    offSet += 30;
  }
}

void stop() {
  deathSound.close();
  introSound.close();
  super.stop();
}
  
