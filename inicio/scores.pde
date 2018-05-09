void drawText() {
    if(sh2){scoreaux=millis()/1000;}
    if(sh1 && !sh2){score=millis()/1000 - scoreaux;}
    
    fill(200);
    textAlign(LEFT, CENTER);
    textSize(30);
    text("JOGADOR 1:  " + score, 70, height-30);  
}

void drawText2() {
  if(sh1){scoreaux2=millis()/1000;}
  if(sh2 && !sh1){score2=millis()/1000 - scoreaux2;}
  fill(200);
  textAlign(RIGHT, CENTER);
  textSize(30);
  text("JOGADOR 2:  " + score2 , width-70, height-30); 
}

void mandascore(){
  if(!sh1 && !sh2){
    
   maxscore=max(score,score2);
   //send("score " + maxscore + "\n");
   
  }
  
}
