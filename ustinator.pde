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

boolean drawWayPoints = false;

int linesPerElement = 16;
int bgColor = color(255, 255, 255);
color fgColor = color(0, 0, 0);
int splineResolution = 10;

int baseRadius = 10;
int radiusSpread = 5;

ArrayList<PVector> basePoints = new ArrayList<PVector>();
PVector[] pvArray = new PVector[0]; 

void setup(){
  size(1024, 768, P3D);
  //ortho();
  smooth(8);
  fill(bgColor);

  background(bgColor);
  stroke(fgColor);
}

void drawSegment(PVector[] current, PVector[] next, PVector[] nextCurrent) {
  // TODO: make this work for differing array sizes.
  int last = current.length - 1;
  float extra = 5.0; //random(1.05, 1.25);

  // draw background quad, so segment seems "solid"
  stroke(bgColor);
  beginShape();
  vertex(current[0].x, current[0].y, current[0].z);
  vertex(nextCurrent[0].x, nextCurrent[0].y, nextCurrent[0].z);
  vertex(nextCurrent[last].x, nextCurrent[last].y, nextCurrent[last].z);
  vertex(current[last].x, current[last].y, current[last].z);
  vertex(current[0].x, current[0].y, current[0].z);
  endShape(CLOSE);
  stroke(fgColor);

  // make sure outer lines are not displaced
  line(current[0].x, current[0].y, current[0].z, nextCurrent[0].x, nextCurrent[0].y, nextCurrent[0].z);
  line(current[last].x, current[last].y, current[last].z, nextCurrent[last].x, nextCurrent[last].y, nextCurrent[last].z);

  for(int i = 1; i < last; i++) {
    drawLine(current[i], next[i], extra);
  }
}

void drawEnd(PVector[] current, PVector endpoint) {
  for(int i = 0; i < current.length; i++) {
    drawLine(current[i], endpoint, 0.0);
  }
}

void drawLine(PVector start, PVector end, float extra) {
  PVector lineVector =  PVector.sub(end, start);
  lineVector.setMag(lineVector.mag() + extra);

  PVector p1 = start.get();
  PVector p2 = PVector.add(start, lineVector);
  
  line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
  // curve(wobble1.x, wobble1.y, wobble1.z, start.x, start.y, start.z, end.x, end.y, end.z, wobble2.x, wobble2.y, wobble2.z);
}

PVector[] generateEnvelope(int numPoints, float xLength) {
  PVector[] result;
  ArrayList<PVector> basePoints = new ArrayList<PVector>();
  
  int numBasePoints = (numPoints / splineResolution) + 1;
  println("envelope spline basePoints: " + numBasePoints); 
  //float xStep = xLength / numBasePoints;
  float x, y;
  PVector p;

  for(int i = 0; i < numBasePoints - 1; i++) {
    //p = new PVector(i * xStep, maxValue + random(-spread, spread), 0.0);
    p = new PVector(i * 10, random(baseRadius - radiusSpread, baseRadius + radiusSpread), 0.0);
    basePoints.add(p);
    point(p.x, p.y, p.z);
  }  
  p = new PVector(numBasePoints * 10, 0.0, 0.0);
  basePoints.add(p);
  
  result = createSplinePoints(basePoints, splineResolution);
  println("envelope size: " + result.length);
  return result;
}

Vector<PVector> generateSegment(PVector current, PVector next, float r, float displacement) {
  Vector<PVector> pointSet = new Vector<PVector>(linesPerElement);

  PVector p;
  float x, y, z, theta;
  float phi = -atan2(current.y - next.y, current.x - next.x);   
  float step = PI / linesPerElement;

  point(current.x, current.y, current.z);
  point(next.x, next.y, next.z);

  for(int i=0; i<linesPerElement; i++) {
    theta = -HALF_PI + displacement + i * step;

    x = current.x + r * sin(theta) * sin(phi);
    y = current.y + r * sin(theta) * cos(phi);
    z = current.z + r * cos(theta);  
    // println(x + " " + y + " " + z);

    p = new PVector(x, y, z);

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
  
  println("no. of points " + points.length);

  Vector<PVector>[] segments = new Vector[points.length*2 - 2];  

  PVector current, next;
  Vector<PVector> currentSegment, nextSegment;
  float displacement = 0.0;

  stroke(fgColor);
  strokeWeight(0.5);

  float vectorLength = PVector.sub(points[points.length - 1], points[0]).mag();
  println("totalLength: "+vectorLength);

  PVector[] envelope = generateEnvelope(points.length, vectorLength); 

  for(int i=0; i < points.length - 1; i++) { 
    current = points[i];
    next = points[i+1];
    float radius = envelope[i].y * 2;
    // create displaced segment on even index with last displacement
    segments[2*i] = generateSegment(current, next, radius, displacement);
    // change displacement
    displacement = i % 2 == 0 ? 0.2 : 0.3;
    // create displaced segment on odd index
    segments[2*i+1] = generateSegment(current, next, radius, displacement);
  }

  for(int i=1; i < segments.length - 2; i += 2) {
    drawSegment(segments[i].toArray(pvArray), segments[i+1].toArray(pvArray), segments[i+2].toArray(pvArray));
  }

  drawEnd(segments[segments.length - 1].toArray(pvArray), points[points.length - 1]);
}

PVector[] createSplinePoints(ArrayList<PVector> basePoints, int resolution) {
  if(basePoints.size() < 3) {
    return new PVector[0];
  } 

  println("spline base points: "+basePoints.size());

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
      if(drawWayPoints) { point(p.x, p.y, p.z); };
      result.add(p);      
    }
  }

  println("spline result points: "+result.size());
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
    clearHelperPoints();
    pointSet = createSplinePoints(basePoints, splineResolution);
    render(pointSet);
    basePoints.clear();
  }
}

void clearHelperPoints() {
  PVector p;
  ListIterator<PVector> i = basePoints.listIterator();

  strokeWeight(3);  
  stroke(bgColor);

  while(i.hasNext()) {
    p = i.next(); 
    point(p.x, p.y, p.z);
  }

  stroke(fgColor);
}