//
//X and Y values for ball.
//
float x1 = 300;
float y1 = 400;
float x2 = -0.75;

float speed = 0;
float gravity = -0.1;

//
//Stretch factor for catenary.
//
float a = 320f;

void setup()
{
  size(600, 500);
  strokeWeight(1);
}
void draw()
{
  background(255);
  translate(0, height);
  scale(1, -1);
  //
  //
  //Catenary
  //
  //

  //
  //Set stretch factor value
  //

  //
  //x and y values for the first point to construct a line
  //
  float xprev, yprev;
  xprev = -200f;
  yprev = a/2*(exp(xprev/a)+exp(-xprev/a));

  //
  //Runs until x = 200, creates lines to form a catenary
  //
  for (float x = -200; x < 200; x+= 10f) 
  {
    //
    //Formula for a catenary
    //
    float y = a/2*(exp(x/a)+exp(-x/a));

    line(xprev+300, yprev-100, x+300, y-100);

    //
    //Sets newly created x and y to xprev/yprev so the next line
    //created starts where the last line created ends
    //
    xprev = x;
    yprev = y;
  }


  //
  //
  //Bouncing ball.
  //
  //

  int m = millis()/1000;

  fill(150);
  stroke(0);

  //
  //Drawing circle.
  //
  ellipse(x1, y1, 15, 15);

  //
  //Stops oscillation at the end.
  //
  if ( m == 10) 
  {
    speed = 0;
    gravity = 0;
  }

  //
  //Applying velocity.
  //
  y1 = y1 + speed;

  //
  //Applying gravity.
  //
  speed = speed + gravity;

  //
  //Creating bounce.
  //
  if (y1 < 0+5) 
  {
    speed = speed * x2 ;

    x2 = x2 - 0.01 * gravity;

    y1 = 0+5;
  }
}
