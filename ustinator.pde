/**
 * form mophing process by connected random agents
 * 
 * MOUSE
 * click               : start a new circe
 * position x/y        : direction of floating
 * 
 * KEYS
 * 1-2                 : fill styles
 * f                   : freeze. loop on/off
 * Delete/Backspace    : clear display
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;
boolean freeze = false;
int centerX;
int centerY;

int linesPerElement = 10;
int lineDistance = 5;
int lineLength = 10;

void setup(){
  size(800, 600, P3D);
  ortho();
  
  centerX = width/2; 
  centerY = height/2;

  background(255);
  strokeWeight(3);
  noSmooth();

  PVector center = new PVector(centerX, centerY, 0);
  PVector xAxis = new PVector(centerX, 0, 0);
  PVector current = new PVector(0, 50, 0);
  PVector next = new PVector(150, 15, 0);
  
  ArrayList<PVector> lastPoints = new ArrayList<PVector>();

  int r = 20;
  float phi = HALF_PI - PVector.angleBetween(current, PVector.sub(current, next));   
  float step = PI / linesPerElement;
  
  point(current.x, current.y, current.z);
  point(next.x, next.y, next.z);

  for(int i=0; i<linesPerElement; i++) {
    float theta = HALF_PI + i * step;

    float xPos = current.x + r * sin(theta) * sin(phi);
    float yPos = current.y + r * sin(theta) * cos(phi);
    float zPos = current.z + r * cos(theta);  
    // println(xPos + " " + yPos + " " + zPos );

    PVector p = new PVector(xPos, yPos, zPos);

    point(p.x, p.y, p.z);
    lastPoints.add(p);
  }

  // initialize first points

  // outer line should be continouus
  // push first elem

  // generate lines in between, push next points along the way


  // push last elem
}


void draw(){
}


// events
void mousePressed() {
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == DELETE || key == BACKSPACE) background(255);

  // ------ pdf export ------
  // press 'r' to start pdf recording and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+".pdf");
      println("recording started");
      recordPDF = true;
      stroke(0, 50);
    }
  } 
  else if (key == 'e' || key =='E') {
    if (recordPDF) {
      println("recording stopped");
      endRecord();
      recordPDF = false;
      background(255); 
    }
  } 

  // switch draw loop on/off
  if (key == 'f' || key == 'F') freeze = !freeze;
  if (freeze == true) noLoop();
  else loop();
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}









