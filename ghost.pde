PVector ghostStartLoc = new PVector(10,13,0);
PVector ghostBoxMid = new PVector(10,12,0);
PVector ghostBoxLeft = new PVector(9,12,0);
PVector ghostBoxRight = new PVector(11,12,0);
float curGhostSpeed;
float FRIGHTENED_SPEED = PAC_SPEED*.30;
float TUNNEL_SPEED = PAC_SPEED*.55;
float DEAD_SPEED = 5.0/60.0;
color frightenedC = #0032F2;
int frightenedTime;
int frightenedTimer = 0;


class Clyde extends Ghost {
  
  Clyde() {
    fillC = #FF7300;
    homeBase = new PVector(-2,-2); // upper left
    ghostBox = ghostBoxRight;
    initialize();
  }
  
  void initialize() {
    ghostInitialize();
    loc.set(ghostBox);
    moving = false;
    inBox = true;
    norm_speed = curGhostSpeed;
  }
  
  void determineChaseTarget() {
    // if less than 8 tiles from pacman, target hometile
    // else same as blinky
    int targetX, targetY;
    int distance = 0;
    distance += abs(loc.x - pac.loc.x);
    distance += abs(loc.y - pac.loc.y);
    if (distance < 6) {
      target.set(homeBase);
    } else {
      target.set(blinky.target);
    }
    
  }
  
}


class Inky extends Ghost {
  
  Inky() {
    fillC = #00CEFF;
    homeBase = new PVector(mapW+2,-1); // upper right
    ghostBox = ghostBoxLeft;
    initialize();
  }
  
  void initialize() {
    ghostInitialize();
    loc.set(ghostBox);
    moving = false;
    inBox = true;
    norm_speed = curGhostSpeed;
  }
  
  void determineChaseTarget() {
    // target is 4 squares ahead of pac
    int targetX, targetY;
    int pacTileX = int(pac.loc.x);
    int pacTileY = int(pac.loc.y);
    pacTileX += pac.direction.x*2;
    pacTileY += pac.direction.y*2;
    
    targetX = int(2*(pacTileX - blinky.loc.x));
    targetY = int(2*(pacTileY - blinky.loc.y));
    
    target.set(float(targetX),float(targetY),0.0);
  }
  
}


class Pinky extends Ghost {
  
  Pinky() {
    fillC = #FF74B7;
    homeBase = new PVector(-1,mapH+2); // bottom left
    ghostBox = ghostBoxMid;
    initialize();
  }
  
  void initialize() {
    ghostInitialize();
    loc.set(ghostBox);
    moving = false; // start right away
    inBox = true;
    norm_speed = curGhostSpeed;
    //moveRequested = 3; // SOUTH
  }
  
  void determineChaseTarget() {
    // target is 4 squares ahead of pac
    int targetX = int(pac.loc.x);
    int targetY = int(pac.loc.y);
    targetX += pac.direction.x*4;
    targetY += pac.direction.y*4;
    
    target.set(float(targetX),float(targetY),0.0);
  }
  
}


class Blinky extends Ghost {
  
  Blinky() {
    initialize();
    fillC = #F20000;
    homeBase = new PVector(mapW+1,-1); // upper right
    ghostBox = new PVector(10,14);
  }
  
  void initialize() {
    ghostInitialize();
    loc.set(ghostStartLoc);
    moving = false; // start right away
    inBox = false;
    moveRequested = 4;
    norm_speed = curGhostSpeed;
  }
  
  void determineChaseTarget() {
    // target is pac's location
    target.set(pac.loc);
  }
  
}


class Ghost extends Man {
  PVector target;
  PVector homeBase;
  PVector ghostBox;
  int mode; // scatter-0, chase-1, frightened-2
  boolean frightened;
  boolean dead;
  color fillC, curFill;
  float norm_speed;
  //int frightenedTimer = 0;
  boolean reverseGhost;
  
  Ghost() {
    ghostInitialize();
    isGhost = true;
  }
  
  void ghostInitialize() {
    moveRequested = 0;
    moving = false;
    mode = 0;
    dead = false;
    target = new PVector(0,0,0);
    loc = new PVector(0,0,0);
    //direction = new PVector(-1,0); // edited
    direction = new PVector(0,0);
    frightened = false;
    reverseGhost = false;
  }
  
  void drawGhost() {
    PVector drawLoc = getLoc(loc.y,loc.x);
    
    if (!dead) {
      ellipseMode(CENTER);
      stroke(0);
      if (!frightened)
        fill(fillC);
      else
        fill(curFill);
      ellipse(drawLoc.x, drawLoc.y, pacDiameter-2, pacDiameter-2);
      
      rectMode(CENTER);
      noStroke();
      rect(drawLoc.x, drawLoc.y+pacDiameter/4, pacDiameter-2, pacDiameter/2);
    }
    
    drawEyes(drawLoc);
  }
  
  void drawEyes(PVector drawLoc) {
    fill(255);
    noStroke();
    ellipseMode(CENTER);
    // draw eyes
    ellipse(drawLoc.x-3, drawLoc.y, 5, 8); // left
    ellipse(drawLoc.x+3, drawLoc.y, 5, 8); // right
    
    // draw pupils
    if (!frightened) {
      fill(0);
      ellipse(drawLoc.x-3+2*direction.x, drawLoc.y+3*direction.y, 2, 2); // left
      ellipse(drawLoc.x+3+2*direction.x, drawLoc.y+3*direction.y, 2, 2); // right
    }
  }
  
  void updateCondition() {
    
    updateMove();
    
    if (!inBox)
      updateMoveDecision();
    
    // handle speed
    if (frightened) {
      speed = FRIGHTENED_SPEED;
    } else if (dead) {
      speed = DEAD_SPEED;
    } else {
      if (inTunnel) {
        speed = TUNNEL_SPEED;
      } else {
        speed = norm_speed;
      }
    }
    
    // see if we need to stop frightened
    if (frightened) {
      if (millis() - frightenedTimer > frightenedTime) {
        frightened = false;
        ghostMult = 1;
      } else if (frightenedTime - (millis() - frightenedTimer) < 2000) {
        float fraction = float((frightenedTime - (millis() - frightenedTimer)))/2000.0;
        curFill = avgColor(frightenedC, fillC, 1-fraction);
      }
    }
    
    // if we are in the box we need to move out
    if (inBox && moving && !dead) {
      if (abs(PVector.dist(loc,ghostBoxLeft)) < 2*speed && direction.x==0 && direction.y==0) {
        moveRequested = 2;
      } else if (abs(PVector.dist(loc,ghostBoxRight)) < 2*speed && direction.x==0 && direction.y==0) {
        moveRequested = 4;
      } else if (abs(PVector.dist(loc,ghostBoxMid)) < 2*speed && direction.y==0) {
        moveRequested = 3;
      } else if (abs(PVector.dist(loc,ghostStartLoc)) < 2*speed) {
        // move out of the box
        loc.x = round(loc.x);
        loc.y = round(loc.y);
        inBox = false;
        //direction.x = 0; direction.y = 0;
        moveRequested = 4;
      }
    }
    
    // check for pacman collision
    if (!dead) {
      float pacDist = loc.dist(pac.loc);
      if (pacDist <= 8*PAC_SPEED) {
        
        if (frightened) {
          // ghost die!
          killGhost(this);
//          dead = true;
//          frightened = false;
//          score += 500;
        } else {
          // pacman die!
          pacDie();
        }
        
      }
    }
    
    // move dead ghost back to home
    if (dead) {
      if (loc.dist(ghostBoxMid) < 2*PAC_SPEED) {
        // if close enough to home, make alive again! rawr payback!
        direction.y = 1;
        dead = false;
        loc.set(ghostBoxMid);
      } else if (loc.dist(ghostStartLoc) < 2*PAC_SPEED) {
        inBox = true;
        direction.y = -1;
        direction.x = 0;
        loc.x = ghostStartLoc.x;
      }
    }
    
    
    
  }
  
  void frighten() {
    if (moving) {
      frightened = true;
      reverseGhost = true;
      frightenedTimer = millis();
      curFill = frightenedC;
    }
  }
  
  void kill() {
    dead = true;
    target.set(ghostBox);
  }
    
  
  void determineChaseTarget() {
    // empty - defined in subclass
  }
  
  void determineTarget() {
    if (frightened) {
      // frightened
      target.set(int(random(0,mapW)), int(random(0,mapH)), 0.0);
    } else {
      if (mode == 0) {
        // SCATTER
        target.set(homeBase);
      } else if (mode == 1) {
        // CHASE
        determineChaseTarget(); // to be filled by subclass
      }
    }
  }
  
  void updateMoveDecision() {
        
    if (!inTunnel && !dead) {
      determineTarget();
      
      if (reverseGhost) {
        if (abs(loc.x-int(loc.x)) < 2*speed && abs(loc.y-int(loc.y)) < 2*speed) {
          if (lastMove == 1)
            moveRequested = 3;
          else if (lastMove == 2)
            moveRequested = 4;
          else if (lastMove == 3)
            moveRequested = 1;
          else
            moveRequested = 2;
          reverseGhost = false;
          return;
        } else {
          return;
        }
      }
      
      inTunnel = loc.x < 0 || loc.x >= mapW;
      
      if (moveRequested == 0 && !inTunnel && !dead) {
        // no decision made for a move - update moveRequest
        int curX = round(loc.x);
        int curY = round(loc.y);
        PVector nextTile = new PVector(curX+direction.x, curY+direction.y, 0.0);
        int nextX = int(nextTile.x);
        int nextY = int(nextTile.y);
        
        if (nextY != tunnel1.y || (nextX > tunnel1.x && nextX < tunnel2.x)) {
        
          if (level[nextY][nextX].numNeighbors > 2) {
            // make decision based on target tile
            int bestMoveInd=0; float minDist = 9999;
            for (int i=0; i<level[nextY][nextX].numNeighbors; i++) {
              // choose best move based on shortest euclidean distance to 
              // target tile
              PVector thisTile = resultTile(nextTile, level[nextY][nextX].neighbor[i]);
              if (curX != round(thisTile.x) || curY != round(thisTile.y)) {
                float distance = PVector.dist(thisTile, target);
                
                // distance thru tunnel is not the same
                if (thisTile.dist(tunnel1) < .5 ) {
                  distance = PVector.dist(target, tunnel2);
                } else if(thisTile.dist(tunnel2) < .5) {
                  distance = PVector.dist(target, tunnel1);
                }
                
                if (distance < minDist) {
                  minDist = distance;
                  bestMoveInd = i;
                }
              }
            }
            int bestMove = level[nextY][nextX].neighbor[bestMoveInd];
            moveRequested = bestMove;
            
          } else if (level[nextY][nextX].numNeighbors == 2) {
            // take the option that doesnt reverse you
            PVector thisTile = resultTile(nextTile, level[nextY][nextX].neighbor[0]);
            if (curX == round(thisTile.x) && curY == round(thisTile.y)) {
              // if this is current tile, use 2nd option
              moveRequested = level[nextY][nextX].neighbor[1];
            } else {
              // otherwise use first option
              moveRequested = level[nextY][nextX].neighbor[0];
            }
            
          } else {
            // get out of a dead end
            if (direction.x == 0 && direction.y == 0)
              moveRequested = level[nextY][nextX].neighbor[0];
          }
          
        } // end if nextTile != either tunnel
        
      }// end if move requested = 0
      
      
    }// end if not inTunnel and not dead
    else if (dead) {
      // move ghost back to home
      moveRequested = ghostDirections[int(loc.y)][int(loc.x)];
    }
  }// end void update
  
}// end class Ghost


color avgColor(color color1, color color2, float percent) {
  float r1,g1,b1,r2,g2,b2,r3,g3,b3;
  r1 = red(color1);
  g1 = green(color1);
  b1 = blue(color1);
  r2 = red(color2);
  g2 = green(color2);
  b2 = blue(color2);
  r3 = percent*r2 + (1-percent)*r1;
  g3 = percent*g2 + (1-percent)*g1;
  b3 = percent*b2 + (1-percent)*b1;
  return color(r3,g3,b3);
}