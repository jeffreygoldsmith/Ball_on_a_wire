//
// Bird on a wire : simulating a realistic version of a bird bouncing on a wire
// Russel Gordon 
// Jeffrey Goldsmith
// Grade 10 Computer Science
//

private static final int W = 600;                         // Width of canvas
private static final int H = 500;                         // Height of canvas
private static final int CAT_MIDDLE = 300;                // Middle of catenary
private static final float Y_MARGIN = 15f;                // Margin above and below flight path
private static final float VDF = -0.75f;                  // Dampening factor for velocity
private static final float X_STEP = 20f;                  // Line length to create catenary
private static final float X_ORIGIN = 300f;               // X value of first catenary pole
private static final float Y_ORIGIN = -100f;              // Y value of first catenary pole
private static final float Y_TOL = 0.01f;                 // Vertical tolerance to catenary
private static final float Y_STOP_TOL = 0.2f;             // Vertical elasticity tolerance to stop flight
private static final float GRAVITY = -9.8f;               // Gravity
private static final float TF = 3.5f / 1000f;             // Accelerates time
private static float SF = 320f;                           // Stretch factor for catenary
private static final float X_START = -200f;               // Length of catenary
private static final float Y_START = cat(X_START, SF);    // Vertical position for any point on the catenary
private static final float BIRD_OFFSET = 14f;             // Image y offset
private static final float BIRD_HEIGHT = 15.5f;           // Height for bird image
private static final float BIRD_WIDTH = 27f;              // Width for bird image
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
private static final int NUM_FRAMES = 10;                 // Number of frames in flapping animation

float r = random(Y_MIN, Y_MAX);                           // 0 in relation to sine wave
float freq = random(0.15, 0.20);                          // Frequency of sine wave
float tRandom = random(0, 0.5);                           // Random time value for sine wave
float x = 450f;                                           // X of bird
float y = H;                                              // Y of bird
float yPrev;                                              // Lagging value of y
float velocity = 0f;                                      // Velocity of bird
float t0 = 0f;                                            // Value to reset time
float tPrev = 0f;                                         // Lagging value of time
float c = min(r - Y_MIN, Y_MAX - r);                      // Takes the smaller of c and lowerC
float vp;                                                 // Potential velocity for the bird
float sf = SF;                                            // Adjustable stretch factor
boolean flg = false;                                      // Flag
PImage background;                                        // Image for background
PImage backgroundTop;                                     // Background for top of screen
PImage telephonePole;                                     // Image for telephone pole

//
// Preload images used.
//
/* @pjs preload = "BackgroundTop.jpg, Background.jpg, Telephonepole.jpg; */
/* @pjs preload = "Bird0.png, Bird1.png, Bird2.png, Bird3.png, Bird4.png5, Bird6.png, Bird7.png, Bird8.png, Bird9.png"; */

int currentFrame = 0;
PImage[] image = new PImage[NUM_FRAMES]; // Create array for flapping frames

//
// Function of catenary equation.
//
static float cat(float x, float sf)
{
  return sf / 2 * (exp(x / sf) + exp(-x / sf));
}

//
// Initialization logic.
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
  
  for (int i = 0; i < NUM_FRAMES; i++)
    image[i] = loadImage("Bird" + nf(i, 0) + ".png");
}

//
// Run loop.
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
  // Draw bouncing bird.
  //
  float t = millis() * TF; // Accelerated time, in seconds

  if (x > CAT_MIDDLE)
  {
    x = W - t * SPEED;
    yPrev = c * sin(TWO_PI * freq * (t / HDF + tRandom)) + r - BIRD_HEIGHT; // Compute y of sine wave

    flapBird(); // Draw bird flapping
  } 
  else
  {
    float deltaT = tPrev == 0f ? 0f : t - tPrev; // Difference between time and lagging time
    y = GRAVITY * 0.5 * deltaT * deltaT + velocity * deltaT + yPrev; // Compute height of projectile

    if (velocity > 0) // Draw bird flapping if velocity is positive
      flapBird();
    else
      image(image[0], x - BIRD_WIDTH, y - BIRD_OFFSET); // Otherwise, draw bird still

    velocity += -VDF * GRAVITY * deltaT; // Compute new velocity

    //
    // Create bounce.
    //
    float catY = Y_ORIGIN + cat(x - X_ORIGIN, sf) + BIRD_OFFSET / 2; // Vertical position of catenary

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
    if (y <= catY + Y_STOP_TOL && abs(y - yPrev) <= Y_TOL)
      noLoop();

    yPrev = y; // Set lagging values
    tPrev = t;
  }

  //
  // Draw catenary.
  //
  float catXPrev = X_START; // Catenary start coordinates
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
    // created starts where the last line created ends.
    //
    catXPrev = x; // Lagging values for catenary x and y
    catYPrev = y;
  } while (Y_START - catYPrev > Y_TOL); // Stop at opposite pole
}


//
// Draw bird in next flapping image.
//
private void flapBird()
{
  currentFrame = (currentFrame + 1) % NUM_FRAMES; // Compute next frame

  loop(); // Enable draw cycle

  image(image[currentFrame], x - BIRD_WIDTH, yPrev - BIRD_OFFSET);
}
