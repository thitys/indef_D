import TUIO.*;
TuioProcessing tuioClient;

float GRAP_CANVAS_DISPLAY_SIZE = 77;
float TARGET_TO_CAMERA_DISTANCE = 200;
float SWING_WIDTH_X = 20;
float SWING_WIDTH_Y = 30;
float SWING_WIDTH_Z = 40;

PGraphics sketchPg;
PGraphics[] grapCanvases;
int[][] grapsMatrix = {
  {0, 1},
  {1, 0},
  {-1, 0},
  {0, -1}
};

float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
float x1, x2, y1, y2, z1, z2;
// float sphereX=0, sphereY=0, sphereZ=0;
PVector spherePos = new PVector(0 ,0, 0);
boolean isFirstDrawing = true;

boolean verbose = false;
boolean callback = true;

void setup()
{
  size(1000, 750, P3D);
  frameRate(60);
  sketchPg = createGraphics(1000, 750, P3D);

  noCursor();
  background(0);

  if (!callback) {
    frameRate(60);
    loop();
  } else noLoop();

  scale_factor = height/table_size;
  tuioClient  = new TuioProcessing(this);

  grapCanvases = new PGraphics[grapsMatrix.length];
  for(int i = 0; i < grapsMatrix.length; i++) {
    grapCanvases[i] = createGraphics(70, 70, P3D);
  }
}

void draw() {
  background(0);
  // x = cos(frameCount/50.0) * 20;
  // y = sin(frameCount/40.0) * 30;
  // z = cos(frameCount/60.0) * 40;
  spherePos.set(
    cos(frameCount/50.0) * SWING_WIDTH_X,
    sin(frameCount/40.0) * SWING_WIDTH_Y,
    cos(frameCount/60.0) * SWING_WIDTH_Z
  );

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
        isFirstDrawing = true;
      }
    }

    drawGraps();

    pushMatrix();
    translate(tobj.getScreenX(width)-50, tobj.getScreenY(height)-50);
    rotate(tobj.getAngle());
    for(int k = 0; k < grapCanvases.length; k++) {
      float x = grapsMatrix[k][0] * GRAP_CANVAS_DISPLAY_SIZE;
      float y = grapsMatrix[k][1] * GRAP_CANVAS_DISPLAY_SIZE;
      image(grapCanvases[k], x, y);
    }
    popMatrix();

    //println("x="+x);
    //println("y="+y);
    //println("z="+z);

    drawLine(tobj);
  }
}

void drawLine(TuioObject tobj) {
  float x = spherePos.x;
  float y = spherePos.y;
  float z = spherePos.z;
  sketchPg.beginDraw();
  //sketchPg.translate(0, 0);
  if (isFirstDrawing) {
    x2 = tobj.getScreenX(width);
    y2 = tobj.getScreenY(height);
    z2 = z;
    isFirstDrawing = false;
  }
  sketchPg.colorMode(HSB, 360, 100, 100);
  float h = map(x, -SWING_WIDTH_X, SWING_WIDTH_X, 0, 360);
  float s = map(y, -SWING_WIDTH_Y, SWING_WIDTH_Y, 0, 100);
  float b = 100;
  sketchPg.stroke(h, s, b);
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

void drawGraps() {
  for(int i = 0; i < grapCanvases.length; i++) {
    drawGrap(grapCanvases[i], i);
  }
}

void drawGrap(PGraphics g, int camType) {
  g.beginDraw();
  g.noStroke();
  g.lights();
  g.background(0);

  float camX = grapsMatrix[camType][0] * TARGET_TO_CAMERA_DISTANCE;
  float camZ = grapsMatrix[camType][1] * TARGET_TO_CAMERA_DISTANCE;
  g.camera(
    camX, 0, camZ,
    0, 0, 0,
    0, 1, 0
  );

  g.pushMatrix();
  //g.rotateX(x);
  g.translate(spherePos.x, spherePos.y, spherePos.z);
  g.sphere(50);
  g.popMatrix();
  g.endDraw();
}
