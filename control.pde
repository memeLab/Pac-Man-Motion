void keyPressed() {
  
  // change treshhold
  int t = tracker.getThreshold();
  if (key == 'z') {
    t+=5;
    tracker.setThreshold(t);
  } else if (key == 'x') {
    t-=5;
    tracker.setThreshold(t);
  }
  
  // mode Pac-Man with keyboard
  if (pac.moving) {
    if (key == CODED) {
      if (keyCode == UP) {
        pac.moveRequested = 1;
      } else if (keyCode == RIGHT) {
        pac.moveRequested = 2;
      } else if (keyCode == DOWN) {
        pac.moveRequested = 3;
      } else if (keyCode == LEFT) {
        pac.moveRequested = 4;
      }
    } 
  }

  if ((key == '.') || (key == ' ')) {
    if (paused == 0) {
        paused = 1;
        redraw();
      } else {
        paused = 0;
        redraw();
      }
  }

}

void move() {
  // draw the raw location
  PVector v1 = tracker.getPos();
  fill(255,255,255);
  noStroke();
  ellipse(v1.x,v1.y,20,20);
  
  // choose direction
  if (v1.x < (width/3)) {
    pac.moveRequested = 4; // left
  } else if (v1.x > ((width/3)*2)) {
    pac.moveRequested = 2; // right
  } else if (v1.y < (height/3)) {
    pac.moveRequested = 1; // up
  } else if (v1.y > ((height/3)*2)) {
    pac.moveRequested = 3; // down
  }
}
