import java.util.*;
import java.net.*;
import java.io.*;
class Mensagens extends Thread{
  
  String mensagem;
  
 Mensagens() throws Exception{
   mensagem=" ";
 }
   
synchronized void run(){
        while(true){
           /* 
            try{
               Thread.sleep(3);
             }catch(Exception e){ System.out.println(e.getMessage()); }
          */
            try{
              mensagem = in.readLine();
            }catch(IOException e){ System.out.println(e.getMessage()); }
            
        
          if(mensagem != null){
             StringTokenizer stk = new StringTokenizer(mensagem," ");
             String token = stk.nextToken();
             
             
             if(token.equals("registook")){
               escolha=0;
             }
             
             if(token.equals("registoinvalido")){
               flagkey=1;
               username="";
               password="";
               passaux=""; 
             }
             
             if(token.equals("loginok")){
               escolha=3;  
             }
             
             if(token.equals("logininvalido")){
               flagkey2=1;
               username2="";
               password2="";
               passaux2="";  
             }
           
             if(token.equals("jogador")){
               
               pos.x=Float.parseFloat(stk.nextToken());
               pos.y=Float.parseFloat(stk.nextToken());
               accel.x=Float.parseFloat(stk.nextToken());
               accel.y=Float.parseFloat(stk.nextToken());
               direction=Float.parseFloat(stk.nextToken());
               totalfuel=Float.parseFloat(stk.nextToken());
               dirmagright.x=Float.parseFloat(stk.nextToken());
               dirmagright.y=Float.parseFloat(stk.nextToken());
               dirmagleft.x=Float.parseFloat(stk.nextToken());
               dirmagleft.y=Float.parseFloat(stk.nextToken());
             
               String alive= stk.nextToken();
             
               if(alive.equals("dead")) sh1=false;
               
               //print(pos.x + " " + pos.y + " " + accel.x + " " + accel.y + " " + direction + " " + totalfuel + " " + dirmagright.x + " " + dirmagright.y + " " + dirmagleft.x + " " + dirmagleft.y + " " + alive + "\n");
             
              }
            
            if(token.equals("adversario")){
             pos2.x=Float.parseFloat(stk.nextToken());
             pos2.y=Float.parseFloat(stk.nextToken());
             accel2.x=Float.parseFloat(stk.nextToken());
             accel2.y=Float.parseFloat(stk.nextToken());
             direction2=Float.parseFloat(stk.nextToken());
             totalfuel2=Float.parseFloat(stk.nextToken());
             dirmagright2.x=Float.parseFloat(stk.nextToken());
             dirmagright2.y=Float.parseFloat(stk.nextToken());
             dirmagleft2.x=Float.parseFloat(stk.nextToken());
             dirmagleft2.y=Float.parseFloat(stk.nextToken());
             
             String alive= stk.nextToken();
             
             if(alive.equals("dead")) sh2=false;
             
             //print(pos.x + " " + pos.y + " " + accel.x + " " + accel.y + " " + direction + " " + totalfuel + " " + dirmagright.x + " " + dirmagright.y + " " + dirmagleft.x + " " + dirmagleft.y + " " + alive + "\n");
             
            }
            
            if(token.equals("planetas")){
               pos1a.x=Float.parseFloat(stk.nextToken());
               pos1a.y=Float.parseFloat(stk.nextToken());
               pos2a.x=Float.parseFloat(stk.nextToken());
               pos2a.y=Float.parseFloat(stk.nextToken());
               pos3a.x=Float.parseFloat(stk.nextToken());
               pos3a.y=Float.parseFloat(stk.nextToken());
               pos4a.x=Float.parseFloat(stk.nextToken());
               pos4a.y=Float.parseFloat(stk.nextToken());
               pos5a.x=Float.parseFloat(stk.nextToken());
               pos5a.y=Float.parseFloat(stk.nextToken());
               pos6a.x=Float.parseFloat(stk.nextToken());
               pos6a.y=Float.parseFloat(stk.nextToken());
               
               //print(pos1a.x + " " + pos1a.y + " " + pos2a.x + " " + pos2a.y + " " + pos3a.x + " " + pos3a.y + " " + pos4a.x + " " + pos4a.y + " " + pos5a.x + " " + pos5a.y + " " + pos6a.x + " " + pos6a.y + "\n");
            }
            
        }
     }
        
    
  }
  
 /*
 synchronized void run(){
   while(true){ 
     
       try{
          Thread.sleep(1);
       }catch(Exception e){ System.out.println(e.getMessage()); }
       
     println("tou a receber"); 
   } 
}
*/
  
}


/*
void send(String mensagem){
  
  print(mensagem);
}
*/


void send(String mensagem){
      StringBuilder result = new StringBuilder();
      result.append(mensagem);
      out.print(result.toString());
      out.flush();
     
   }
   


