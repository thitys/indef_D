import TUIO.*;
TuioProcessing tuioClient;

int GRAP_CANVAS_SIZE = 70;
int GRAP_CANVAS_DISPLAY_SIZE = GRAP_CANVAS_SIZE + 7;
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

PVector pPenPos = new PVector(0, 0, 0);
PVector penPos = new PVector(0, 0, 0);
PVector spherePos = new PVector(0 ,0, 0);
boolean isFirstDrawing = true;

void setup()
{
  size(1000, 750, P3D);
  frameRate(60);
  noCursor();

  sketchPg = createGraphics(1000, 750, P3D);
  cursorSize = height / tableSize;
  tuioClient  = new TuioProcessing(this);

  grapCanvases = new PGraphics[grapsMatrix.length];
  for(int i = 0; i < grapsMatrix.length; i++)
    grapCanvases[i] = createGraphics(GRAP_CANVAS_SIZE, GRAP_CANVAS_SIZE, P3D);
}

void draw() {
  background(0);
  spherePos.set(
    cos(frameCount/50.0) * SWING_WIDTH_X,
    sin(frameCount/40.0) * SWING_WIDTH_Y,
    cos(frameCount/60.0) * SWING_WIDTH_Z
  );

  image(sketchPg, 0, 0);

  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  // マーカは1つのみを前提とする
  if(tuioObjectList.size() == 1) {
    TuioObject tobj = tuioObjectList.get(0);
    sketchPg.translate(1000/2, 750/2, 0);
    // TODO: 手動化する
    // if (mousePressed) {
    //   float rotationX = map(mouseY, 0, height, -PI, PI);
    //   float rotationY = map(mouseX, 0, width, -PI, PI);
    //   sketchPg.rotateX(rotationX);
    //   sketchPg.rotateY(rotationY);
    // }
    drawGraps(grapCanvases, spherePos);
    pushMatrix();
    translate(tobj.getScreenX(width)-50, tobj.getScreenY(height)-50);
    rotate(tobj.getAngle());
    for(int k = 0; k < grapCanvases.length; k++) {
      float x = grapsMatrix[k][0] * GRAP_CANVAS_DISPLAY_SIZE;
      float y = grapsMatrix[k][1] * GRAP_CANVAS_DISPLAY_SIZE;
      image(grapCanvases[k], x, y);
    }
    popMatrix();
    drawLine(tobj);
  }
}

void keyReleased() {
  if(key == 'c') clearSketch();
}

void clearSketch() {
  sketchPg = createGraphics(1000, 750, P3D);
  isFirstDrawing = true;
}

void drawLine(TuioObject tobj) {
  float x = spherePos.x;
  float y = spherePos.y;
  float z = spherePos.z;
  sketchPg.beginDraw();
  //sketchPg.translate(0, 0);
  if (isFirstDrawing) {
    pPenPos.x = tobj.getScreenX(width);
    pPenPos.y = tobj.getScreenY(height);
    pPenPos.z = z;
    isFirstDrawing = false;
  }
  sketchPg.colorMode(HSB, 360, 100, 100);
  float h = map(x, -SWING_WIDTH_X, SWING_WIDTH_X, 0, 360);
  float s = map(y, -SWING_WIDTH_Y, SWING_WIDTH_Y, 0, 100);
  float b = 100;
  float weight = map(z, -SWING_WIDTH_Z, SWING_WIDTH_Z, 1, 10);
  sketchPg.stroke(h, s, b);
  sketchPg.strokeWeight(weight);
  penPos.set(tobj.getScreenX(width), tobj.getScreenY(height), z);
  sketchPg.line(
    pPenPos.x, pPenPos.y, pPenPos.z * 2,
    penPos.x, penPos.y, penPos.z * 2
  );
  pPenPos.set(penPos);
  sketchPg.endDraw();
}

void drawGraps(PGraphics[] pgs, PVector pos) {
  if(pgs.length != 4) return;
  for(int i = 0; i < pgs.length; i++) {
    drawGrap(pgs[i], i, pos);
  }
}

void drawGrap(PGraphics g, int camType, PVector pos) {
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
  g.translate(pos.x, pos.y, pos.z);
  g.sphere(50);
  g.popMatrix();
  g.endDraw();
}
