//Desenho dos planetas
//Força gravitica exercida pelo planeta na nave1 e nave2
//Força de impacto quando a nave1 ou nave2 bate no planeta

void draw_planet(PVector ppos, PImage imagem, float raio) {
   
////////DRAW PLANET/////////////////////
  imageMode(CENTER);
  image(imagem, ppos.x, ppos.y, raio, raio); 
  
}

///cenario0
void draw_planetsa() {
  
  draw_planet(pos1a,p1a,95);
  draw_planet(pos2a,p2a,120);
  draw_planet(pos3a,p3a,80);
  draw_planet(pos4a,p4a,75);
  draw_planet(pos5a,p5a,65);
  draw_planet(pos6a,p6a,90);
 
}
