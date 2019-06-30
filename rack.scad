Pi = 3.1416;


module Hole(l, v1, r, v2) {
  w1 = perp(v1);
  w2 = -perp(v2);
  c = intersect(l, w1, r, w2);
  translate(c) 
   circle(distance(c, l), $fn = 100);
}

function ToothVertices(a, phi, t) =
	[
	  	[-a*tan(phi)-t/2, 0], 
  		[-t/2+a*tan(phi), 2*a],   
  		[t/2-a*tan(phi), 2*a],
  		[a*tan(phi)+t/2, 0],
	  ];


module gear(P, N) {
  // See Gear Theory, p. 5
  phi = 20;
  p = 3.1416/P;
  a = 1/P;
  t = 1.5708/P;
  ht = 2.157/P;
  b = ht - a;
  c = ht - 2*a;
  D = N/P;
  Dr = D - 2*b;
  Db = D*cos(phi);

  ToothTranslation = [0, Db/2];

  V = ToothVertices(a, phi, t);
  L = V[3] + ToothTranslation;
  Ltemp = V[2] + ToothTranslation;
  V1  = L - Ltemp;

  R = VecRotate (-360/N, V[0] + ToothTranslation);
  Rtemp = VecRotate (-360/N, V[1] + ToothTranslation);
  W1 = R - Rtemp;
  
  linear_extrude(height = .5, center = true, convexity = 10, twist = 0) // 2d -> 3d
{  for (i = [0 : N - 1]) 
    rotate(360*i/N) 
{
    translate([0, Db/2])
      tooth(a, phi, t);
      difference() 
      {
         polygon(points = [V[0] + ToothTranslation, L, R, [0, 0]], paths = [[0, 1, 2, 3, 0]]);
         Hole(L, V1, R, W1);
      }
 } 
}
}


module rack(P, Depth, TeethNumber) {
  // See Gear Theory, p. 5
  phi = 20;
  p = 3.1416/P;
  a = 1/P;
  t = 1.5708/P;
  ht = 2.2/P;
  c = ht - 2*a;

  RackDepth = Depth*a;

  linear_extrude(height = .5, center = true, convexity = 10, twist = 0) // 2d -> 3d
  {
    for (i = [0:TeethNumber-1]) {
      translate( [i*p, 0])
	    tooth(a, phi, t);
    }

    difference() 
    {
      translate([-p/2, 0])
        polygon(
          points = [
            [0, 0], [p*TeethNumber, 0], 
            [p*TeethNumber, -RackDepth], [0, -RackDepth]
          ],
          paths = [[0, 1, 2, 3, 0]]
        );

      for (i = [0:TeethNumber-1]) {
        translate([p/2+i*p, 0])
          PunchHole(a, p/2 - t/2 - a*tan(phi));
      }
    }
  }
}


module tooth(a, phi, t) {
    polygon(points = ToothVertices(a, phi, t), 
	  paths = [[0, 1, 2, 3, 0]]
    );
  }

module PunchHole(a, r) {
  translate([0, .1*a])
    circle(r = r, $fn = 100);
}

// simple 2D linear algebra.

function intersect(a, v, b, w) = 
  a + v*((
    (b - a)[0]*w[1] - w[0]*(b-a)[1]
  )/(v[0]*w[1] - w[0]*v[1])
  );

function perp(v) = [-v[1], v[0]];

function norm(v) = sqrt(v[0]*v[0] + v[1]*v[1]);

function distance(v1, v2) = norm(v2 - v1);

function VecRotate(deg, v) = 
  [ v[0]*cos(deg) - v[1]*sin(deg)
  , v[1]*cos(deg) + v[0]*sin(deg)];


/////////////////////////////////////////////////////////


gear(8, 16);

translate([-1.7725, -1.3])
  rack(8, 3, 11);