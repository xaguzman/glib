part of glib.graphics;

 /// Manages a [Camera] and determines how world coordinates are mapped to and from the screen.
abstract class Viewport {
  Camera camera;
  double worldWidth, worldHeight;
  int screenX, screenY, screenWidth, screenHeight;

  final Vector3 _tmp = new Vector3();

  /// Applies the viewport to the camera and sets the glViewport.
  /// [centerCamera] If true, the camera position is set to the center of the world
  void apply (bool centerCamera) {
    
    _graphics.gl.viewport(screenX, screenY, screenWidth, screenHeight);
    camera.viewportWidth = worldWidth;
    camera.viewportHeight = worldHeight;
    if (centerCamera)
      camera.position.setValues(worldWidth / 2, worldHeight / 2, 0.0);
    camera.update();
  }

  /// Configures this viewport's screen bounds using the specified screen size and calls [apply](centerCamera)
  void update (int screenWidth, int screenHeight, [bool centerCamera = false]) {
    apply(centerCamera);
  }

  /// Transforms the specified screen coordinate to world coordinates.
  /// returns The vector that was passed in, transformed to world coordinates.
  Vector2 unproject2 (Vector2 screenCoords) {
    _tmp.setValues(screenCoords.x, screenCoords.y, 1.0);
    camera.unproject(_tmp, screenX.toDouble(), screenY.toDouble(), screenWidth.toDouble(), screenHeight.toDouble());
    screenCoords.setValues(_tmp.x, _tmp.y);
    return screenCoords;
  }

  /// Transforms the specified world coordinate to screen coordinates.
  /// returns the vector that was passed in, transformed to screen coordinates.
  Vector2 project2 (Vector2 worldCoords) {
    _tmp.setValues(worldCoords.x, worldCoords.y, 1.0);
    camera.project(_tmp, screenX.toDouble(), screenY.toDouble(), screenWidth.toDouble(), screenHeight.toDouble());
    worldCoords.setValues(_tmp.x, _tmp.y);
    return worldCoords;
  }

  /// Transforms the specified screen coordinate to world coordinates.
  /// returns The vector that was passed in, transformed to world coordinates.
  Vector3 unproject3 (Vector3 screenCoords) {
    camera.unproject(screenCoords, screenX.toDouble(), screenY.toDouble(), screenWidth.toDouble(), screenHeight.toDouble());
    return screenCoords;
  }

  /// Transforms the specified world coordinate to screen coordinates.
  /// return The vector that was passed in, transformed to screen coordinates.
  Vector3 project3 (Vector3 worldCoords) {
    camera.project(worldCoords, screenX.toDouble(), screenY.toDouble(), screenWidth.toDouble(), screenHeight.toDouble());
    return worldCoords;
  }

  Ray getPickRay (double screenX, double screenY) {
    return camera.getPickRay(screenX, screenY, this.screenX.toDouble(), this.screenY.toDouble(), screenWidth.toDouble(), screenHeight.toDouble());
  }

//  /** @see ScissorStack#calculateScissors(Camera, float, float, float, float, Matrix4, Rectangle, Rectangle) */
//  void calculateScissors (Matrix4 batchTransform, Rectangle area, Rectangle scissor) {
//    ScissorStack.calculateScissors(_camera, _screenX, _screenY, _screenWidth, _screenHeight, batchTransform, area, scissor);
//  }

  /// Transforms a point to real screen coordinates (as opposed to OpenGL ES window coordinates), where the origin is in the top
  /// left and the the y-axis is pointing downwards.
  Vector2 toScreenCoordinates (Vector2 worldCoords, Matrix4 transformMatrix) {
    _tmp.setValues(worldCoords.x, worldCoords.y, 0.0);
//    _tmp.multiply(transformMatrix);
    _tmp.project(transformMatrix);
//    _tmp.applyProjection(transformMatrix);
    camera.project(_tmp);
    _tmp.y = _graphics.height - _tmp.y;
    worldCoords.x = _tmp.x;
    worldCoords.y = _tmp.y;
    return worldCoords;
  }

  /// Sets the viewport's position in screen coordinates. This is typically set by [update]
  void setScreenPosition (int screenX, int screenY) {
    this.screenX = screenX;
    this.screenY = screenY;
  }

  /// Sets the viewport's size in screen coordinates. This is typically set by [update]
  void setScreenSize (int screenWidth, int screenHeight) {
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
  }

  /// Sets the viewport's bounds in screen coordinates. This is typically set by [update]
  void setScreenBounds (int screenX, int screenY, int screenWidth, int screenHeight) {
    this.screenX = screenX;
    this.screenY = screenY;
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
  }

  /// Returns the left gutter (black bar) width in screen coordinates.
  int get leftGutterWidth => screenX;

  /// Returns the right gutter (black bar) x in screen coordinates.
  int get rightGutterX => screenX + screenWidth;

  /// Returns the right gutter (black bar) width in screen coordinates. 
  int get rightGutterWidth => _graphics.width - (screenX + screenWidth);

  /// Returns the bottom gutter (black bar) height in screen coordinates. 
  int get bottomGutterHeight => screenY;

  /// Returns the top gutter (black bar) y in screen coordinates. 
  int get topGutterY => screenY + screenHeight;

  /// Returns the top gutter (black bar) height in screen coordinates.
  int get topGutterHeight => _graphics.height - (screenY + screenHeight);
}