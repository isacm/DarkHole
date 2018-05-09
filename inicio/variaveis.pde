// A PVector holds three values, and allow operations
// such as adding and multiplying vectors.

import java.util.concurrent.*;
import java.io.*;
import java.net.*;
import java.util.*;
import java.util.Scanner;

//ship1 setup
PVector pos;    // ship's position
PVector accel;// ship's acceleration
float direction; // ship's direction
PVector dirmagleft;
PVector dirmagright;
float totalfuel=174;
boolean sh1=true;

//ship2 setup
PVector pos2;
PVector accel2;
float direction2;
PVector dirmagleft2;
PVector dirmagright2;
float totalfuel2=174;
boolean sh2=true;

//planets1a setup
PVector pos1a;
PVector pos2a;
PVector pos3a;
PVector pos4a;
PVector pos5a;
PVector pos6a;
//end of planets1a setup

//vars for score
int score=0;
int score2=0;
int scoreaux=0;
int scoreaux2=0;
float maxscore=0;

//other stuff
int contador =0;
int flagkey = 1; 
String username="";
String password="";
String passaux="";

int flagkey2 = 1; 
String username2="";
String password2="";
String passaux2="";

Boolean mylogin=false;
int antigoframe=0;
int escolha=0;

//Initialazing images
PImage fundo;

PImage p1a;
PImage p2a;
PImage p3a;
PImage p4a;
PImage p5a;
PImage p6a;
//End of Initialazing images

Thread thread;

Socket socket;
BufferedReader in;
PrintStream out;

