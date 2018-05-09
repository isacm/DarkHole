  void drawShip() {
  pushMatrix();
   
  // use the ship's position and direction when drawing it
  
  translate(pos.x, pos.y);
  rotate(direction);
  
  noStroke();
  
  if (dirmagleft.mag() != 0) {
  //left thrustet
  float thrusterCol2 = random(0,255);
  fill(thrusterCol2, thrusterCol2/2, 0);
  triangle(-9, 0, -4, 10, -18, 15);
  }
  
  if (dirmagright.mag() != 0) {
  //rigth truster
  float thrusterCol3 = random(0,255);
  fill(thrusterCol3, thrusterCol3/2, 0);
  triangle(4, 10, 9, 0, 18, 15);
  }
   
  // draw the ship 
  fill(124,252,0);
  ellipse(0,0,20,20);
  fill(0);
  triangle(0, -10, -4, 1, 4, 1);
  
   
  // if the ship is accelerating, draw the thruster
  if (accel.mag() != 0) {
    // use a random color value so that the thruster is flickering
    float thrusterCol = random(0,255);
    fill(thrusterCol, thrusterCol/2, 0);
    triangle(-5, 10, 5, 10, 0, 30);
    //pushMatrix();
    //popMatrix(); 
    
  }
 
  popMatrix(); 
}

void drawShip2() {
  pushMatrix();
   
  // use the ship's position and direction when drawing it
  translate(pos2.x, pos2.y);
  rotate(direction2);
   
  noStroke();
  
   if (dirmagleft2.mag() != 0) {
  //left thrustet
  float thrusterCol2 = random(0,255);
  fill(thrusterCol2, thrusterCol2/2, 0);
  triangle(-9, 0, -4, 10, -18, 15);
  }
  
  if (dirmagright2.mag() != 0) {
  //rigth truster
  float thrusterCol3 = random(0,255);
  fill(thrusterCol3, thrusterCol3/2, 0);
  triangle(4, 10, 9, 0, 18, 15);
  }
   
  // draw the ship as a white triangle
  fill(250);
  ellipse(0,0,20,20);
  fill(0);
  triangle(0, -10, -4, 1, 4, 1);
   
  // if the ship is accelerating, draw the thruster
  if (accel2.mag() != 0) {
    // use a random color value so that the thruster is flickering
    float thrusterCol = random(0,255);
    fill(thrusterCol, thrusterCol/2, 0);
    triangle(-5, 10, 5, 10, 0, 30);
  }
 
  popMatrix(); 
}
