part of glib.graphics;

class OrthographicCamera extends Camera{
  /** the zoom of the camera **/
  double zoom = 1.0;

  OrthographicCamera() {
    this.near = 0.0;
  }

  /** Constructs a new OrthographicCamera, using the given viewport width and height. For pixel perfect 2D rendering just supply
   * the screen size. The camera will show the region (-[viewportWidth] /2, -([viewportHeight]/2-1)) - ( ([viewportWidth]/2-1), [viewportHeight]/2)
   * [viewportWidth] the viewport width
   * [viewportHeight] the viewport height */
  OrthographicCamera.viewport(num viewportWidth, num viewportHeight) {
    this.viewportWidth = viewportWidth.toDouble();
    this.viewportHeight = viewportHeight.toDouble();
    this.near = 0.0;
    update();
  }

  final Vector3 _tmp = new Vector3();

  void update ([bool updateFrustum = true]) {
    
    projection.setToOrtho(zoom * -viewportWidth / 2, zoom * (viewportWidth / 2), zoom * -(viewportHeight / 2), zoom * viewportHeight / 2, near, far);
    view.setToLookAt(position, up, target: _tmp.set(position).add(direction));
    
    combined.setMatrix(projection).multiply(view);

    if (updateFrustum) {
      invProjectionView.setMatrix(combined);
      invProjectionView.invert();
      frustum.update(invProjectionView);
    }
  }

  /** Sets this camera to an orthographic projection, centered at ([viewportWidth]/2, [viewportHeight]/2), 
   * with the y-axis pointing up
   * or down.
   * [yDown] whether y should be pointing down.
   * [viewportWidth] the ammount pixels that the viewport should be made of on the x-axis
   * [viewportHeight] the ammount pixels that the viewport should be made of on the y-axis 
   */
  void setToOrtho ([bool yDown = false, double viewportWidth, double viewportHeight]) {
    if (viewportWidth == null)
      viewportWidth = _graphics.width.toDouble();
    if (viewportHeight == null)
      viewportHeight = _graphics.height.toDouble();
    
    if (yDown) {
      up.setValues(0.0, -1.0, 0.0);
      direction.setValues(0.0, 0.0, 1.0);
    } else {
      up.setValues(0.0, 1.0, 0.0);
      direction.setValues(0.0, 0.0, -1.0);
    }
    position.setValues(zoom * viewportWidth / 2.0, zoom * viewportHeight / 2.0, 0.0);
    this.viewportWidth = viewportWidth;
    this.viewportHeight = viewportHeight;
    update();
  }

  /// Rotates the camera by the given angle around the direction vector. The direction and up vector will not be orthogonalized.
  void rotate (double angle) {
//      super.rotateVector(direction, angle);
  }

  /// Moves the camera by the given vector, or units.
  void translate (x_OR_Vector2, [double y]) {
    if (x_OR_Vector2 is Vector2)
      super.translateUnits(x_OR_Vector2.x, x_OR_Vector2.y, 0.0);
    else
      super.translateUnits(x_OR_Vector2, y, 0.0);
  }
}