void draw_login(){
    
  fill(204,204,204,200);
  rectMode(CENTER);
  rect(width/2,height/2,450,450);
  
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(50);
  text("LOGIN:",width/2,(height/2)-160); 
  
  ///USER
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("USERNAME:",width/2,(height/2)-60);
    
  fill(0,0,0);
  rect(width/2,(height/2)-23,190,25);
  
  fill(255);
  textAlign(LEFT, LEFT);
  textSize(20);
  text(username2,width/2-92,(height/2)-15);
  
  ////PASS
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("PASSWORD:",width/2,(height/2)+50); 
  
  fill(0,0,0);
  rect(width/2,(height/2)+83,190,25);
  
  fill(255);
  textAlign(LEFT, LEFT);
  textSize(20);
  text(passaux2,width/2-92,(height/2)+90);
    
    
}

void draw_registo(){
    
  fill(204,204,204,200);
  rectMode(CENTER);
  rect(width/2,height/2,450,450);
  
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(50);
  text("REGISTO:",width/2,(height/2)-160); 
  
  ///USER
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("USERNAME:",width/2,(height/2)-60);
    
  fill(0,0,0);
  rect(width/2,(height/2)-23,190,25);
  
  fill(255);
  textAlign(LEFT, LEFT);
  textSize(20);
  text(username,width/2-92,(height/2)-15);
  
  ////PASS
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("PASSWORD:",width/2,(height/2)+50); 
  
  fill(0,0,0);
  rect(width/2,(height/2)+83,190,25);
  
  fill(255);
  textAlign(LEFT, LEFT);
  textSize(20);
  text(passaux,width/2-92,(height/2)+90);
        
}

void draw_menuinicio(){
    
  fill(204,204,204,200);
  rectMode(CENTER);
  rect(width/2,height/2,450,450);
  
  ///USER
  fill(0);
  textAlign(CENTER,CENTER);
  textSize(40);
  text("1 - REGISTO",width/2,(height/2)-60);

  
  ////PASS
  fill(0);
  textAlign(CENTER,CENTER);
  textSize(40);
  text("2 - LOGIN",width/2,(height/2)+50); 
  
 
}


