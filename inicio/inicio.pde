void setup() {
  size(1200, 700);
  
  pos = new PVector(150, 600, 0); //initial position of ship1
  accel = new PVector();
  dirmagleft= new PVector();
  dirmagright= new PVector();
  
  pos2 = new PVector(width-150, 600, 0); //initial position of ship2
  accel2 = new PVector();
  dirmagleft2= new PVector();
  dirmagright2= new PVector();
  
    
  //loading images for planets
  p1a = loadImage("p1a.png");
  p2a = loadImage("p2a.png");
  p3a = loadImage("p3a.png");
  p4a = loadImage("p4a.png");
  p5a = loadImage("p5a.png");
  p6a = loadImage("p6a.png");
  
  //loading image for background
  fundo= loadImage("space.jpg");
  
  
  //keeping setting up planets1a
  
  pos1a = new PVector(width/2, height/2+200, 0);
  pos2a = new PVector(width/2+100, height/2 - 200, 0);  
  pos3a = new PVector(width/2-400, height/2 - 230, 0);
  pos4a = new PVector(140, height/2, 0);  
  pos5a = new PVector(width/2-200, height/2+250, 0);
  pos6a = new PVector(width/2+300, 200, 0);

  //end of keeping setting up planets1a
  
    //endereço->String
    //porta-> int


  try{
     socket = new Socket("169.254.232.200",12345);
     in = new BufferedReader( new InputStreamReader(socket.getInputStream()));
     out = new PrintStream(socket.getOutputStream());
  }catch(Exception e){ System.out.println(e.getMessage()); }
  
  
  try{
   thread= new Mensagens();
   thread.start();
  }catch(Exception e){ System.out.println(e.getMessage()); }
  
  
}

 
void draw() {
  
  
    background(fundo);
    
    if(escolha==0){
      draw_menuinicio();
    }
    
    if(escolha==1){      
      draw_registo();
      //println("cheguei aqui");

    }
    
    if(escolha==2){   
     draw_login();
        
    }
    
    
    if(escolha==3){
     
     if(frameCount!=antigoframe){
       send("frame\n");
       antigoframe=frameCount;
      }
      
      checkKeys();
 
      draw_planetsa();
      
       //////SCORES
      drawText();
      drawText2();
  
      ///////
      draw_fuel1();
      draw_fuel2();
 
      draw_buraconegro();
      
      if(sh1) {drawShip();}
      if(sh2){drawShip2();}
      
    }
       
}


 void keyTyped() {
   
   if(escolha==0){
     if(keyPressed && key=='1'){
     escolha=1;
     }
     
     if(keyPressed && key=='2'){
     escolha=2;
     }
   
   }
   
  if(escolha==1){
   
    if(keyPressed && key=='\n' && flagkey==0) {send("registar " + username + " " + password + "\n");}
  
    else if(keyPressed && key=='\n' && flagkey==1) {
      flagkey=0;
    }
  
    else if(keyPressed && key!='1' && flagkey==1){
        username+=key;   
    }
  
    else if(keyPressed && flagkey==0){
       password+=key;
       passaux+='*';  
    }
 
  }
   
  if(escolha==2){
    
   
    if(keyPressed && key=='\n' && flagkey2==0) {send("login " + username2 + " " + password2 + "\n");}
  
    else if(keyPressed && key=='\n' && flagkey2==1) {
    flagkey2=0;
    }
  
    else if(keyPressed && key!='2' && flagkey2==1){
        username2+=key;   
    }
  
    else if(keyPressed && flagkey2==0){
       password2+=key;
       passaux2+='*';  
    }
 
  }
    
}


