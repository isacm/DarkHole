void checkKeys() {
   
  if (keyPressed && key == CODED) {
    if (keyCode == LEFT) {
      if(sh1){
        if(totalfuel>0){
          String esquerda="movimento E\n";
          send(esquerda);
        }
      }
    }
    else if (keyCode == RIGHT) {
      if(sh1){
        if(totalfuel>0){
           String direita="movimento D\n";
           send(direita);
        }
      }
    }
    else if (keyCode == UP) {
      if(sh1){
        if(totalfuel>0){
          String frente="movimento F\n";
          send(frente);
        }
      }
    }
  } 
}
