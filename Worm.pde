// A Worm is just an array of Segments along a number of points and draw methods
class Worm {

	PVector[] points;
  Segment[] segments;
	
	Worm(PVector[] basePoints) {
	   points = basePoints; 		
	   init();
  }

	void init() {
		if (points.length < 3) {
    	println("Not enough enough points to render");
    	return;
  	}
  
	  println("no. of points " + points.length);

	  segments = new Segment[points.length - 1];  

	  PVector current, next;
	  Segment currentSegment, nextSegment;
	  float displacement = 0.3;

	  PVector[] envelope = generateEnvelope(points.length); 

	  for(int i=0; i < points.length - 1; i++) { 
	    current = points[i];
	    next = points[i+1];
	    float radius = envelope[i].y * 2;
	    segments[i] = new Segment(current, next, radius, displacement);
	  }
  }

	 
	void draw() {
    stroke(fgColor);
    strokeWeight(0.5);

    for(int i=0; i < segments.length - 1; i++) {
      drawSegment(segments[i], segments[i+1], i % 2 == 0);
    }
    // drawEnd(segments[segments.length - 1].toArray(pvArray), points[points.length - 1]);
   }

   void drawSegment(Segment startSegment, Segment endSegment, boolean displaced) {
    // TODO: make this work for differing array sizes.
    PVector[] current = startSegment.points;
    PVector[] next = endSegment.points;

    int last = current.length - 1;
    float extra = 5.0; //random(1.05, 1.25);

    // draw background quad, so segment seems "solid"
    // stroke(bgColor);
    // beginShape();
    // vertex(current[0].x, current[0].y, current[0].z);
    // vertex(nextCurrent[0].x, nextCurrent[0].y, nextCurrent[0].z);
    // vertex(nextCurrent[last].x, nextCurrent[last].y, nextCurrent[last].z);
    // vertex(current[last].x, current[last].y, current[last].z);
    // vertex(current[0].x, current[0].y, current[0].z);
    // endShape(CLOSE);
    // stroke(fgColor);

    // make sure outer lines are not displaced
    line(current[0].x, current[0].y, current[0].z, next[0].x, next[0].y, next[0].z);
    line(current[last].x, current[last].y, current[last].z, next[last].x, next[last].y, next[last].z);

    for(int i = 1; i < last; i++) {
      if(displaced) {
        current = startSegment.displacedPoints;
        next = startSegment.displacedPoints;
        drawLine(current[i], next[i], extra);
      } else {
        drawLine(current[i], next[i], extra);
      }
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
}
