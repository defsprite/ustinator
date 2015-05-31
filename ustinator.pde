// import processing.pdf.*;
import java.util.Calendar;
import java.util.ListIterator;
import java.util.Vector;

boolean drawWayPoints = false;

int linesPerElement = 16;
int bgColor = color(255, 255, 255);
color fgColor = color(0, 0, 0);
int splineResolution = 10;

int baseRadius = 10;
int radiusSpread = 3;

ArrayList<PVector> basePoints = new ArrayList<PVector>();
PVector[] pvArray = new PVector[0]; 

void setup(){
  size(1024, 768, P3D);
  ortho();
  smooth(8);
  fill(bgColor);

  background(bgColor);
  stroke(fgColor);
}

void draw() {
  // keep draw, so events work
}

void render(PVector[] points) {
  Worm worm = new Worm(points);
  worm.draw();
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

PVector[] generateEnvelope(int numPoints) {
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

