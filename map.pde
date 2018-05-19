float TILE_SIZE = 20;
int mapW, mapH;
String fileIN[];
Tile level[][];
boolean isPassable[][];
PVector levelLoc = new PVector(120,60); // where to shift level in viewing screen
//PImage cherry, apple, strawberry, orange;
int totalDots = 0, dotsEaten = 0;
PVector tunnel1 = new PVector(0,11);
PVector tunnel2 = new PVector(20,11);
int ghostDirections[][];

class MoveResult {
  boolean valid;
  boolean tunnel;
}

class Tile {
  boolean passable;
  char type;
  boolean eaten;
  int dotType; // 0-none, 1-normal, 2-superdot
  int numNeighbors;
  int neighbor[]; // describes the move: 1N,2E,3S,4W
  
  Tile() {
    dotType = 0;
    eaten = false;
    passable = false;
    numNeighbors = 0;
    neighbor = new int[4];
  }
}

void readMapFile() {
  fileIN = loadStrings("pacmanMap_pinheiros.txt");
  mapW = int(fileIN[0]);
  mapH = int(fileIN[1]);
  
  level = new Tile[mapH][mapW];
  for (int i=2; i<fileIN.length; i++) {
    String thisLine = fileIN[i];
    for (int j=0; j<mapW; j++) {
      level[i-2][j] = new Tile();
      level[i-2][j].type = thisLine.charAt(j);
      if (thisLine.charAt(j) == 'A' || thisLine.charAt(j) == 'B' || thisLine.charAt(j) == 'a') {
        level[i-2][j].passable = true;
      }
      if (thisLine.charAt(j) == 'A') {
        // normal dot
        level[i-2][j].dotType = 1;
        totalDots++;
      } else if (thisLine.charAt(j) == 'a') {
        // super dot
        level[i-2][j].dotType = 2;
        totalDots++;
      }
    }
  }
  // bug???
  //totalDots--;
  
  // count number of neighbors
  for (int i=0; i<mapH; i++) {
    for (int j=0; j<mapW; j++) {
      if (level[i][j].passable) {
        int numNeighbor = 0;
        // top neighbor
        if (i>0) {
          if (level[i-1][j].passable) {
            level[i][j].neighbor[numNeighbor] = 1;
            numNeighbor++;
          }
        }
        // bottom neighbor
        if (i<mapH-1) {
          if (level[i+1][j].passable) {
            level[i][j].neighbor[numNeighbor] = 3;
            numNeighbor++;
          }
        }
        // left neighbor
        if (j>0) {
          if (level[i][j-1].passable) {
            level[i][j].neighbor[numNeighbor] = 4;
            numNeighbor++;
          }
        }
        // right neighbor
        if (j<mapW-1) {
          if (level[i][j+1].passable) {
            level[i][j].neighbor[numNeighbor] = 2;
            numNeighbor++;
          }
        }
        level[i][j].numNeighbors = numNeighbor;
      }
    }
  }
  
  // load images into memory
  //loadImages();
  // read in ghost directions for returning to home
  readGhostDirections();
}


void drawLevel() {
  
  // draw walls
  for (int i=0; i<mapH; i++) {
    for (int j=0; j<mapW; j++) {
      if (level[i][j].type == 'W' || level[i][j].type == 'w') {
        pushMatrix();
        
        PVector loc = getLoc(i,j);
        translate(loc.x, loc.y);
        rectMode(CENTER);
        if (level[i][j].type == 'W')
          fill(#FF035F);
        else
          fill(0);
          stroke(#0046FF);
        rect(0,0,TILE_SIZE-5,TILE_SIZE-5);
        stroke(0);
        
        popMatrix();
      } else if (level[i][j].type == 'A' || level[i][j].type == 'a') {
        
        if (!level[i][j].eaten) {
          // draw dot
          pushMatrix();
          PVector loc = getLoc(i,j);
          translate(loc.x, loc.y);
          ellipseMode(CENTER);
          fill(#FFF708);
          int circleRad;
          if (level[i][j].dotType == 1) {
            circleRad = 5;
          } else {
            circleRad = 10;
          }
          ellipse(0,0,circleRad,circleRad);
          popMatrix();
        }
      }
    }
  }
  
  // draw ghost box
  pushMatrix();
  PVector loc = getLoc(12,10);
  translate(loc.x, loc.y);
  noFill();
  stroke(#0046FF);
  rectMode(CENTER);
  rect(0,0,TILE_SIZE*3,TILE_SIZE);
  // draw door
  fill(255);
  rect(0,TILE_SIZE/2,TILE_SIZE,3);
  popMatrix();
  
  /*// draw cherry
  pushMatrix();
  loc = getLoc(7,14);
  translate(loc.x, loc.y);
  imageMode(CENTER);
  image(cherry,0,0,18,18);
  popMatrix();
  */
  
}


void initializeDots() {
  for (int i=0; i<mapH; i++) {
    for (int j=0; j<mapW; j++) {
      level[i][j].eaten = false;
    }
  }
}

void drawTunnel() {
  // draw tunnel "curtains"
  noFill();
  noStroke();
  
  pushMatrix();
  PVector loc = getLoc(tunnel1.y,tunnel1.x-1);
  translate(loc.x, loc.y);
  rect(0,0,TILE_SIZE,TILE_SIZE);
  popMatrix();
  pushMatrix();
  loc = getLoc(tunnel2.y,tunnel2.x+1);
  translate(loc.x, loc.y);
  rect(0,0,TILE_SIZE,TILE_SIZE);
  popMatrix();
}


PVector resultTile(PVector curTile, int moveType) {
  PVector ans = new PVector(0.0,0.0,0.0);
  switch(moveType) {
    case 1: // NORTH
      ans.x = curTile.x;
      ans.y = curTile.y - 1;
      break;
    case 2: // EAST
      ans.x = curTile.x + 1;
      ans.y = curTile.y;
      break;
    case 3: // SOUTH
      ans.x = curTile.x;
      ans.y = curTile.y + 1;
      break;
    case 4: // WEST
      ans.x = curTile.x - 1;
      ans.y = curTile.y;
      break;
    default:
      break;    
  }
  return ans;
}




// returns true if tile to move to is passable
MoveResult validMove(int locx, int locy, int moveRequested) {
  int next_locx=-1, next_locy=-1;
  boolean valid = false;
  boolean tunnel = false;
  MoveResult ans = new MoveResult();
  
  PVector temp = new PVector(locx,locy,0);
  PVector next_loc = resultTile(temp, moveRequested);
  next_locx = int(next_loc.x);
  next_locy = int(next_loc.y);
  
  if (next_locx >= 0 && next_locx < mapW) {
    if (next_locy >= 0 && next_locy < mapH) {
      if (level[next_locy][next_locx].passable) {
        valid = true;
      }
    }
  }
  
  // what if its the tunnel?
  if (next_locy == tunnel1.y) {
    if ((next_locx <= tunnel1.x || next_locx >= tunnel2.x) && (moveRequested == 2 || moveRequested == 4)) {
      valid = true;
      tunnel = true;
    }
  }
  
  ans.valid = valid;
  ans.tunnel = tunnel;
  return ans;
}


PVector getLoc(float row, float col) {
  PVector ans = new PVector(0,0);
  ans.x = levelLoc.x + col*TILE_SIZE;
  ans.y = levelLoc.y + row*TILE_SIZE;
  return ans;
}
/*
void loadImages() {
  strawberry = loadImage("strawberry.gif");
  cherry = loadImage("cherry.gif");
  apple = loadImage("apple.gif");
  orange = loadImage("orange.gif");
}
*/
void readGhostDirections() {
  String file[] = loadStrings("ghostDirections_pinheiros.txt");
  ghostDirections = new int[mapH][mapW];
  
  for (int i=0; i<mapH; i++) {
    String thisLine = file[i];
    for (int j=0; j<mapW; j++) {
      char thisChar = thisLine.charAt(j);
      switch (thisChar) {
        case 'u':
          ghostDirections[i][j] = 1;
          break;
        case 'r':
          ghostDirections[i][j] = 2;
          break;
        case 'd':
          ghostDirections[i][j] = 3;
          break;
        case 'l':
          ghostDirections[i][j] = 4;
          break;
        default:
          ghostDirections[i][j] = 0;
          break;
      }
    }
  }  
}