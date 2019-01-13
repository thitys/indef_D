// import the TUIO library
import TUIO.*;
// declare a TuioProcessing client
TuioProcessing tuioClient;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
float x1, x2, y1, y2, z1, z2;
PGraphics g1, g2, g3, g4;
float x=0, y=0, z=0;
int j=0;
PGraphics sketchPg;

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks

void setup()
{
  size(1000, 750, P3D);
  frameRate(60);
  sketchPg = createGraphics(1000, 750, P3D);

  // GUI setup
  noCursor();
  background(0);

  // periodic updates
  if (!callback) {
    frameRate(60);
    loop();
  } else noLoop(); // or callback updates 

  scale_factor = height/table_size;
  tuioClient  = new TuioProcessing(this);

  g1 = createGraphics(70, 70, P3D);
  g2 = createGraphics(70, 70, P3D);
  g3 = createGraphics(70, 70, P3D);
  g4 = createGraphics(70, 70, P3D);
}

void draw() {
  background(0);
  x = cos(frameCount/50.0) * 20;
  y = sin(frameCount/40.0) * 30;
  z = cos(frameCount/60.0) * 40;

  image(sketchPg, 0, 0);

  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  for (int i=0; i<tuioObjectList.size(); i++) {
    TuioObject tobj = tuioObjectList.get(i);
    sketchPg.translate(1000/2, 750/2, 0);
    if (mousePressed==true) {
      float rotationX = map(mouseY, 0, height, -PI, PI);
      float rotationY = map(mouseX, 0, width, -PI, PI);
      sketchPg.rotateX(rotationX);
      sketchPg.rotateY(rotationY);
    }
    if (keyPressed) {
      if (key=='c') {
        background(0);
        j=0;
      }
    }

    drawGrap(g1, 1);
    drawGrap(g2, 2);
    drawGrap(g3, 3);
    drawGrap(g4, 4);
    pushMatrix();
    translate(tobj.getScreenX(width)-50, tobj.getScreenY(height)-50);
    rotate(tobj.getAngle());
    image(g1, 0, 77);
    image(g2, 77, 0);
    image(g3, -77, 0);
    image(g4, 0, -77);
    popMatrix();

    //println("x="+x);
    //println("y="+y);
    //println("z="+z);


    // drawLine--------------------------------------------------------------
    sketchPg.beginDraw();
    //sketchPg.translate(0, 0);
    if (j==0) {
      x2=tobj.getScreenX(width);
      y2=tobj.getScreenY(height);
      z2=z;
      j++;
    }
    sketchPg.colorMode(HSB);
    sketchPg.stroke(x*x/1.6, y*y/3.6, 255);
    println("x="+x*x/1.6);
    println("y="+y*y/3.6);
    println("z="+z*z/100);
    sketchPg.strokeWeight(z*z/100);

    x1=tobj.getScreenX(width);
    y1=tobj.getScreenY(height);
    z1=z;
    sketchPg.line(x2, y2, z2*2, x1, y1, z1*2);
    println("x1="+x1);
    println("x2="+x2);
    println("z1="+z1*2);
    println("z2="+z2*2);
    x2=x1;
    y2=y1;
    z2=z1;
    sketchPg.endDraw();
  }
}

// --------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs
// there are three callbacks for add/set/del events for each object/cursor/blob type
// the final refresh callback marks the end of each TUIO frame

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (verbose) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
    +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (verbose) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}
// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) {
  if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  if (callback) redraw();
}
void drawGrap(PGraphics g, int camType) {
  g.beginDraw();
  g.noStroke();
  g.lights();
  g.background(0);

  switch(camType) {
  case 1://front
    g.camera(0, 0, 200, 0, 0, 0, 0, 1, 0);
    break;
  case 2://right
    g.camera(200, 0, 0, 0, 0, 0, 0, 1, 0);
    break;
  case 3://left
    g.camera(-200, 0, 0, 0, 0, 0, 0, 1, 0);
    break;
  case 4://back
    g.camera(0, 0, -200, 0, 0, 0, 0, 1, 0);
    break;
  }

  g.pushMatrix();
  //g.rotateX(x);
  g.translate(x, y, z);
  g.sphere(50);
  g.popMatrix();
  g.endDraw();
}
