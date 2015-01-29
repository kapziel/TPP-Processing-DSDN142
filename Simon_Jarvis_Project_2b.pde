/*
Processing Code created and manipulated by Simon Jarvis
 
 Reference Material from:
 3 layers of parallax floating Balls/Balloons
 by Birgit Bachler, 2013
 www.birgitbachler.com
 
 Ball class adapted from
 Learning Processing
 Daniel Shiffman
 http://www.learningprocessing.com
 Example 10-2: Bouncing ball class
 
 http://forum.processing.org/one/topic/falling-effect.html
 http://forum.processing.org/one/topic/making-text-fall-on-screen.html
 http://forum.processing.org/one/topic/falling-letters-how.html
 http://www.lynda.com/Processing-tutorials/Adding-sound/97578/113198-4.html
 http://code.compartmental.net/minim/noise_class_noise.html || author:Anderson Mills
 https://processing.org/examples/easing.html
 
 */


//import minim for sound!
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim soundCode;
AudioOutput out;

// used as instruments
NoiseInstrument myWhiteNoise, myPinkNoise, myRedNoise;
// used for the drawing
color noiseColor;
int xa;
int xDir;
int iFlip;

//follow the ayn chaser
float xe;
float ye;
float easing = 0.05;



//Getting prepped for $$ bills
PFont myfont;
int xpos = 0;
int ypos;
int xOffset = 40;
String word = "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$";
ArrayList<Letter> letters;



//setup different layers of AynBalls
int bground = 30;
int mdground = 40;
int fground = 25;


//array length, all layers together
int total = bground+mdground+fground;


//different sizes of the AynBalls
int bgsize = 50;
int mdsize = 80;
int frsize = 150;


//PImage for Ayn Rand's head
PImage randy;


//PImage for chasing Ayn Rand
PImage chaser;
PImage tpp;

//PImage for a lovely surprise
PShape surprise;
PShape dbg;

//AynBall Array
Ball[] balls;

float Xp = 1;
float Yp = height/2;





/// SETUP------------------



//setup, framerate, size, antialiasing ON
void setup() {
  size(1280, 720, P2D);
  frameRate(25);
  smooth();

  //font setup
  myfont = createFont("RussoOne-Regular-100.vlw", 100, true);
  textFont(myfont);


  //letter setup
  ypos = height;
  xpos = 0;
  letters = new ArrayList<Letter>();

  //surprise setup
  surprise = loadShape("demon.svg");

  //sound setup
  soundCode = new Minim(this);
  out = soundCode.getLineOut(Minim.MONO, 512);
  //define noise
  myWhiteNoise = new NoiseInstrument( 0.5, Noise.Tint.WHITE );
  myPinkNoise = new NoiseInstrument( 0.5, Noise.Tint.PINK );
  myRedNoise = new NoiseInstrument( 0.5, Noise.Tint.RED );
  noiseColor = color( 255, 255, 255 );


  //create the first letter, $
  letters.add(new Letter(word.charAt(0), xpos, ypos));


  //load the AynBall image into the sketch
  randy = loadImage("ball.png");

  //load the chase image and sort setup
  chaser = loadImage("chaser.png");
  tpp = loadImage("tpp.png");


  //filling the array of Ayn
  balls = new Ball[total];
  for (int i = 0; i < balls.length; i++) {
    if (i < bground) {
      balls[i] = new Ball(bgsize);
    } else if (i < mdground+bground) {
      balls[i] = new Ball (mdsize);
    } else if (i >= mdground) {
      balls[i] = new Ball(frsize);
    }
  }
}



/// DRAW------------------



void draw() {
  background(255);

  //move and display Ayn
  for (int i = 0; i < balls.length; i++) {
    balls[i].move();
    balls[i].display();
  }


  //time based -- falling letters (sequential)
  if (frameCount % 10 == 0) {
    fill(0);
    //falling letters
    int numLetters = letters.size();

    //Check to see if last letter has reached the end
    Letter last = letters.get(numLetters-1);
    if (last.maxY > last.y) {
      last.update();
    } else if (numLetters < word.length()) {
      letters.add(new Letter(word.charAt(numLetters), xpos+xOffset*numLetters, ypos));
    }

    //show all current letters
    for (int i = 0; i<numLetters; i++) {
      Letter current = letters.get(i);
      current.display();
    }
  }

  // chase graphic
  float targetX = mouseX;
  float dx = targetX -xe;
  if (abs(dx) > 1) {
    xe += dx * easing;
  }

  float targetY = mouseY;
  float dy = targetY - ye;
  if (abs(dy) > 1) {
    ye += dy * easing;
  }

  chaser.resize(200, 100);
  image(chaser, xe, ye);
  tpp.resize(200, 100);
  image(tpp, mouseX, mouseY);

  if (frameCount % 2 == 0) {
    background(000);
  } else if (keyPressed == true) {
    out.playNote(0, 1.5, myWhiteNoise);
    tpp = loadImage("tppburn.png");
    float bs = 1;
    shape(surprise, bs, bs);
    bs += 10;
  } else {
    tpp = loadImage("tpp.png");
  }
}


//------------- CLASSES ---------------



//Ball Class

class Ball {
  int size;
  float r;
  float x, y;
  float xspeed;
  float rota = 0.0001;

  Ball(float tempR) {
    r= tempR;
    x = random(width);
    y = random(height);
    xspeed = map(r, bgsize, frsize, 2, 8);
  }

  void move() {
    x += xspeed*mouseX/width;
    y += map(mouseY, 0, height, -5, 5);
    xspeed += 1;


    if (x > width+r || x < -r) {
      x= -r-random(width)/2;
      y = random(height);
    }
  }

  void display() {
    noStroke();
    pushMatrix();
    translate(x, y);
    smooth();
    image(randy, 0, 0, r, r);
    rotate(rota);

    if (frameCount % 10 == 0) {
      rota += rota;
    }
    popMatrix();
  }
}




//Letter class

class Letter {
  float speed = 200;
  float offset = height;

  char c;
  float x, y, maxY;

  Letter(char pC, float pX, float pY) {
    x = pX;
    y= pY-offset;
    c = pC;
    maxY = pY;
  }

  void update() {
    if (y+speed <= maxY) {
      y+=speed;
    } else {
      y= maxY;
    }
  }

  void display() {
    pushMatrix();
    text(c, x, y);
    popMatrix();
  }
}




//------ Noise class (minim)


// just plays a burst of noise of the specified tint and amplitude
class NoiseInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Noise myNoise;

  // constructors for the intsrument
  NoiseInstrument( float amplitude, Noise.Tint noiseTint )
  {
    // create new instances of any UGen objects as necessary
    // white noise is used for this instrument
    myNoise = new Noise( amplitude, noiseTint );
  }

  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    myNoise.patch( out );
  }

  // every instrument must have a noteOff() method
  void noteOff()
  {
    // unpatch the output 
    // this causes the entire instrument to stop calculating sampleframes
    // which is good when the instrument is no longer generating sound.
    myNoise.unpatch( out );
  }
}

