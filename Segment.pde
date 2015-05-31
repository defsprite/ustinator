class Segment {

  int linesPerSegment = 16;
  PVector startPoint; 
  PVector endPoint;
  
  float startRadius;
  float endRadius;
  float displacement;
	
	PVector[] startPoints;
	PVector[] endPoints;
  PVector[] bogus = new PVector[0];

	Segment(PVector current, PVector next, float r1, float r2, float d) {
    startPoint = current;
    endPoint = next;
    startRadius = r1;
    endRadius = r2;
    displacement = d;
    linesPerSegment = floor((startRadius) / 1.5);
    init();
	}

  void init() {
    float phi = -atan2(startPoint.y - endPoint.y, startPoint.x - endPoint.x);
    
    startPoints = generatePoints(startPoint, phi, startRadius, displacement);
    endPoints = generatePoints(endPoint, phi, endRadius, displacement); 
  }

  PVector[] generatePoints(PVector center, float phi, float radius, float displacement) {
    Vector<PVector> pointSet = new Vector<PVector>(linesPerSegment);
    PVector p;
    float theta;
    float step = PI / linesPerSegment;

    pointSet.add(polar2vector(center, radius, -HALF_PI, phi));

    for(int i = 1; i < linesPerSegment; i++) {
      theta = -HALF_PI + displacement + i * step;
      p = polar2vector(center, radius, theta, phi);
      // point(p.x, p.y, p.z);
      pointSet.add(p);
    }

    pointSet.add(polar2vector(center, radius, HALF_PI, phi));

    return pointSet.toArray(bogus);
  }

  PVector polar2vector(PVector center, float r, float theta, float phi) {
    float x, y, z;
    
    x = center.x + r * sin(theta) * sin(phi);
    y = center.y + r * sin(theta) * cos(phi);
    z = center.z + r * cos(theta);  
    
    return new PVector(x, y, z);
  } 
}
