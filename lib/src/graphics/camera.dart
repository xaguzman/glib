part of glib.graphics;


abstract class Camera{
    /// the position of the camera
    final Vector3 position = new Vector3.zero();
    /// the unit length direction vector of the camera
    final Vector3 direction = new Vector3(0.0, 0.0, -1.0);
    /// the unit length up vector of the camera
    final Vector3 up = new Vector3(0.0, 1.0, 0.0);

    /// the projection matrix 
    final Matrix4 projection = new Matrix4.identity();
    
    /// the view matrix 
    final Matrix4 view = new Matrix4.identity();
    
    /// the combined projection and view matrix
    final Matrix4 combined = new Matrix4.identity();
    
    final Matrix4 _tmpM4 = new Matrix4.identity();
    final Vector3 _tmpV3 = new Vector3.zero();
    
    /// the inverse combined projection and view matrix
    final Matrix4 invProjectionView = new Matrix4.identity();

    /// the near clipping plane distance, has to be positive 
    double near = 1.0;
    /// the far clipping plane distance, has to be positive
    double far = 100.0;

    /// the viewport width
    double viewportWidth = 0.0;
    /// the viewport height
    double viewportHeight = 0.0;

    /// the frustum
    final Frustum frustum = new Frustum();

    final Vector3 _tmpVec = new Vector3.zero();
    final Ray _ray = new Ray.originDirection(new Vector3.zero(), new Vector3.zero());

    /** Recalculates the projection and view matrix of this camera and the [Frustum] planes if [updateFrustum] is
     * true. Use this after you've manipulated any of the attributes of the camera. */
    void update ([bool updateFrustum = true]);

    /** Recalculates the direction of the camera to look at the point (x, y, z). This function assumes the up vector is normalized.
     * [x] the x-coordinate of the point to look at
     * [y] the x-coordinate of the point to look at
     * [z] the x-coordinate of the point to look at */
    void lookAt(double x, double y, double z) {
      _tmpVec.setValues(x, y, z).sub(position).normalize();
      if (! isZero(_tmpVec) ) {
        double dot = _tmpVec.dot(up); // up and direction must ALWAYS be orthonormal vectors
        if ((dot - 1).abs() < 0.000000001) {
          // Collinear
          up.setFrom(direction).scale(-1.0);
        } else if ((dot + 1).abs() < 0.000000001) {
          // Collinear opposite
          up.setFrom(direction);
        }
        direction.setFrom(_tmpVec);
        normalizeUp();
      }
    }

    /** Recalculates the direction of the camera to look at the point (x, y, z).
     * @param target the point to look at */
    void lookAtVector(Vector3 target) {
      lookAt(target.x, target.y, target.z);
    }

    /** Normalizes the up vector by first calculating the right vector via a cross product between direction and up, and then
     * recalculating the up vector via a cross product between right and direction. */
    void normalizeUp () {
      _tmpVec.setFrom(direction).cross(up).normalize();
      up.setFrom(_tmpVec).cross(direction).normalize();
    }

//    /** Rotates the direction and up vector of this camera by the given angle around the given axis. The direction and up vector
//     * will not be orthogonalized.
//     * 
//     * [angle] the angle
//     * [axisX] the x-component of the axis
//     * [axisY] the y-component of the axis
//     * [axisZ] the z-component of the axis */
//    void rotateUnits(double angle, double axisX, double axisY, double axisZ) {
//      direction.rotateDeg(angle, axisX, axisY, axisZ);
//      up.rotateDeg(angle, axisX, axisY, axisZ);
//    }
//
//    /** Rotates the direction and up vector of this camera by the given angle around the given axis. The direction and up vector
//     * will not be orthogonalized.
//     * 
//     * [axis] the axis to rotate around
//     * [angle] the angle */
//    void rotateVector(Vector3 axis, double angle) {
//      
//      direction.rotateDegVector(axis, angle);
//      up.rotateDegVector(axis, angle);
//    }
//
//    /** Rotates the direction and up vector of this camera by the given rotation matrix. The direction and up vector will not be
//     * orthogonalized.
//     * 
//     * @param transform The rotation matrix */
//    void rotateMatrix(final Matrix4 transform) {
//      direction.rotateMatrix4(transform);
//      up.rotateMatrix4(transform);
//    }

    /** Rotates the direction and up vector of this camera by the given {@link Quaternion}. The direction and up vector will not be
     * orthogonalized.
     * 
     * @param quat The quaternion */
    void rotateQuat(final Quaternion quat) {
      quat.rotate(direction);
      quat.rotate(up);
    }

//    /** Rotates the direction and up vector of this camera by the given angle around the given axis, with the axis attached to given
//     * point. The direction and up vector will not be orthogonalized.
//     * 
//     * @param point the point to attach the axis to
//     * @param axis the axis to rotate around
//     * @param angle the angle */
//    void rotateAround (Vector3 point, Vector3 axis, double angle) {
//      _tmpVec.setFrom(point);
//      _tmpVec.sub(position);
//      translateVector(_tmpVec);
//      rotateVector(axis, angle);
//      _tmpVec.rotateDegVector(axis, angle);
//      translateUnits(-_tmpVec.x, -_tmpVec.y, -_tmpVec.z);
//    }

//    /** Transform the position, direction and up vector by the given matrix
//     * 
//     * @param transform The transform matrix */
//    void transform (final Matrix4 transform) {
//      position.mulMatrix4(transform);
//      rotateMatrix(transform);
//    }

    /** Moves the camera by the given amount on each axis.
     * @param x the displacement on the x-axis
     * @param y the displacement on the y-axis
     * @param z the displacement on the z-axis */
    void translateUnits(double x, double y, double z) {
      translateVector(_tmpVec.setValues(x, y, z));
    }

    /** Moves the camera by the given vector.
     * @param vec the displacement vector */
    void translateVector(Vector3 vec) {
      position.add(vec);
    }

    /** Function to translate a point given in screen coordinates to world space. It's the same as GLU gluUnProject, but does not
     * rely on OpenGL. The x- and y-coordinate of vec are assumed to be in screen coordinates (origin is the top left corner, y
     * pointing down, x pointing to the right) as reported by the touch methods in {@link Input}. A z-coordinate of 0 will return a
     * point on the near plane, a z-coordinate of 1 will return a point on the far plane. This method allows you to specify the
     * viewport position and dimensions in the coordinate system expected by {@link GL20#glViewport(int, int, int, int)}, with the
     * origin in the bottom left corner of the screen.
     * [screenCoords] the point in screen coordinates (origin top left)
     * [viewportX] the coordinate of the bottom left corner of the viewport in glViewport coordinates.
     * [viewportY] the coordinate of the bottom left corner of the viewport in glViewport coordinates.
     * [viewportWidth] the width of the viewport in pixels. If not specified, it will take the value of [_width]
     * [viewportHeight] the height of the viewport in pixels If not specified, it will take the value of [_height] */
    Vector3 unproject (Vector3 screenCoords, [double viewportX = 0.0, double viewportY = 0.0, double viewportWidth, double viewportHeight]) {
      if (viewportWidth == null)
        viewportWidth = _graphics.width.toDouble();
      
      if(viewportHeight == null)
        viewportHeight = _graphics.height.toDouble();
      
      double x = screenCoords.x, y = screenCoords.y;
      x = x - viewportX;
      y = viewportHeight - y - 1;
      y = y - viewportY;
      screenCoords.x = (2 * x) / viewportWidth - 1;
      screenCoords.y = (2 * y) / viewportHeight - 1;
      screenCoords.z = 2 * screenCoords.z - 1;
      screenCoords.applyProjection(invProjectionView);
      return screenCoords;
    }

    /** Projects the {@link Vector3} given in world space to screen coordinates. It's the same as GLU gluProject with one small
     * deviation: The viewport is assumed to span the whole screen. The screen coordinate system has its origin in the
     * <b>bottom</b> left, with the y-axis pointing <b>upwards</b> and the x-axis pointing to the right. This makes it easily
     * useable in conjunction with {@link Batch} and similar classes. This method allows you to specify the viewport position and
     * dimensions in the coordinate system expected by {@link GL20#glViewport(int, int, int, int)}, with the origin in the bottom
     * left corner of the screen.
     * [viewportX] the coordinate of the bottom left corner of the viewport in glViewport coordinates.
     * [viewportY] the coordinate of the bottom left corner of the viewport in glViewport coordinates.
     * [viewportWidth] the width of the viewport in pixels. If not specified, it will take the value of [_width]
     * [viewportHeight] the height of the viewport in pixels If not specified, it will take the value of [_height] */
    Vector3 project (Vector3 worldCoords, [double viewportX = 0.0, double viewportY = 0.0, double viewportWidth, double viewportHeight]) {
      worldCoords.applyProjection(combined);
      worldCoords.x = viewportWidth * (worldCoords.x + 1) / 2 + viewportX;
      worldCoords.y = viewportHeight * (worldCoords.y + 1) / 2 + viewportY;
      worldCoords.z = (worldCoords.z + 1) / 2;
      return worldCoords;
    }

    /** Creates a picking {@link Ray} from the coordinates given in screen coordinates. It is assumed that the viewport spans the
     * whole screen. The screen coordinates origin is assumed to be in the top left corner, its y-axis pointing down, the x-axis
     * pointing to the right. The returned instance is not a new instance but an internal member only accessible via this function.
     * [viewportX] the coordinate of the bottom left corner of the viewport in glViewport coordinates.
     * [viewportY] the coordinate of the bottom left corner of the viewport in glViewport coordinates.
     * [viewportWidth] the width of the viewport in pixels. If not specified, it will take the value of [_width]
     * [viewportHeight] the height of the viewport in pixels If not specified, it will take the value of [_height]
     * @return the picking Ray. */
    Ray getPickRay (double screenX, double screenY, [double viewportX = 0.0, double viewportY = 0.0, double viewportWidth,
      double viewportHeight]) {
      unproject(_ray.origin.setValues(screenX, screenY, 0.0), viewportX, viewportY, viewportWidth, viewportHeight);
      unproject(_ray.direction.setValues(screenX, screenY, 1.0), viewportX, viewportY, viewportWidth, viewportHeight);
      _ray.direction.sub(_ray.origin).normalize();
      return _ray;
    }
}

bool isZero(Vector3 v) => v.x * v.y * v.z == 0.0;