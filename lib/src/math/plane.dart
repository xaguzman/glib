part of glib.math;

/// A plane defined via a unit length normal and the distance from the origin, as you learned in your math class.
class Plane{
  
  final Vector3 normal = new Vector3();
  double d = 0.0;

  /// Constructs a new plane based on the normal and distance to the origin.
  Plane.withDistance(Vector3 normal, double d) {
    this.normal.set(normal).nor();
    this.d = d;
  }

  /// Constructs a new plane based on the normal and a point on the plane.
  Plane.point (Vector3 normal, Vector3 point) {
    this.normal.set(normal).nor();
    this.d = -this.normal.dot(point);
  }

  /// Constructs a new plane out of the three given points that are considered to be on the plane. The normal is calculated via a cross product between (point1-point2)x(point2-point3)
  Plane (Vector3 point1, Vector3 point2, Vector3 point3) {
    set(point1, point2, point3);
  }

  /// Sets the plane normal and distance to the origin based on the three given points which are considered to be on the plane.
  /// The normal is calculated via a cross product between (point1-point2)x(point2-point3)
  void set(Vector3 point1, Vector3 point2, Vector3 point3) {
    normal.set(point1).sub(point2).crsValues(point2.x-point3.x, point2.y-point3.y, point2.z-point3.z).nor();
    d = -point1.dot(normal);
  }

  /// Sets the plane normal and distance
  void setNormalValues(double nx, double ny, double nz, double d) {
    normal.set(nx, ny, nz);
    this.d = d;
  }

  /// Calculates the shortest signed distance between the plane and the given point.
  double distance (Vector3 point) {
    return normal.dot(point) + d;
  }

  /// Returns on which side the given point lies relative to the plane and its normal. PlaneSide.Front refers to the side the plane normal points to.
  PlaneSide testPoint (Vector3 point) {
    double dist = normal.dot(point) + d;

    if (dist == 0)
      return PlaneSide.OnPlane;
    else if (dist < 0)
      return PlaneSide.Back;
    else
      return PlaneSide.Front;
  }

  /// Returns on which side the given point lies relative to the plane and its normal. PlaneSide.Front refers to the side the plane normal points to.
  PlaneSide testPointValues(double x, double y, double z) {
    double dist = normal.dotValues(x, y, z) + d;

    if (dist == 0)
      return PlaneSide.OnPlane;
    else if (dist < 0)
      return PlaneSide.Back;
    else
      return PlaneSide.Front;
  }

  /// Returns whether the plane is facing the direction vector. Think of the direction vector as the direction a camera looks in.
  /// This method will return true if the front side of the plane determined by its normal faces the camera.
  bool isFrontFacing (Vector3 direction) {
    double dot = normal.dot(direction);
    return dot <= 0;
  }

  /// Sets the plane to the given point and normal.
  void setPoint(Vector3 point, Vector3 normal) {
    this.normal.set(normal);
    d = -point.dot(normal);
  }

  void setPointValues(double pointX, double pointY, double pointZ, double norX, double norY, double norZ) {
    this.normal.set(norX, norY, norZ);
    d = -(pointX * norX + pointY * norY + pointZ * norZ);
  }

  /// Sets this plane from the given plane
  void setPlane(Plane plane) {
    this.normal.set(plane.normal);
    this.d = plane.d;
  }

  String toString () => '${normal}, d' ;
}

/// Enum specifying on which side a point lies respective to the plane and it's normal. [PlaneSide.Front] is the side to which the normal points.
class PlaneSide{
  final num _val;
  
  const PlaneSide._(this._val);

  static const PlaneSide OnPlane = const PlaneSide._(1);
  static const PlaneSide Back = const PlaneSide._(2);
  static const PlaneSide Front = const PlaneSide._(3);
 
  bool operator ==(PlaneSide other) => other._val == _val;
}