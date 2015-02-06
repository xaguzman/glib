part of glib.math;


class Ray{
  final Vector3 origin, direction;
  final Vector3 _tmp = new Vector3();
  
  Ray.originDirection(Vector3 origin , Vector3 direction)
    :origin = new Vector3(),
     direction = new Vector3()
  {
    this.origin.setVector(origin);
    this.direction.setVector(direction);
  }
  
  Ray copy() => new Ray.originDirection(origin, direction);
  
  /// Returns the endpoint given the distance. This is calculated as startpoint + distance * direction.
  Vector3 getEndPoint(Vector3 out, double distance) => 
      out.setVector(direction).scl(distance).addVector(origin);
  
  /// Multiplies the ray by the given matrix. Use this to transform a ray into another coordinate system.
  Ray multiply(Matrix4 matrix) {
    _tmp.set(origin).add(direction);
    _tmp.mulMatrix4(matrix);
    origin.mulMatrix4(matrix);
    direction.set(_tmp.sub(origin));
    return this;
  }
  
  Ray setValues(double x, double y, double z, double dx, double dy, double dz){
    origin.setValues(x, y, z);
    direction.setValues(dx, dy, dz);
    return this;
  }
  
  Ray setRay(Ray ray){
    origin.setVector(ray.origin);
    direction.setVector(ray.direction);
    return this;
  }
  
/// the negation of this Ray. It creates a ray from the same origin, in the opposite direction
  Ray operator -() => 
      copy()..direction.scl(-1) ;
  
  bool operator ==(Ray other) => other.origin == origin && other.direction == direction;
  
  @override
  String toString() => "ray: [ ${origin} : ${direction} ]";
}