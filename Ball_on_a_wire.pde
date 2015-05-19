private static final int W = 600;                         // Width of canvas
private static final int H = 500;                         // Height of canvas
private static final float Y_MARGIN = 15f;                // Margin above and below flight path
private static final float VDF = -0.75f;                  // Dampening factor for velocity
private static final float X_STEP = 20f;                  // Line length to create catenary
private static final float X_ORIGIN = 300f;               // X value of first catenary pole
private static final float Y_ORIGIN = -100f;              // Y value of first catenary pole
private static final float Y_TOL = 0.01f;                 // If the Y of catenary is within Y_TOL to Y_ORIGIN, stop drawing
private static final float TF = 3.5f / 1000f;             // Accelerates time
private static float SF = 320f;                           // Stretch factor for catenary
private static final float X_START = -200f;               // Length of catenary
private static final float Y_START = cat(X_START, SF);    // Vertical position for any point on the catenary
private static final float DIAM = 15f;                    // Diameter of ball
private static final float Y_OFFSET = 15f;                // Image y offset
private static final float X_OFFSET = 27f;                // Image x offset
private static final float Y_MIN = Y_START + Y_MARGIN;    // Lower boundary for sine wave
private static final float Y_MAX = H - Y_MARGIN;          // Upper boundary for sine wave
private static final float SPEED = 25f;                   // Speed of object
private static final float HDF = 2f;                      // Dampening factor for sinusoidal frequency


float r = random(Y_MIN, Y_MAX);                           // 0 in relation to sine wave
float freq = random(0.15, 0.20);                          // Frequency of sine wave
float tRandom = random(0, 0.5);                           // Random time value for sine wave
float x = 450f;                                           //!X of ball
float y = H;                                              // Y of ball
//!float yStart = 0f;                                        // Starting y value for drop
//!float yPrev = y;                                          // Lagging value of object
float yPrev;
float velocity = 0f;                                      // Velocity of ball
float gravity = -9.8f;                                    // Gravity
float t0 = 0f;                                            // Value to reset time
float tPrev = 0f;                                         // Lagging value of time
float c = min(r - Y_MIN, Y_MAX - r);                      // Takes the smaller of c and lowerC

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
  // Draw bouncing ball.
  //
  float t = millis() * TF; // Accelerated time, in seconds

  if (x > 300)
  {
    x = W - t * SPEED;
    yPrev = c * sin(TWO_PI * freq * (t / HDF + tRandom)) + r; // Compute y of sine wave

    ellipse(x, yPrev, DIAM, DIAM);
  }
  else
  {
    float deltaT = tPrev == 0f ? 0f : t - tPrev; // Difference between time and lagging time
    y = gravity * 0.5 * deltaT * deltaT + velocity * deltaT + yPrev; // Compute height of projectile

    ellipse(x, y, DIAM, DIAM);

    velocity += -VDF * gravity * deltaT; // Compute new velocity

    //
    // Create bounce.
    //
    float catY = Y_ORIGIN + cat(x - X_ORIGIN, SF) + DIAM / 2; // Vertical position of catenary

    if (y <= catY)
    {
      velocity *= VDF; // Reverse direction and dampening factor (coefficient of restitution)
      y = catY;
    }

    //
    // Discontinue drawing when motion stops.
    //
    if (y == catY && abs(y - yPrev) <= Y_TOL)
      noLoop();

    yPrev = y; // Set lagging values
    tPrev = t;
  }

  //
  // Draw catenary.
  //

  //
  // x and y values for the first point to construct a line
  //
  float catXPrev = X_START;
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
  } 
  while (Y_START - catYPrev > Y_TOL); // Stop at opposite pole
}
