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
import java.util.Vector;

boolean recordPDF = false;
boolean freeze = false;
int centerX;
int centerY;

int linesPerElement = 16;
int lineDistance = 5;
int lineLength = 10;

int bgColor = 255;
color fgColor = color(0, 0, 0);

ArrayList<PVector> basePoints = new ArrayList<PVector>();
PVector[] pvArray = new PVector[0]; 

void setup(){
  // size(800, 600);
  size(800, 600, P3D);

  ortho();
  smooth(8);

  centerX = width/2; 
  centerY = height/2;

  background(bgColor);
  stroke(fgColor);
}

void drawSegment(PVector[] current, PVector[] next, PVector[] nextCurrent) {
  // TODO: make this work for differing array sizes.
  int last = current.length - 1;
  float scale = random(1.05, 1.25);

  // make sure outer lines are not displaced
  line(current[0].x, current[0].y, current[0].z, nextCurrent[0].x, nextCurrent[0].y, nextCurrent[0].z);
  line(current[last].x, current[last].y, current[last].z, nextCurrent[last].x, nextCurrent[last].y, nextCurrent[last].z);

   for(int i = 1; i < last; i++) {
     drawLine(current[i], next[i], scale);
  }
}

void drawLine(PVector start, PVector end, float scale) {
  PVector lineVector =  PVector.sub(end, start);
  lineVector.setMag(lineVector.mag() + 5.0);

  PVector p1 = start.get();
  PVector p2 = PVector.add(start, lineVector);
  
  line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
  // curve(wobble1.x, wobble1.y, wobble1.z, start.x, start.y, start.z, end.x, end.y, end.z, wobble2.x, wobble2.y, wobble2.z);
}

Vector<PVector> generateSegment(PVector current, PVector next, int r, float displacement) {
  Vector<PVector> pointSet = new Vector<PVector>(linesPerElement);

  float phi = -atan2(current.y - next.y, current.x - next.x);   
  float step = PI / linesPerElement;
  
  point(current.x, current.y, current.z);
  point(next.x, next.y, next.z);

  for(int i=0; i<linesPerElement; i++) {
    float theta = HALF_PI + displacement + i * step;

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

void render(PVector[] points) {
  if (points.length < 3) {
    println("Not enough enough points to render");
    return;
  }

  Vector<PVector>[] segments = new Vector[points.length*2 - 2];  

  PVector current;
  PVector next;

  Vector<PVector> currentSegment;
  Vector<PVector> nextSegment;

  float displacement = 0.0;

  for(int i=0; i < points.length - 1; i++) { 
    current = points[i];
    next = points[i+1];
    // create displaced segment on even index with last displacement
    segments[2*i] = generateSegment(current, next, 20, displacement);
    // change displacement
    displacement = random(0.2, 0.4);
    // create displaced segment on odd index
    segments[2*i+1] = generateSegment(current, next, 20, displacement);
  }

  for(int i=1; i < segments.length - 2; i += 2) {
    drawSegment(segments[i].toArray(pvArray), segments[i+1].toArray(pvArray), segments[i+2].toArray(pvArray));
  }
}

PVector[] createSplinePoints(ArrayList<PVector> basePoints, int resolution) {
  if(basePoints.size() < 3) {
    return new PVector[0];
  } 

  ArrayList<PVector> result =  new ArrayList<PVector>();
  ArrayList<PVector> tmpPoints = new ArrayList<PVector>();

  tmpPoints.add(basePoints.get(0));
  tmpPoints.addAll(basePoints);
  tmpPoints.add(basePoints.get(basePoints.size() - 1));

  PVector[] points = tmpPoints.toArray(pvArray);
  PVector t1, t2, p;
  float c1, c2, c3, c4, x, y;

  float tension = 0.5;
  float step = 1.0/resolution;
  
  for(int i=1; i < points.length - 2; i++) {
    for (float st = 0; st <= 1.0; st += step) {
      t1 = new PVector((points[i+1].x - points[i-1].x) * tension, (points[i+1].y - points[i-1].y) * tension, 0.0);
      t2 = new PVector((points[i+2].x - points[i].x) * tension, (points[i+2].y - points[i].y) * tension, 0.0);
      
      c1 =   2 * pow(st, 3)  - 3 * pow(st, 2) + 1; 
      c2 = -(2 * pow(st, 3)) + 3 * pow(st, 2); 
      c3 =       pow(st, 3)  - 2 * pow(st, 2) + st; 
      c4 =       pow(st, 3)  -     pow(st, 2);
       
      x = c1 * points[i].x + c2 * points[i+1].x + c3 * t1.x + c4 * t2.x;
      y = c1 * points[i].y + c2 * points[i+1].y + c3 * t1.y + c4 * t2.y;

      p = new PVector(x, y, 0);
      result.add(p);      
      point(p.x, p.y, p.z);
    }
  }

  return result.toArray(pvArray);
}

void drawHelperPoint(PVector p) {
  strokeWeight(3);
  stroke(fgColor);
  point(p.x, p.y, p.z);  
}

// events
void mousePressed() {
  PVector p;
  PVector[] pointSet;

  if (mouseButton == LEFT) {
    p = new PVector(mouseX, mouseY, 0);
    drawHelperPoint(p);    
    basePoints.add(p);
  } else if (mouseButton == RIGHT) {
    println("Rendering");
    
    background(bgColor);
    stroke(fgColor);

    pointSet = createSplinePoints(basePoints, 10);
    
    strokeWeight(0.5);
    render(pointSet);
    // render(basePoints);
    
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
