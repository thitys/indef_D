import TUIO.*;
TuioProcessing tuioClient;

int GRAP_CANVAS_SIZE = 70;
int GRAP_CANVAS_DISPLAY_SIZE = GRAP_CANVAS_SIZE + 7;
float TARGET_TO_CAMERA_DISTANCE = 200;
float SWING_WIDTH_X = 20;
float SWING_WIDTH_Y = 30;
float SWING_WIDTH_Z = 40;

ArrayList<Ink> inks = new ArrayList<Ink>();
boolean is3d = false;
PGraphics canvas2d, canvas3d;
PGraphics[] grapCanvases;
int[][] grapsMatrix = {
  {0, 1},
  {1, 0},
  {-1, 0},
  {0, -1}
};

void setup()
{
  size(1000, 750, P3D);
  frameRate(60);
  noCursor();

  canvas3d = createGraphics(1000, 750, P3D);
  canvas2d = createGraphics(1000, 750, P2D);
  cursorSize = height / tableSize;
  tuioClient  = new TuioProcessing(this);

  grapCanvases = new PGraphics[grapsMatrix.length];
  for(int i = 0; i < grapsMatrix.length; i++)
    grapCanvases[i] = createGraphics(GRAP_CANVAS_SIZE, GRAP_CANVAS_SIZE, P3D);
}

void draw() {
  // *** 更新 ***
  PVector spherePos = new PVector(
    cos(radians(frameCount) * 1.0) * SWING_WIDTH_X,
    sin(radians(frameCount) * 1.2) * SWING_WIDTH_Y,
    cos(radians(frameCount) * 1.4) * SWING_WIDTH_Z
  );
  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  // マーカは1つのみを前提とする
  if(tuioObjectList.size() == 1) {
    TuioObject tobj = tuioObjectList.get(0);
    PVector markerPos = new PVector(tobj.getScreenX(width), tobj.getScreenY(height));
    if(!is3d) inks.add(new Ink(spherePos, markerPos));
    drawGraps(grapCanvases, spherePos);
  }
  draw3d();
  draw2d();

  // *** 描画 ***
  background(0);
  if (is3d) image(canvas3d, 0, 0);
  else image(canvas2d, 0, 0);

  if(tuioObjectList.size() == 1 && !is3d) {
    TuioObject tobj = tuioObjectList.get(0);
    pushMatrix();
    translate(tobj.getScreenX(width)-50, tobj.getScreenY(height)-50);
    rotate(tobj.getAngle());
    for(int k = 0; k < grapCanvases.length; k++) {
      float x = grapsMatrix[k][0] * GRAP_CANVAS_DISPLAY_SIZE;
      float y = grapsMatrix[k][1] * GRAP_CANVAS_DISPLAY_SIZE;
      image(grapCanvases[k], x, y);
    }
    popMatrix();
  }
}

void keyReleased() {
  if(key == 'c') clearSketch();
  if(key == 'd') is3d = !is3d;
}

void clearSketch() {
  inks.clear();
}

void draw2d() {
  canvas2d.beginDraw();
  canvas2d.background(0);

  for(int i = 1; i < inks.size(); i++) {
    Ink previewInk = inks.get(i - 1);
    Ink currentInk = inks.get(i);
    canvas2d.colorMode(HSB, 360, 100, 100);
    color penColor = currentInk.to2DColor();
    float penWeight = currentInk.to2DWeight();
    canvas2d.stroke(penColor);
    canvas2d.strokeWeight(penWeight);
    canvas2d.line(
      previewInk.to2DPosition().x, previewInk.to2DPosition().y,
      currentInk.to2DPosition().x, currentInk.to2DPosition().y
    );
  }
  canvas2d.endDraw();
}

void draw3d() {
  canvas3d.beginDraw();
  canvas3d.background(0);

  PVector transVec = new PVector(canvas3d.width / 2, canvas3d.height / 2, -canvas3d.height / 2);
  canvas3d.translate(transVec.x, transVec.y, transVec.z);
  canvas3d.rotateY(radians(frameCount));
  canvas3d.translate(-transVec.x, -transVec.y, -transVec.z);

  for(int i = 1; i < inks.size(); i++) {
    Ink previewInk = inks.get(i - 1);
    Ink currentInk = inks.get(i);
    canvas3d.colorMode(HSB, 360, 100, 100);
    color penColor = currentInk.to3DColor();
    canvas3d.stroke(penColor);
    canvas3d.line(
      previewInk.to3DPosition().x, previewInk.to3DPosition().y, previewInk.to3DPosition().z,
      currentInk.to3DPosition().x, currentInk.to3DPosition().y, currentInk.to3DPosition().z
    );
  }
  canvas3d.endDraw();
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
