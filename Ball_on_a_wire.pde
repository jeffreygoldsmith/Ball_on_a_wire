/*
 * Research sag in relation to a catenary
 */
private static final int W = 600;               // Width of canvas
private static final int H = 500;               // Height of canvas
private static final float Y_MARGIN = 25f;      // Margin above and below flight path
private static final float DF = -0.75f;         // Dampening factor
private static final float X_STEP = 20f;        // Line length to create catenary
private static final float X_ORIGIN = 300f;     // X value of first catenary pole
private static final float Y_ORIGIN = -100f;    // Y value of first catenary pole
private static final float Y_TOL = 0.01f;       // If the Y of catenary is within Y_TOL to Y_ORIGIN, stop drawing
private static final float TF = 3.5f / 1000f;   // Accelerates time
private static float SF = 320f;                 // Stretch factor for catenary
private static final float X_START = -200f;      // Horizontal position of start left pole
private static final float Y_START = cat(X_START, SF);
private static final float DIAM = 15f;          // Diameter of ball
private static final float Y_OFFSET = 15f;      // Image y offset
private static final float X_OFFSET = 27f;      // Image x offset
private static final float Y_RANGE = (H - Y_START) / 2f; 

float x;                                        // X of ball
float y = H;                                    // Y of ball
float yPrev = y;                                // Lagging value of object
float velocity = 0f;                            // Velocity of ball
float gravity = -9.8f;                          // Gravity
float t0 = 0f;                                  // Value to reset time
float tPrev = 0f;                               // Lagging value of time



//
// Function of catenary equation
//
static float cat(float x, float sf)
{
  return sf / 2 * (exp(x / sf) + exp(-x / sf));
}

//
// Run once
//
void setup()
{ 
  size(W, H); // Set canvas size
  fill(150); // Set colour
  stroke(0); // Set border width
}

//
// Run loop
//
void draw()
{
  translate(0, height); // Invert ordinate
  scale(1, -1);
  background(255);
  //background(87, 223, 250); // Set background to blue

  //
  // x and y values for the first point to construct a line
  //
  float catXPrev = X_START;

  //
  // Draw bouncing ball.
  //
  float t = millis() * TF; // Accelerated time, in seconds
  float deltaT = tPrev == 0f ? 0f : t - tPrev; // Difference between time and lagging time
   
  //x = (X_START + catXPrev) * 0.5; // Set x value of ball to midpoint of catenary (constant)
  x = 0f; //!
  y = gravity * 0.5 * deltaT * deltaT + velocity * deltaT + yPrev; // Compute height of projectile
  
  velocity += -DF * gravity * deltaT; // Compute new velocity
  
  //
  // Create bounce.
  //
  float catY = cat(x, SF) + DIAM / 2; // Vertical position of catenary
  
  if (y <= catY)
  {
    velocity *= DF; // Reverse direction and dampening factor (coefficient of restitution)
    y = catY;
  }
  
  //
  // Draw bird.
  //
  // PImage img;
  // img = loadImage("Bird.png");
  // image(img, x + X_ORIGIN - X_OFFSET, y + Y_ORIGIN - Y_OFFSET); 
  ellipse(x + X_ORIGIN, y + Y_ORIGIN, DIAM, DIAM);
  
  //
  // Discontinue drawing when motion stops.
  //
  if (y == catY && abs(y - yPrev) <= Y_TOL)
    noLoop();
  
  yPrev = y; // Set lagging values
  tPrev = t;

  //
  // Draw catenary.
  //
  float catYPrev = Y_START;
  
  do
  {
    float x = catXPrev + X_STEP; // Advance to next horizontal value   
    float y = cat(x, SF); // Next vertical value
    
    //
    // Draw line segment.
    //
    line(catXPrev + X_ORIGIN, catYPrev + Y_ORIGIN, x + X_ORIGIN, y + Y_ORIGIN);

    //
    // Set newly created x and y to xprev/yprev so the next line
    // created starts where the last line created ends
    //
    catXPrev = x; // Lagging values for catenary x and y
    catYPrev = y;    
  } while (Y_START - catYPrev > Y_TOL); // Stop at opposite pole  
}
