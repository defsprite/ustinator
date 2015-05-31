class Segment {

  int linesPerSegment = 16;
  PVector startPoint; 
  PVector endPoint;
  float radius;
  float displacement;
	
	PVector[] points;
	PVector[] displacedPoints;
  PVector[] bogus = new PVector[0];

	Segment(PVector current, PVector next, float r, float d) {
    startPoint = current;
    endPoint = next;
    radius = r;
    displacement = d;    
    init();
	}

  void init() {
    points = generatePoints(startPoint, endPoint, radius, 0);
    displacedPoints = generatePoints(startPoint, endPoint, radius, displacement); 
  }

  PVector[] generatePoints(PVector current, PVector next, float radius, float displacement) {
    Vector<PVector> pointSet = new Vector<PVector>(linesPerSegment);

    PVector p;
    float x, y, z, theta;
    float phi = -atan2(current.y - next.y, current.x - next.x);   
    float step = PI / linesPerSegment;

    point(current.x, current.y, current.z);
    point(next.x, next.y, next.z);

    for(int i=0; i<linesPerSegment; i++) {
      theta = -HALF_PI + displacement + i * step;

      x = current.x + radius * sin(theta) * sin(phi);
      y = current.y + radius * sin(theta) * cos(phi);
      z = current.z + radius * cos(theta);  
      // println(x + " " + y + " " + z);

      p = new PVector(x, y, z);

      point(p.x, p.y, p.z);
      pointSet.add(p);
    }

    return pointSet.toArray(bogus);
  } 
}
