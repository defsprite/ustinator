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
	  PVector[] envelope = generateEnvelope(points.length);

	  for(int i=0; i < points.length - 1; i++) { 
	    current = points[i];
	    next = points[i+1];
      float radius1 = envelope[i].y * 2;
	    float radius2 = envelope[i+1].y * 2;
	    float displacement = random(-0.15, 0.15);
      segments[i] = new Segment(current, next, radius1, radius2, displacement);
	  }
  }

	 
	void draw() {
    stroke(fgColor);
    strokeWeight(0.5);

    for(int i=0; i < segments.length; i++) {
      drawSegment(segments[i]);
    }
    // drawEnd(segments[segments.length - 1].toArray(pvArray), points[points.length - 1]);
   }

   void drawSegment(Segment segment) {
    // TODO: make this work for differing array sizes.
    PVector[] current = segment.startPoints;
    PVector[] next = segment.endPoints;

    int last = current.length - 1;
    float extra = 5.0; //random(1.05, 1.25);

    // draw background quad, so segment seems "solid"
    stroke(bgColor);
    beginShape();
    vertex(current[0].x, current[0].y, current[0].z);
    vertex(next[0].x, next[0].y, next[0].z);
    vertex(next[last].x, next[last].y, next[last].z);
    vertex(current[last].x, current[last].y, current[last].z);
    vertex(current[0].x, current[0].y, current[0].z);
    endShape(CLOSE);
    stroke(fgColor);

    for(int i = 0; i <= last; i++) {
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
}
