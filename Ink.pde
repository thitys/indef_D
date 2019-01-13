
class Ink {
  PVector spherePos;
  PVector markerPos;

  Ink(PVector _spherePos, PVector _markerPos) {
    spherePos = _spherePos;
    markerPos = _markerPos;
  }

  color toColor() {
    pushStyle();
    colorMode(HSB, 360, 100, 100);
    float h = map(spherePos.x, -SWING_WIDTH_X, SWING_WIDTH_X, 0, 360);
    float s = map(spherePos.y, -SWING_WIDTH_Y, SWING_WIDTH_Y, 0, 100);
    float b = 100;
    color c = color(h, s, b);
    popStyle();
    return c;
  }

  color to3DColor() {
    return toColor();
  }

  PVector to3DPosition() {
    return new PVector(markerPos.x, markerPos.y, spherePos.z);
  }

  float to2DWeight() {
    return map(spherePos.z, -SWING_WIDTH_Z, SWING_WIDTH_Z, 1, 10);
  }

  color to2DColor() {
    return toColor();
  }

  PVector to2DPosition() {
    return new PVector(markerPos.x, markerPos.y);
  }
}
