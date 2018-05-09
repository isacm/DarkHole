void draw_fuel1(){
 rectMode(CORNER);
 noStroke();
 fill(255,0,0,170);
 if(totalfuel>0)rect(71, height-55,totalfuel,15);
}

void draw_fuel2(){
 rectMode(CORNER);
 noStroke();
 fill(255,0,0,170);
 if(totalfuel2>0) rect(width-287, height-55,totalfuel2,15);
}
