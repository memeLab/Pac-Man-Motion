class Man {
  PVector loc;
  int moveRequested; // 1-N, 2-E, 3-S, 4-W
  int lastMove;
  PVector direction;
  float speed;
  boolean moving;
  boolean inTunnel;
  boolean inBox; // only may be true for a ghost
  boolean cornering;
  int corneringTimer;
  boolean isGhost;
  
  void updateMove() {
    if (moving) {
      // check if change of direction is required
      if (boolean(moveRequested)) {
        if (moveRequested == 1 || moveRequested == 3) {
          // NORTH or SOUTH - x val must be near integer
          if ( abs(loc.x - int(loc.x)) < 2*speed && validMove(round(loc.x), round(loc.y), moveRequested).valid || inBox) {
            loc.x = round(loc.x);
            if (direction.x != 0 && isGhost) {
              cornering = true;
              corneringTimer = millis();
            }
            if (moveRequested == 1) {
              // NORTH
              direction.x = 0; direction.y = -1;
            } else {
              // SOUTH
              direction.x = 0; direction.y = 1;
            }
            lastMove = moveRequested;
            moveRequested = 0;
          }
        } else if (moveRequested == 2 || moveRequested == 4) {
          // EAST or WEST - y val must be near integer
          if ( abs(loc.y - int(loc.y)) < 2*speed && (validMove(round(loc.x), round(loc.y), moveRequested).valid || inBox)) {
            loc.y = round(loc.y);
            if (direction.y != 0 && isGhost) {
              cornering = true;
              corneringTimer = millis();
            }
            if (moveRequested == 2) {
              // EAST
              direction.x = 1; direction.y = 0;
            } else {
              // WEST
              direction.x = -1; direction.y = 0;
            }
            lastMove = moveRequested;
            moveRequested = 0;
          }
        }
      }
      
      // account for ghost cornering
      float curSpeed=0;
      if (isGhost) {
        if (cornering) {
          curSpeed = speed*.6;
        } else {
          curSpeed = speed;
        }
        if (cornering && millis() - corneringTimer > 1000.0*8.0/60.0) {
          cornering = false;
        }
      } else {
        curSpeed = speed;
      }
      
      // calculate next position
      PVector nextLoc = new PVector(0,0);
      nextLoc.x = loc.x + curSpeed*direction.x;
      nextLoc.y = loc.y + curSpeed*direction.y;
      // check if we're passing a tile midpoint in this timestep
      if (abs(floor(nextLoc.x)-floor(loc.x)) > 0.5 || abs(floor(nextLoc.y)-floor(loc.y)) > 0.5) {
        int nextMove;
        if (nextLoc.y < loc.y) {
          nextMove = 1; // NORTH
        } else if (nextLoc.y > loc.y) {
          nextMove = 3; // SOUTH
        } else if (nextLoc.x > loc.x) {
          nextMove = 2; // EAST
        } else {
          nextMove = 4; // WEST
        }
        MoveResult moveResult = validMove(round(nextLoc.x),round(nextLoc.y),nextMove);
        boolean valid = moveResult.valid;
        inTunnel = moveResult.tunnel;
        
        if (valid || inBox) {
          // continue moving
          loc = nextLoc;
        } else {
          // stop
          loc.x = round(loc.x);
          loc.y = round(loc.y);
          direction.set(0.0,0.0,0.0);
        }
        
        
      } else {
        // NOT passing midpoint - continue moving
        loc.x = loc.x + curSpeed*direction.x;
        loc.y = loc.y + curSpeed*direction.y;
      }
      
      // check if its in the tunnel
      if (inTunnel) {
        if (loc.x > tunnel2.x+1) {
          loc.x = tunnel1.x-1;
        } else if (loc.x < tunnel1.x-1) {
          loc.x = tunnel2.x+1;
        }
      }
      
//      if (PVector.dist(loc,tunnel1) < speed*2 && lastMove == 4) {
//        inTunnel = true;
//        // left tunnel
//        direction.set(-1.0,0.0,0.0);
//        loc = PVector.add(loc, PVector.mult(direction,speed));
//        if (loc.x <= -1.0 + speed*2) {
//          // move to next tunnel
//          loc.x = tunnel2.x;
//        }
//      }
//      if (PVector.dist(loc,tunnel2) < speed*2 && lastMove == 2) {
//        inTunnel = true;
//        // right tunnel
//        direction.set(1.0,0.0,0.0);
//        loc = PVector.add(loc, PVector.mult(direction,speed));
//        println("loc " + loc.x);
//        println(tunnel2.x + 1 - speed*2);
//        if (loc.x >= tunnel2.x+.5) {
//          // move to next tunnel
//          println("warped");
//          loc.x = tunnel1.x;
//        }
//      }
          
      
    }  // end if moving
  } // end void updateMove()
}