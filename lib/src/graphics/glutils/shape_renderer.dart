part of glib.graphics;

/** Renders points, lines, shape outlines and filled shapes.
 * <p>
 * By default a 2D orthographic projection with the origin in the lower left corner is used and units are specified in screen
 * pixels. This can be changed by configuring the projection matrix, usually using the {@link Camera#combined} matrix. If the
 * screen resolution changes, the projection matrix may need to be updated.
 * <p>
 * Shapes are rendered in batches to increase performance. Standard usage pattern looks as follows:
 * 
 * <pre>
 * {@code
 * camera.update();
 * shapeRenderer.setProjectionMatrix(camera.combined);
 * 
 * shapeRenderer.begin(ShapeType.Line);
 * shapeRenderer.setColor(1, 1, 0, 1);
 * shapeRenderer.line(x, y, x2, y2);
 * shapeRenderer.rect(x, y, width, height);
 * shapeRenderer.circle(x, y, radius);
 * shapeRenderer.end();
 * 
 * shapeRenderer.begin(ShapeType.Filled);
 * shapeRenderer.setColor(0, 1, 0, 1);
 * shapeRenderer.rect(x, y, width, height);
 * shapeRenderer.circle(x, y, radius);
 * shapeRenderer.end();
 * }
 * </pre>
 * 
 * ShapeRenderer has a second matrix called the transformation matrix which is used to rotate, scale and translate shapes in a
 * more flexible manner. The following example shows how to rotate a rectangle around its center using the z-axis as the rotation
 * axis and placing it's center at (20, 12, 2):
 * 
 * <pre>
 * shapeRenderer.begin(ShapeType.Line);
 * shapeRenderer.identity();
 * shapeRenderer.translate(20, 12, 2);
 * shapeRenderer.rotate(0, 0, 1, 90);
 * shapeRenderer.rect(-width / 2, -height / 2, width, height);
 * shapeRenderer.end();
 * </pre>
 * 
 * Matrix operations all use postmultiplication and work just like glTranslate, glScale and glRotate. The last transformation
 * specified will be the first that is applied to a shape (rotate then translate in the above example).
 * <p>
 * The projection and transformation matrices are a state of the ShapeRenderer, just like the color, and will be applied to all
 * shapes until they are changed.
 * @author mzechner
 * @author stbachmann
 * @author Nathan Sweet */
class ShapeRenderer implements Disposable {
  

  final ImmediateModeRenderer renderer;
  bool _matrixDirty = false;
  final Matrix4 _projectionMatrix = new Matrix4();
  final Matrix4 _transformMatrix = new Matrix4();
  final Matrix4 _combinedMatrix = new Matrix4();
  final Vector2 _tmp = new Vector2();
  final Color color = new Color(1, 1, 1, 1);
  ShapeType _shapeType;
  bool autoShapeType;
  double _defaultRectLineWidth = 0.75;

  ShapeRenderer ([int maxVertices = 5000]) {
    renderer = new WebGLImmediateModeRenderer(maxVertices, false, true, 0);
    _projectionMatrix.setToOrtho2D(0, 0, _graphics.width, _graphics.height);
    _matrixDirty = true;
  }

  /** Sets the color to be used by the next shapes drawn. */
  void setColor (Color color) {
    this.color.set(color);
  }

  /** Sets the color to be used by the next shapes drawn. */
  void setColorValues(double r, double g, double b, double a) {
    this.color.setDoubleChannels(r, g, b, a);
  }

  Color getColor () {
    return color;
  }

  void updateMatrices () {
    _matrixDirty = true;
  }

  /// If the matrix is modified, [updateMatrices] must be called.
  Matrix4 get projectionMatrix => _projectionMatrix;
  
  /// Sets the projection matrix to be used for rendering. Usually this will be set to [Camera.combined]
  void set _projectionMatrix (Matrix4 matrix) {
    _projectionMatrix.set(matrix);
    _matrixDirty = true;
  }

  /// If the matrix is modified, [updateMatrices] must be called. */
  Matrix4 get transformMatrix => _transformMatrix;
  void set transformMatrix (Matrix4 matrix) {
    _transformMatrix.setMatrix(matrix);
    _matrixDirty = true;
  }

  /// Sets the transformation matrix to identity
  void identity () {
    _transformMatrix.setIdentity();
    _matrixDirty = true;
  }

  /// Multiplies the current transformation matrix by a translation matrix
  void translate (double x, double y, double z) {
    _transformMatrix.translate(x, y, z);
    _matrixDirty = true;
  }

  /// Multiplies the current transformation matrix by a rotation matrix
  void rotate (double axisX, double axisY, double axisZ, double degrees) {
    _transformMatrix.rotate(axisX, axisY, axisZ, degrees);
    _matrixDirty = true;
  }

  /// Multiplies the current transformation matrix by a scale matrix
  void scale (double scaleX, double scaleY, double scaleZ) {
    _transformMatrix.scale(scaleX, scaleY, scaleZ);
    _matrixDirty = true;
  }

  /// If true, when drawing a shape cannot be performed with the current shape type, the batch is flushed and the shape type is
  /// changed automatically. This can increase the number of batch flushes if care is not taken to draw the same type of shapes
  /// together. Default is false. */
  void setAutoShapeType (bool autoShapeType) {
    this.autoShapeType = autoShapeType;
  }


  /// Starts a new batch of shapes. Shapes drawn within the batch will attempt to use the type specified, if no type is specified
  /// and [autoShapeType] = true, it will use [ShapeType.Line] 
  /// The call to this method must be paired with a call to [end]
  void begin ([ShapeType type]) {
    if ( type == null && !autoShapeType) 
      throw new ArgumentError("type can only be null if autoShapeType is set to true.");
    
    if (_shapeType != null) 
      throw new StateError("Call end() before beginning a new shape batch.");
    
    type = type == null ? ShapeType.Line : type;
    _shapeType = type;
    if (_matrixDirty) {
      _combinedMatrix.setMatrix(_projectionMatrix);
      _combinedMatrix.multiply(_transformMatrix);
      _matrixDirty = false;
    }
    renderer.begin(_combinedMatrix, _shapeType.glType);
  }

  void set (ShapeType type) {
    if (_shapeType == type) return;
    if (_shapeType == null) throw new StateError("begin must be called first.");
    if (!autoShapeType) throw new StateError("autoShapeType must be enabled.");
    end();
    begin(type);
  }

  /// Draws a point using [ShapeType.Point], [ShapeType.Line] or [ShapeType.Filled]
  void point (double x, double y, double z) {
    if (_shapeType == ShapeType.Line) {
      double size = defaultRectLineWidth * 0.5;
      line(x - size, y - size, z, x + size, y + size, z);
      return;
    } else if (_shapeType == ShapeType.Filled) {
      double size = _defaultRectLineWidth * 0.5;
      box(x - size, y - size, z - size, _defaultRectLineWidth, _defaultRectLineWidth, _defaultRectLineWidth);
      return;
    }
    _check(ShapeType.Point, null, 1);
    renderer.color(color);
    renderer.vertex(x, y, z);
  }


  /** Draws a line using {@link ShapeType#Line} or {@link ShapeType#Filled}. The line is drawn with two colors interpolated
   * between the start and end points. */
  void line (double x, double y, double z, double x2, double y2, double z2, Color c1, Color c2) {
    c1 = c1 == null ? color : c1;
    c2 = c2 == null ? color : c2;
    
    if (_shapeType == ShapeType.Filled) {
      rectLine(x, y, x2, y2, _defaultRectLineWidth);
      return;
    }
    _check(ShapeType.Line, null, 2);
    renderer.color(c1.r, c1.g, c1.b, c1.a);
    renderer.vertex(x, y, z);
    renderer.color(c2.r, c2.g, c2.b, c2.a);
    renderer.vertex(x2, y2, z2);
  }
  
  void lineV2(Vector2 v1, Vector2 v2, [Color color1, Color color2]){
    line(v1.x, v2.y, 0.0, v2.x, v2.y, 0.0, color1, color2);
  }
  
  void lineV3(Vector3 v1, Vector3 v2, [Color color1, Color color2]){
    line(v1.x, v2.y, v1.z, v2.x, v2.y, v2.z, color1, color2);
  }

  /** Draws a curve using {@link ShapeType#Line}. */
  void curve (double x1, double y1, double cx1, double cy1, double cx2, double cy2, double x2, double y2, int segments) {
    _check(ShapeType.Line, null, segments * 2 + 2);

    // Algorithm from: http://www.antigrain.com/research/bezier_interpolation/index.html#PAGE_BEZIER_INTERPOLATION
    double subdiv_step = 1.0 / segments;
    double subdiv_step2 = subdiv_step * subdiv_step;
    double subdiv_step3 = subdiv_step * subdiv_step * subdiv_step;

    double pre1 = 3 * subdiv_step;
    double pre2 = 3 * subdiv_step2;
    double pre4 = 6 * subdiv_step2;
    double pre5 = 6 * subdiv_step3;

    double tmp1x = x1 - cx1 * 2 + cx2;
    double tmp1y = y1 - cy1 * 2 + cy2;

    double tmp2x = (cx1 - cx2) * 3 - x1 + x2;
    double tmp2y = (cy1 - cy2) * 3 - y1 + y2;

    double fx = x1;
    double fy = y1;

    double dfx = (cx1 - x1) * pre1 + tmp1x * pre2 + tmp2x * subdiv_step3;
    double dfy = (cy1 - y1) * pre1 + tmp1y * pre2 + tmp2y * subdiv_step3;

    double ddfx = tmp1x * pre4 + tmp2x * pre5;
    double ddfy = tmp1y * pre4 + tmp2y * pre5;

    double dddfx = tmp2x * pre5;
    double dddfy = tmp2y * pre5;

    while (segments-- > 0) {
      renderer.color(color);
      renderer.vertex(fx, fy, 0);
      fx += dfx;
      fy += dfy;
      dfx += ddfx;
      dfy += ddfy;
      ddfx += dddfx;
      ddfy += dddfy;
      renderer.color(color);
      renderer.vertex(fx, fy, 0);
    }
    renderer.color(color);
    renderer.vertex(fx, fy, 0);
    renderer.color(color);
    renderer.vertex(x2, y2, 0);
  }

  /** Draws a triangle in x/y plane using {@link ShapeType#Line} or {@link ShapeType#Filled}. */
  void triangle (double x1, double y1, double x2, double y2, double x3, double y3) {
    _check(ShapeType.Line, ShapeType.Filled, 6);
    if (_shapeType == ShapeType.Line) {
      renderer.color(color);
      renderer.vertex(x1, y1, 0);
      renderer.color(color);
      renderer.vertex(x2, y2, 0);

      renderer.color(color);
      renderer.vertex(x2, y2, 0);
      renderer.color(color);
      renderer.vertex(x3, y3, 0);

      renderer.color(color);
      renderer.vertex(x3, y3, 0);
      renderer.color(color);
      renderer.vertex(x1, y1, 0);
    } else {
      renderer.color(color);
      renderer.vertex(x1, y1, 0);
      renderer.color(color);
      renderer.vertex(x2, y2, 0);
      renderer.color(color);
      renderer.vertex(x3, y3, 0);
    }
  }

  /** Draws a triangle in x/y plane with colored corners using {@link ShapeType#Line} or {@link ShapeType#Filled}. */
  void triangle (double x1, double y1, double x2, double y2, double x3, double y3, Color col1, Color col2, Color col3) {
    check(ShapeType.Line, ShapeType.Filled, 6);
    if (shapeType == ShapeType.Line) {
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x1, y1, 0);
      renderer.color(col2.r, col2.g, col2.b, col2.a);
      renderer.vertex(x2, y2, 0);

      renderer.color(col2.r, col2.g, col2.b, col2.a);
      renderer.vertex(x2, y2, 0);
      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x3, y3, 0);

      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x3, y3, 0);
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x1, y1, 0);
    } else {
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x1, y1, 0);
      renderer.color(col2.r, col2.g, col2.b, col2.a);
      renderer.vertex(x2, y2, 0);
      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x3, y3, 0);
    }
  }

  /** Draws a rectangle in the x/y plane using {@link ShapeType#Line} or {@link ShapeType#Filled}. */
  void rect (double x, double y, double width, double height) {
    check(ShapeType.Line, ShapeType.Filled, 8);

    if (shapeType == ShapeType.Line) {
      renderer.color(color);
      renderer.vertex(x, y, 0);
      renderer.color(color);
      renderer.vertex(x + width, y, 0);

      renderer.color(color);
      renderer.vertex(x + width, y, 0);
      renderer.color(color);
      renderer.vertex(x + width, y + height, 0);

      renderer.color(color);
      renderer.vertex(x + width, y + height, 0);
      renderer.color(color);
      renderer.vertex(x, y + height, 0);

      renderer.color(color);
      renderer.vertex(x, y + height, 0);
      renderer.color(color);
      renderer.vertex(x, y, 0);
    } else {
      renderer.color(color);
      renderer.vertex(x, y, 0);
      renderer.color(color);
      renderer.vertex(x + width, y, 0);
      renderer.color(color);
      renderer.vertex(x + width, y + height, 0);

      renderer.color(color);
      renderer.vertex(x + width, y + height, 0);
      renderer.color(color);
      renderer.vertex(x, y + height, 0);
      renderer.color(color);
      renderer.vertex(x, y, 0);
    }
  }

  /** Draws a rectangle in the x/y plane using {@link ShapeType#Line} or {@link ShapeType#Filled}. The x and y specify the lower
   * left corner.
   * @param col1 The color at (x, y).
   * @param col2 The color at (x + width, y).
   * @param col3 The color at (x + width, y + height).
   * @param col4 The color at (x, y + height). */
  void rect (double x, double y, double width, double height, Color col1, Color col2, Color col3, Color col4) {
    check(ShapeType.Line, ShapeType.Filled, 8);

    if (shapeType == ShapeType.Line) {
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x, y, 0);
      renderer.color(col2.r, col2.g, col2.b, col2.a);
      renderer.vertex(x + width, y, 0);

      renderer.color(col2.r, col2.g, col2.b, col2.a);
      renderer.vertex(x + width, y, 0);
      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x + width, y + height, 0);

      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x + width, y + height, 0);
      renderer.color(col4.r, col4.g, col4.b, col4.a);
      renderer.vertex(x, y + height, 0);

      renderer.color(col4.r, col4.g, col4.b, col4.a);
      renderer.vertex(x, y + height, 0);
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x, y, 0);
    } else {
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x, y, 0);
      renderer.color(col2.r, col2.g, col2.b, col2.a);
      renderer.vertex(x + width, y, 0);
      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x + width, y + height, 0);

      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x + width, y + height, 0);
      renderer.color(col4.r, col4.g, col4.b, col4.a);
      renderer.vertex(x, y + height, 0);
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x, y, 0);
    }
  }

  /** Draws a rectangle in the x/y plane using {@link ShapeType#Line} or {@link ShapeType#Filled}. The x and y specify the lower
   * left corner. The originX and originY specify the point about which to rotate the rectangle. */
  void rect (double x, double y, double originX, double originY, double width, double height, double scaleX, double scaleY,
    double degrees) {
    rect(x, y, originX, originY, width, height, scaleX, scaleY, degrees, color, color, color, color);
  }

  /** Draws a rectangle in the x/y plane using {@link ShapeType#Line} or {@link ShapeType#Filled}. The x and y specify the lower
   * left corner. The originX and originY specify the point about which to rotate the rectangle.
   * @param col1 The color at (x, y)
   * @param col2 The color at (x + width, y)
   * @param col3 The color at (x + width, y + height)
   * @param col4 The color at (x, y + height) */
  void rect (double x, double y, double originX, double originY, double width, double height, double scaleX, double scaleY,
    double degrees, Color col1, Color col2, Color col3, Color col4) {
    check(ShapeType.Line, ShapeType.Filled, 8);

    double cos = MathUtils.cosDeg(degrees);
    double sin = MathUtils.sinDeg(degrees);
    double fx = -originX;
    double fy = -originY;
    double fx2 = width - originX;
    double fy2 = height - originY;

    if (scaleX != 1 || scaleY != 1) {
      fx *= scaleX;
      fy *= scaleY;
      fx2 *= scaleX;
      fy2 *= scaleY;
    }

    double worldOriginX = x + originX;
    double worldOriginY = y + originY;

    double x1 = cos * fx - sin * fy + worldOriginX;
    double y1 = sin * fx + cos * fy + worldOriginY;

    double x2 = cos * fx2 - sin * fy + worldOriginX;
    double y2 = sin * fx2 + cos * fy + worldOriginY;

    double x3 = cos * fx2 - sin * fy2 + worldOriginX;
    double y3 = sin * fx2 + cos * fy2 + worldOriginY;

    double x4 = x1 + (x3 - x2);
    double y4 = y3 - (y2 - y1);

    if (shapeType == ShapeType.Line) {
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x1, y1, 0);
      renderer.color(col2.r, col2.g, col2.b, col2.a);
      renderer.vertex(x2, y2, 0);

      renderer.color(col2.r, col2.g, col2.b, col2.a);
      renderer.vertex(x2, y2, 0);
      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x3, y3, 0);

      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x3, y3, 0);
      renderer.color(col4.r, col4.g, col4.b, col4.a);
      renderer.vertex(x4, y4, 0);

      renderer.color(col4.r, col4.g, col4.b, col4.a);
      renderer.vertex(x4, y4, 0);
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x1, y1, 0);
    } else {
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x1, y1, 0);
      renderer.color(col2.r, col2.g, col2.b, col2.a);
      renderer.vertex(x2, y2, 0);
      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x3, y3, 0);

      renderer.color(col3.r, col3.g, col3.b, col3.a);
      renderer.vertex(x3, y3, 0);
      renderer.color(col4.r, col4.g, col4.b, col4.a);
      renderer.vertex(x4, y4, 0);
      renderer.color(col1.r, col1.g, col1.b, col1.a);
      renderer.vertex(x1, y1, 0);
    }

  }

  /** Draws a line using a rotated rectangle, where with one edge is centered at x1, y1 and the opposite edge centered at x2, y2. */
  void rectLine (double x1, double y1, double x2, double y2, double width) {
    check(ShapeType.Line, ShapeType.Filled, 8);

    Vector2 t = _tmp.set(y2 - y1, x1 - x2).nor();
    width *= 0.5f;
    double tx = t.x * width;
    double ty = t.y * width;
    if (shapeType == ShapeType.Line) {
      renderer.color(color);
      renderer.vertex(x1 + tx, y1 + ty, 0);
      renderer.color(color);
      renderer.vertex(x1 - tx, y1 - ty, 0);

      renderer.color(color);
      renderer.vertex(x2 + tx, y2 + ty, 0);
      renderer.color(color);
      renderer.vertex(x2 - tx, y2 - ty, 0);

      renderer.color(color);
      renderer.vertex(x2 + tx, y2 + ty, 0);
      renderer.color(color);
      renderer.vertex(x1 + tx, y1 + ty, 0);

      renderer.color(color);
      renderer.vertex(x2 - tx, y2 - ty, 0);
      renderer.color(color);
      renderer.vertex(x1 - tx, y1 - ty, 0);
    } else {
      renderer.color(color);
      renderer.vertex(x1 + tx, y1 + ty, 0);
      renderer.color(color);
      renderer.vertex(x1 - tx, y1 - ty, 0);
      renderer.color(color);
      renderer.vertex(x2 + tx, y2 + ty, 0);

      renderer.color(color);
      renderer.vertex(x2 - tx, y2 - ty, 0);
      renderer.color(color);
      renderer.vertex(x2 + tx, y2 + ty, 0);
      renderer.color(color);
      renderer.vertex(x1 - tx, y1 - ty, 0);
    }
  }

  /** @see #rectLine(float, float, float, float, float) */
  void rectLine (Vector2 p1, Vector2 p2, double width) {
    rectLine(p1.x, p1.y, p2.x, p2.y, width);
  }

  /** Draws a cube using {@link ShapeType#Line} or {@link ShapeType#Filled}. The x, y and z specify the bottom, left, front corner
   * of the rectangle. */
  void box (double x, double y, double z, double width, double height, double depth) {
    depth = -depth;

    if (shapeType == ShapeType.Line) {
      check(ShapeType.Line, ShapeType.Filled, 24);

      renderer.color(color);
      renderer.vertex(x, y, z);
      renderer.color(color);
      renderer.vertex(x + width, y, z);

      renderer.color(color);
      renderer.vertex(x + width, y, z);
      renderer.color(color);
      renderer.vertex(x + width, y, z + depth);

      renderer.color(color);
      renderer.vertex(x + width, y, z + depth);
      renderer.color(color);
      renderer.vertex(x, y, z + depth);

      renderer.color(color);
      renderer.vertex(x, y, z + depth);
      renderer.color(color);
      renderer.vertex(x, y, z);

      renderer.color(color);
      renderer.vertex(x, y, z);
      renderer.color(color);
      renderer.vertex(x, y + height, z);

      renderer.color(color);
      renderer.vertex(x, y + height, z);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z);

      renderer.color(color);
      renderer.vertex(x + width, y + height, z);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z + depth);

      renderer.color(color);
      renderer.vertex(x + width, y + height, z + depth);
      renderer.color(color);
      renderer.vertex(x, y + height, z + depth);

      renderer.color(color);
      renderer.vertex(x, y + height, z + depth);
      renderer.color(color);
      renderer.vertex(x, y + height, z);

      renderer.color(color);
      renderer.vertex(x + width, y, z);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z);

      renderer.color(color);
      renderer.vertex(x + width, y, z + depth);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z + depth);

      renderer.color(color);
      renderer.vertex(x, y, z + depth);
      renderer.color(color);
      renderer.vertex(x, y + height, z + depth);
    } else {
      check(ShapeType.Line, ShapeType.Filled, 36);

      // Front
      renderer.color(color);
      renderer.vertex(x, y, z);
      renderer.color(color);
      renderer.vertex(x + width, y, z);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z);

      renderer.color(color);
      renderer.vertex(x, y, z);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z);
      renderer.color(color);
      renderer.vertex(x, y + height, z);

      // Back
      renderer.color(color);
      renderer.vertex(x + width, y, z + depth);
      renderer.color(color);
      renderer.vertex(x, y, z + depth);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z + depth);

      renderer.color(color);
      renderer.vertex(x, y + height, z + depth);
      renderer.color(color);
      renderer.vertex(x, y, z + depth);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z + depth);

      // Left
      renderer.color(color);
      renderer.vertex(x, y, z + depth);
      renderer.color(color);
      renderer.vertex(x, y, z);
      renderer.color(color);
      renderer.vertex(x, y + height, z);

      renderer.color(color);
      renderer.vertex(x, y, z + depth);
      renderer.color(color);
      renderer.vertex(x, y + height, z);
      renderer.color(color);
      renderer.vertex(x, y + height, z + depth);

      // Right
      renderer.color(color);
      renderer.vertex(x + width, y, z);
      renderer.color(color);
      renderer.vertex(x + width, y, z + depth);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z + depth);

      renderer.color(color);
      renderer.vertex(x + width, y, z);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z + depth);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z);

      // Top
      renderer.color(color);
      renderer.vertex(x, y + height, z);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z + depth);

      renderer.color(color);
      renderer.vertex(x, y + height, z);
      renderer.color(color);
      renderer.vertex(x + width, y + height, z + depth);
      renderer.color(color);
      renderer.vertex(x, y + height, z + depth);

      // Bottom
      renderer.color(color);
      renderer.vertex(x, y, z + depth);
      renderer.color(color);
      renderer.vertex(x + width, y, z + depth);
      renderer.color(color);
      renderer.vertex(x + width, y, z);

      renderer.color(color);
      renderer.vertex(x, y, z + depth);
      renderer.color(color);
      renderer.vertex(x + width, y, z);
      renderer.color(color);
      renderer.vertex(x, y, z);
    }

  }

  /** Draws two crossed lines using {@link ShapeType#Line} or {@link ShapeType#Filled}. */
  void x (double x, double y, double size) {
    line(x - size, y - size, x + size, y + size);
    line(x - size, y + size, x + size, y - size);
  }

  /** @see #x(float, float, float) */
  void x (Vector2 p, double size) {
    x(p.x, p.y, size);
  }

  /** Calls {@link #arc(float, float, float, float, float, int)} by estimating the number of segments needed for a smooth arc. */
  void arc (double x, double y, double radius, double start, double degrees) {
    arc(x, y, radius, start, degrees, Math.max(1, (int)(6 * (float)Math.cbrt(radius) * (degrees / 360.0f))));
  }

  /** Draws an arc using {@link ShapeType#Line} or {@link ShapeType#Filled}. */
  void arc (double x, double y, double radius, double start, double degrees, int segments) {
    if (segments <= 0) throw new IllegalArgumentException("segments must be > 0.");

    double theta = (2 * MathUtils.PI * (degrees / 360.0f)) / segments;
    double cos = MathUtils.cos(theta);
    double sin = MathUtils.sin(theta);
    double cx = radius * MathUtils.cos(start * MathUtils.degreesToRadians);
    double cy = radius * MathUtils.sin(start * MathUtils.degreesToRadians);

    if (shapeType == ShapeType.Line) {
      check(ShapeType.Line, ShapeType.Filled, segments * 2 + 2);

      renderer.color(color);
      renderer.vertex(x, y, 0);
      renderer.color(color);
      renderer.vertex(x + cx, y + cy, 0);
      for (int i = 0; i < segments; i++) {
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, 0);
        double temp = cx;
        cx = cos * cx - sin * cy;
        cy = sin * temp + cos * cy;
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, 0);
      }
      renderer.color(color);
      renderer.vertex(x + cx, y + cy, 0);
    } else {
      check(ShapeType.Line, ShapeType.Filled, segments * 3 + 3);

      for (int i = 0; i < segments; i++) {
        renderer.color(color);
        renderer.vertex(x, y, 0);
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, 0);
        double temp = cx;
        cx = cos * cx - sin * cy;
        cy = sin * temp + cos * cy;
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, 0);
      }
      renderer.color(color);
      renderer.vertex(x, y, 0);
      renderer.color(color);
      renderer.vertex(x + cx, y + cy, 0);
    }

    double temp = cx;
    cx = 0;
    cy = 0;
    renderer.color(color);
    renderer.vertex(x + cx, y + cy, 0);
  }

  /** Calls {@link #circle(float, float, float, int)} by estimating the number of segments needed for a smooth circle. */
  void circle (double x, double y, double radius) {
    circle(x, y, radius, Math.max(1, (int)(6 * (float)Math.cbrt(radius))));
  }

  /** Draws a circle using {@link ShapeType#Line} or {@link ShapeType#Filled}. */
  void circle (double x, double y, double radius, int segments) {
    if (segments <= 0) throw new IllegalArgumentException("segments must be > 0.");

    double angle = 2 * MathUtils.PI / segments;
    double cos = MathUtils.cos(angle);
    double sin = MathUtils.sin(angle);
    double cx = radius, cy = 0;
    if (shapeType == ShapeType.Line) {
      check(ShapeType.Line, ShapeType.Filled, segments * 2 + 2);
      for (int i = 0; i < segments; i++) {
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, 0);
        double temp = cx;
        cx = cos * cx - sin * cy;
        cy = sin * temp + cos * cy;
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, 0);
      }
      // Ensure the last segment is identical to the first.
      renderer.color(color);
      renderer.vertex(x + cx, y + cy, 0);
    } else {
      check(ShapeType.Line, ShapeType.Filled, segments * 3 + 3);
      segments--;
      for (int i = 0; i < segments; i++) {
        renderer.color(color);
        renderer.vertex(x, y, 0);
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, 0);
        double temp = cx;
        cx = cos * cx - sin * cy;
        cy = sin * temp + cos * cy;
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, 0);
      }
      // Ensure the last segment is identical to the first.
      renderer.color(color);
      renderer.vertex(x, y, 0);
      renderer.color(color);
      renderer.vertex(x + cx, y + cy, 0);
    }

    double temp = cx;
    cx = radius;
    cy = 0;
    renderer.color(color);
    renderer.vertex(x + cx, y + cy, 0);
  }

  /** Calls {@link #ellipse(float, float, float, float, int)} by estimating the number of segments needed for a smooth ellipse. */
  void ellipse (double x, double y, double width, double height) {
    ellipse(x, y, width, height, Math.max(1, (int)(12 * (float)Math.cbrt(Math.max(width * 0.5f, height * 0.5f)))));
  }

  /** Draws an ellipse using {@link ShapeType#Line} or {@link ShapeType#Filled}. */
  void ellipse (double x, double y, double width, double height, int segments) {
    if (segments <= 0) throw new IllegalArgumentException("segments must be > 0.");
    check(ShapeType.Line, ShapeType.Filled, segments * 3);

    double angle = 2 * MathUtils.PI / segments;

    double cx = x + width / 2, cy = y + height / 2;
    if (shapeType == ShapeType.Line) {
      for (int i = 0; i < segments; i++) {
        renderer.color(color);
        renderer.vertex(cx + (width * 0.5f * MathUtils.cos(i * angle)), cy + (height * 0.5f * MathUtils.sin(i * angle)), 0);

        renderer.color(color);
        renderer.vertex(cx + (width * 0.5f * MathUtils.cos((i + 1) * angle)),
          cy + (height * 0.5f * MathUtils.sin((i + 1) * angle)), 0);
      }
    } else {
      for (int i = 0; i < segments; i++) {
        renderer.color(color);
        renderer.vertex(cx + (width * 0.5f * MathUtils.cos(i * angle)), cy + (height * 0.5f * MathUtils.sin(i * angle)), 0);

        renderer.color(color);
        renderer.vertex(cx, cy, 0);

        renderer.color(color);
        renderer.vertex(cx + (width * 0.5f * MathUtils.cos((i + 1) * angle)),
          cy + (height * 0.5f * MathUtils.sin((i + 1) * angle)), 0);
      }
    }
  }

  /** Calls {@link #cone(float, float, float, float, float, int)} by estimating the number of segments needed for a smooth
   * circular base. */
  void cone (double x, double y, double z, double radius, double height) {
    cone(x, y, z, radius, height, Math.max(1, (int)(4 * (float)Math.sqrt(radius))));
  }

  /** Draws a cone using {@link ShapeType#Line} or {@link ShapeType#Filled}. */
  void cone (double x, double y, double z, double radius, double height, int segments) {
    if (segments <= 0) throw new IllegalArgumentException("segments must be > 0.");
    check(ShapeType.Line, ShapeType.Filled, segments * 4 + 2);

    double angle = 2 * MathUtils.PI / segments;
    double cos = MathUtils.cos(angle);
    double sin = MathUtils.sin(angle);
    double cx = radius, cy = 0;
    if (shapeType == ShapeType.Line) {
      for (int i = 0; i < segments; i++) {
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, z);
        renderer.color(color);
        renderer.vertex(x, y, z + height);
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, z);
        double temp = cx;
        cx = cos * cx - sin * cy;
        cy = sin * temp + cos * cy;
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, z);
      }
      // Ensure the last segment is identical to the first.
      renderer.color(color);
      renderer.vertex(x + cx, y + cy, z);
    } else {
      segments--;
      for (int i = 0; i < segments; i++) {
        renderer.color(color);
        renderer.vertex(x, y, z);
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, z);
        double temp = cx;
        double temp2 = cy;
        cx = cos * cx - sin * cy;
        cy = sin * temp + cos * cy;
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, z);

        renderer.color(color);
        renderer.vertex(x + temp, y + temp2, z);
        renderer.color(color);
        renderer.vertex(x + cx, y + cy, z);
        renderer.color(color);
        renderer.vertex(x, y, z + height);
      }
      // Ensure the last segment is identical to the first.
      renderer.color(color);
      renderer.vertex(x, y, z);
      renderer.color(color);
      renderer.vertex(x + cx, y + cy, z);
    }
    double temp = cx;
    double temp2 = cy;
    cx = radius;
    cy = 0;
    renderer.color(color);
    renderer.vertex(x + cx, y + cy, z);
    if (shapeType != ShapeType.Line) {
      renderer.color(color);
      renderer.vertex(x + temp, y + temp2, z);
      renderer.color(color);
      renderer.vertex(x + cx, y + cy, z);
      renderer.color(color);
      renderer.vertex(x, y, z + height);
    }
  }

  /** Draws a polygon in the x/y plane using {@link ShapeType#Line}. The vertices must contain at least 3 points (6 floats x,y). */
  void polygon (float[] vertices, int offset, int count) {
    if (count < 6) throw new IllegalArgumentException("Polygons must contain at least 3 points.");
    if (count % 2 != 0) throw new IllegalArgumentException("Polygons must have an even number of vertices.");

    check(ShapeType.Line, null, count);

    double firstX = vertices[0];
    double firstY = vertices[1];

    for (int i = offset, n = offset + count; i < n; i += 2) {
      double x1 = vertices[i];
      double y1 = vertices[i + 1];

      double x2;
      double y2;

      if (i + 2 >= count) {
        x2 = firstX;
        y2 = firstY;
      } else {
        x2 = vertices[i + 2];
        y2 = vertices[i + 3];
      }

      renderer.color(color);
      renderer.vertex(x1, y1, 0);
      renderer.color(color);
      renderer.vertex(x2, y2, 0);
    }
  }

  /** @see #polygon(float[], int, int) */
  void polygon (float[] vertices) {
    polygon(vertices, 0, vertices.length);
  }

  /** Draws a polyline in the x/y plane using {@link ShapeType#Line}. The vertices must contain at least 2 points (4 floats x,y). */
  void polyline (Float32List vertices, [int offset = 0, int count]) {
    
    if (count == null)
      count = vertices.length;
    
    if (count < 4) 
      throw new IllegalArgumentError("Polylines must contain at least 2 points.");
    if (count % 2 != 0) 
      throw new IllegalArgumentError("Polylines must have an even number of vertices.");

    _check(ShapeType.Line, null, count);

    for (int i = offset, n = offset + count - 2; i < n; i += 2) {
      double x1 = vertices[i];
      double y1 = vertices[i + 1];

      double x2;
      double y2;

      x2 = vertices[i + 2];
      y2 = vertices[i + 3];

      _renderer.color(color);
      _renderer.vertex(x1, y1, 0);
      _renderer.color(color);
      _renderer.vertex(x2, y2, 0);
    }
  }

  /** @param other May be null. */
  void _check (ShapeType preferred, ShapeType other, int newVertices) {
    if (shapeType == null) throw new IllegalStateException("begin must be called first.");

    if (shapeType != preferred && shapeType != other) {
      // Shape type is not valid.
      if (!autoShapeType) {
        if (other == null)
          throw new IllegalStateException("Must call begin(ShapeType." + preferred + ").");
        else
          throw new IllegalStateException("Must call begin(ShapeType." + preferred + ") or begin(ShapeType." + other + ").");
      }
      end();
      begin(preferred);
    } else if (matrixDirty) {
      // Matrix has been changed.
      ShapeType type = shapeType;
      end();
      begin(type);
    } else if (renderer.getMaxVertices() - renderer.getNumVertices() < newVertices) {
      // Not enough space.
      ShapeType type = shapeType;
      end();
      begin(type);
    }
  }

  /** Finishes the batch of shapes and ensures they get rendered. */
  void end () {
    renderer.end();
    shapeType = null;
  }

  void flush () {
    ShapeType type = shapeType;
    end();
    begin(type);
  }

  /** Returns the current shape type. */
  ShapeType getCurrentType () {
    return shapeType;
  }

  ImmediateModeRenderer getRenderer () {
    return renderer;
  }

  /** @return true if currently between begin and end. */
  bool isDrawing () {
    return _shapeType != null;
  }

  void dispose () {
    _renderer.dispose();
  }
}


/** Shape types to be used with {@link #begin(ShapeType)}.
   * @author mzechner, stbachmann */
class ShapeType {
  static const Point = const ShapeType._(GL.POINTS); 
  static const Line = const ShapeType._(GL.LINES);
  static const Filled = const ShapeType._(GL.TRIANGLES);

  final int glType;

  const ShapeType._(this.glType);
}
