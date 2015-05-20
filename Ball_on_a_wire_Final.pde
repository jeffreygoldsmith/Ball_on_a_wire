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
private static final float BG_TOP_X = 0f;                 // Top backgrounx 
private static final float BG_TOP_Y = 375f;               // Top background y
private static final float BG_X = 0f;                     // Background x
private static final float BG_Y = -50f;                   // Background y
private static final float TP_ONE_X = -90f;               // Telephone pole 1 x
private static final float TP_ONE_Y = -50f;               // Telephone pole 1 y
private static final float TP_TWO_X = 480f;               // Telephone pole 2 x
private static final float TP_TWO_Y = -50f;               // Telephone pole 2 y


float r = random(Y_MIN, Y_MAX);                           // 0 in relation to sine wave
float freq = random(0.15, 0.20);                          // Frequency of sine wave
float tRandom = random(0, 0.5);                           // Random time value for sine wave
float x = 450f;                                           // X of ball
float y = H;                                              // Y of ball
float yPrev;                                              // Lagging value of y
float velocity = 0f;                                      // Velocity of ball
float gravity = -9.8f;                                    // Gravity
float t0 = 0f;                                            // Value to reset time
float tPrev = 0f;                                         // Lagging value of time
float c = min(r - Y_MIN, Y_MAX - r);                      // Takes the smaller of c and lowerC
float vp;                                                 // Potential velocity for the ball
float sf = SF;                                            // Adjustable stretch factor
boolean flg = false;                                      // Flag
PImage background;                                        // Image for background
PImage backgroundTop;                                     // Background for top of screen
PImage telephonePole;                                     // Image for telephone pole

/* @pjs preload="bird.png, bird1.png, bird2.png, bird3.png, bird4.png5, bird.png"; */

int numFrames = 10;  // The number of frames in the animation
int currentFrame = 0;
PImage[] image = new PImage[numFrames]; // Create array for flapping frames

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

  //
  // Load images.
  //
  backgroundTop = loadImage("BackgroundTop.jpg");
  background = loadImage("Background.jpg");
  telephonePole = loadImage("Telephonepole.png");
  image[0]  = loadImage("Bird.png");
  image[1]  = loadImage("Bird1.png"); 
  image[2]  = loadImage("Bird2.png"); 
  image[3]  = loadImage("Bird3.png");
  image[4]  = loadImage("Bird4.png");
  image[5]  = loadImage("Bird5.png");
  image[6]  = loadImage("Bird4.png");
  image[7]  = loadImage("Bird3.png");
  image[8]  = loadImage("Bird2.png");
  image[9]  = loadImage("Bird1.png");
}

//
// Run loop
//
void draw()
{
  translate(0, height); // Invert ordinate
  scale(1, -1);
  background(255); // Create background colour

  image(backgroundTop, BG_TOP_X, BG_TOP_Y); // Draw background
  image(background, BG_X, BG_Y); // Draw background
  image(telephonePole, TP_ONE_X, TP_ONE_Y); // Draw telephone pole 1
  image(telephonePole, TP_TWO_X, TP_TWO_Y); // Draw telephone pole 2

  //
  // Draw bouncing ball.
  //
  float t = millis() * TF; // Accelerated time, in seconds

  if (x > 300)
  {
    x = W - t * SPEED;
    yPrev = c * sin(TWO_PI * freq * (t / HDF + tRandom)) + r; // Compute y of sine wave

    //
    // Draw bird flapping.
    //
    currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames
    int offset = 0;
    loop(); 
    {
      image(image[(currentFrame+offset) % numFrames], x - X_OFFSET, yPrev - Y_OFFSET);
      offset+=1;
    }
  } 
  else
  {
    float deltaT = tPrev == 0f ? 0f : t - tPrev; // Difference between time and lagging time
    y = gravity * 0.5 * deltaT * deltaT + velocity * deltaT + yPrev; // Compute height of projectile

    //
    // Draw bird flapping if velocity is positive.
    //
    if (velocity > 0)
    {
      currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames
      int offset = 0;
      loop(); 
      {
        image(image[(currentFrame+offset) % numFrames], x - X_OFFSET, yPrev - Y_OFFSET);
        offset+=1;
      }
    }
    
    //
    // Draw bird still if velocity is negative.
    //
    if (velocity < 0)
    image(image[0], x - X_OFFSET, y - Y_OFFSET);

    velocity += -VDF * gravity * deltaT; // Compute new velocity

    //
    // Create bounce.
    //
    float catY = Y_ORIGIN + cat(x - X_ORIGIN, sf) + DIAM / 2; // Vertical position of catenary

    if (y <= catY)
    {
      if (flg)
      {
        vp = velocity; // Potential energy for return path
        flg = false;
      }
      sf -= velocity * 0.08; // Reduce stretch factor
      velocity *= 0.25; // Dampens velocity

      if (velocity >= -8f)
        velocity = vp * VDF; // Reverse direction and dampening factor (coefficient of restitution)
    } 
    else
    {
      flg = true;
      sf = SF;
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
    float y = cat(x, sf); // Next vertical value

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
