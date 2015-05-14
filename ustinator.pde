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
import java.util.ListIterator;

boolean recordPDF = false;
boolean freeze = false;
int centerX;
int centerY;

int linesPerElement = 10;
int lineDistance = 5;
int lineLength = 10;

int bgColor = 255;
color fgColor = color(0, 0, 0);

ArrayList<PVector> basePoints = new ArrayList<PVector>();  

void setup(){
  size(800, 600, P3D);
  ortho();
  smooth(4);

  centerX = width/2; 
  centerY = height/2;

  background(bgColor);
  stroke(fgColor);
  strokeWeight(3);
}

void drawSegment(PVector[] current, PVector[] next) {
  // connect first
  // connect last
  // TODO: make this work for differing array sizes.
  int last = current.length - 1;

  line(current[0].x, current[0].y, current[0].z, next[0].x, next[0].y, next[0].z);
  line(current[last].x, current[last].y, current[last].z, next[last].x, next[last].y, next[last].z);
}

ArrayList<PVector> generateSegment(PVector current, PVector next) {
  ArrayList<PVector> pointSet = new ArrayList<PVector>();

  int r = 20;
  float phi = -atan2(current.y - next.y, current.x - next.x);   
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
    pointSet.add(p);
  }

  return pointSet;
}


void draw() {
  // keep draw, so events work
}

void render(ArrayList<PVector> basePoints) {
  ListIterator<PVector> i = basePoints.listIterator();
  PVector current;
  PVector next;
  ArrayList<PVector> currentSegment;
  ArrayList<PVector> nextSegment;
  PVector[] type = new PVector[0];



  stroke(fgColor);
  strokeWeight(3);

  if (basePoints.size() < 2) {
    return;
  }

  current = i.next();
  next = i.next();
  currentSegment = generateSegment(current, next);
  line(current.x, current.y, current.z, next.x, next.y, next.z);
  
  while(i.hasNext()) {
    
    current = next;
    next = i.next();

    line(current.x, current.y, current.z, next.x, next.y, next.z);
    nextSegment = generateSegment(current, next);

    drawSegment(currentSegment.toArray(type), nextSegment.toArray(type));
    currentSegment = nextSegment;
  }
}

void clearHelperPoints(ArrayList<PVector> points) {
  PVector p;
  ListIterator<PVector> i = points.listIterator();

  strokeWeight(3);
  stroke(bgColor);
  
  while(i.hasNext()) {
    p = i.next();
    point(p.x, p.y, p.z);    
  }
}

void drawHelperPoint(PVector p) {
  strokeWeight(3);
  stroke(fgColor);
  point(p.x, p.y, p.z);  
}

// events
void mousePressed() {
  PVector p;

  if (mouseButton == LEFT) {
    p = new PVector(mouseX, mouseY, 0);
    drawHelperPoint(p);    
    basePoints.add(p);
  } else if (mouseButton == RIGHT) {
    println("Rendering");
    clearHelperPoints(basePoints);
    render(basePoints);
    basePoints.clear();
  }
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









