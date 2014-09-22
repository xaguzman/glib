part of glib.math;


class Vec3{
  double x, y, z;

  static final Vec3 X = new Vec3(1.0, 0.0, 0.0);
  static final Vec3 Y = new Vec3(0.0, 1.0, 0.0);
  static final Vec3 Z = new Vec3(0.0, 0.0, 1.0);
  static final Vec3 Zero = new Vec3(0.0, 0.0, 0.0);
  
  static final Matrix4 tmpMat = new Matrix4();


  Vec3([this.x = 0.0, this.y = 0.0, this.z = 0.0]);

  Vec3.from(final Vec3 vector): this(vector.x, vector.y, vector.z) ;
  
  Vec3.fromVector2(Vec2 vector, [double z = 0.0]): this(vector.x, vector.y, z);
  
  Vec3 copy() => new Vec3.from(this);
  bool get isZero => this == Vec3.Zero;
  Vec3 setZero () => set(Vec3.Zero);
  
  /// the negation of this vector
  Vec3 operator -() => copy().scl(-1);
  Vec3 operator -(v) => copy().sub(v);
  Vec3 operator +(v) => copy().add(v);
  Vec3 operator *(v) => copy().scl(v);
  bool operator ==(Vec3 other) => other.x == x && other.y == y;
  
  /// The euclidian length 
  num length() => sqrt(x * x + y * y + z * z);
  
  /** This method is faster than Vector.len() because it avoids calculating a square root. 
   * It is useful for comparisons, but not for getting accurate lengths, as the return 
   * value is the square of the actual length.
   */
  num length2() => x * x + y * y + z * z;
  
  Vec3 set (x_OR_vec3, [double y, double z]) {
    if(x_OR_vec3 is Vec3)
      return setValues(x_OR_vec3.x, x_OR_vec3.y, x_OR_vec3.z);
    else if(x_OR_vec3 is num){
     z = z != null ? z : x_OR_vec3; 
     y = y != null ? y : x_OR_vec3;
     return setValues(x_OR_vec3, y, z);
    }
    return this;
  }
  
  Vec3 setVector(Vec3 other) => setValues(other.x, other.y, other.z);
  
  Vec3 setValues(double x, double y, double z){
    this.x = x;
    this.y = y;
    this.z = z;
    return this;
  }
  
  Vec3 add (x_OR_vec3, [num y, num z]) {
    if( x_OR_vec3 is Vec3){
      addValues(x_OR_vec3.x, x_OR_vec3.y, x_OR_vec3.z);
    }else if(x_OR_vec3 is num){
      this.x += x_OR_vec3;
      this.y += y == null ? x_OR_vec3 : y;
      this.z += z == null ? x_OR_vec3 : z;
    }
    return this;
  }
  
  Vec3 addVector(Vec3 other) => addValues(other.x, other.y, other.z);
  
  Vec3 addValues(num x, num y, num z){
    this.x += x;
    this.y += y;
    this.z += z;
    return this;
  }
  
  Vec3 sub (x_OR_vec3, [num y, num z]) {
    if( x_OR_vec3 is Vec3){
      subValues(x_OR_vec3.x, x_OR_vec3.y, x_OR_vec3.z);
    }else if(x_OR_vec3 is num){
      this.x -= x_OR_vec3;
      this.y -= y == null ? x_OR_vec3 : y;
      this.z -= z == null ? x_OR_vec3 : z;
    }
    return this;
  }
  
  Vec3 subVector(Vec3 other) => subValues(other.x, other.y, other.z);
  
  Vec3 subValues(num x, num y, num z){
    this.x -= x;
    this.y -= y;
    this.z -= z;
    return this;
  }
  
  Vec3 scl (x_OR_vec3, [num y, num z]) {
    if( x_OR_vec3 is Vec3){
      sclValues(x_OR_vec3.x, x_OR_vec3.y, x_OR_vec3.z);
    }else if(x_OR_vec3 is num){
      this.x *= x_OR_vec3;
      this.y *= y == null ? x_OR_vec3 : y;
      this.z *= z == null ? x_OR_vec3 : z;
    }
    return this;
  }
  
  Vec3 sclVector(Vec3 other) => sclValues(other.x, other.y, other.z);
  
  Vec3 sclValues(num x, num y, num z){
    this.x *= x;
    this.y *= y;
    this.z *= z;
    return this;
  }
  
  /// First scale a supplied vector, then add it to this vector.
  Vec3 sclAddScalar(Vec3 vec, num scalar) {
    this.x += vec.x * scalar;
    this.y += vec.y * scalar;
    this.z += vec.z * scalar;
    return this;
  }

  /// First scale a supplied vector, then add it to this vector.
  Vec3 sclAddVector(Vec3 vec, Vec3 mulVec) {
    this.x += vec.x * mulVec.x;
    this.y += vec.y * mulVec.y;
    this.z += vec.z * mulVec.z;
    return this;
  }
  
  /// the distance between this and the [other] vector
  num dstVector(final Vec3 other) => dstValues(other.x, other.y, other.z);
  
  /// the distance between this and the other vector, defined by [x], [y], [z]
  num dstValues(num x, num y, num z) {
      final num a = x - this.x;
      final num b = y - this.y;
      final num c = z - this.z;
      return sqrt(a * a + b * b + c * c);
  }
  
  /**
   * The squared distance between this and the [other] vector.
   * This method is faster than [Vec3.dst] because it avoids calculating a square root. 
   * It is useful for comparisons, but not for getting accurate distances, as the return value is the 
   * square of the actual distance
   */
  num dst2Vector(final Vec3 other) => dstValues(other.x, other.y, other.z);
  
  /**
   * The squared distance between this and the other vector, defined by [x], [y], [z].
   * This method is faster than [Vec3.dst] because it avoids calculating a square root. 
   * It is useful for comparisons, but not for getting accurate distances, as the return value is the 
   * square of the actual distance
   */
  num dst2Values(num x, num y, num z) {
      final num a = x - this.x;
      final num b = y - this.y;
      final num c = z - this.z;
      return sqrt(a * a + b * b + c * c);
  }
  
  ///Normalizes this vector. Does nothing if it is zero.
  Vec3 nor () {
    num len2 = this.length2();
    if (len2 == 0 || len2 == 1) return this;
    return this.scl(1 / sqrt(len2));
  }
  
  ///The dot product between this and the [other] vector 
  num dot(final Vec3 other) => dotValues(other.x, other.y, other.z);
  
  /// The dot product between this and the other vector, defined by [x], [y], [z] 
  num dotValues(num x, num y, num z) => this.x * x + this.y * y + this.z * z;
  
  /// Sets this vector to the cross product between it and the [other] vector.
  Vec3 crs(final Vec3 other) => crsValues(other.x, other.y, other.z);
  
  ///Sets this vector to the cross product between it and the other vector, defined by [x], [y], [z] 
  Vec3 crsValues(num x, num y, num z) => this..set(this.y * z - this.z * y, this.z * x - this.x * z, this.x * y - this.y * x);
  
  /// Left-multiplies the vector by the given matrix, assuming the fourth (w) component of the vector is 1.
  Vec3 mulMatrix4(Matrix4 matrix){
      var l_mat = matrix.val;
      
      set(x * l_mat[Matrix4.M00] + y * l_mat[Matrix4.M01] + z * l_mat[Matrix4.M02] + l_mat[Matrix4.M03], 
          x * l_mat[Matrix4.M10] + y * l_mat[Matrix4.M11] + z * l_mat[Matrix4.M12] + l_mat[Matrix4.M13], 
          x * l_mat[Matrix4.M20] + y * l_mat[Matrix4.M21] + z * l_mat[Matrix4.M22] + l_mat[Matrix4.M23]);
      
      return this;
  }
  
  /// Multiplies the vector by the transpose of the given matrix, assuming the fourth (w) component of the vector is 1.
  Vec3 traMulMatrix4 (Matrix4 matrix) {
      var l_mat = matrix.val;
      set(x * l_mat[Matrix4.M00] + y * l_mat[Matrix4.M10] + z * l_mat[Matrix4.M20] + l_mat[Matrix4.M30], x
        * l_mat[Matrix4.M01] + y * l_mat[Matrix4.M11] + z * l_mat[Matrix4.M21] + l_mat[Matrix4.M31], x * l_mat[Matrix4.M02] + y
        * l_mat[Matrix4.M12] + z * l_mat[Matrix4.M22] + l_mat[Matrix4.M32]);
      
      return this;
  }
  
  /// Left-multiplies the vector by the given matrix.
  Vec3 mulMatrix3(Matrix3 matrix) {
    var l_mat = matrix.val;
    return set(x * l_mat[Matrix3.M00] + y * l_mat[Matrix3.M01] + z * l_mat[Matrix3.M02], x * l_mat[Matrix3.M10] + y
      * l_mat[Matrix3.M11] + z * l_mat[Matrix3.M12], x * l_mat[Matrix3.M20] + y * l_mat[Matrix3.M21] + z * l_mat[Matrix3.M22]);
  }
  
  ///  Multiplies the vector by the transpose of the given matrix.
  Vec3 traMulMatrix3(Matrix3 matrix) {
    var l_mat = matrix.val;
    return set(x * l_mat[Matrix3.M00] + y * l_mat[Matrix3.M10] + z * l_mat[Matrix3.M20], x * l_mat[Matrix3.M01] + y
      * l_mat[Matrix3.M11] + z * l_mat[Matrix3.M21], x * l_mat[Matrix3.M02] + y * l_mat[Matrix3.M12] + z * l_mat[Matrix3.M22]);
  }
  
  /// Multiplies the vector by the given [Quaternion].
  Vec3 mulQuat(Quaternion quat) {
      return quat.transform(this);
  }
  
  /**
   * Multiplies this vector by the given matrix dividing by w, assuming the fourth (w) component of the vector is 1. This is
   * mostly used to project/unproject vectors via a perspective projection matrix.
   */
  Vec3 project (Matrix4 matrix) {
    var l_mat = matrix.val;
    num l_w = 1 / (x * l_mat[Matrix4.M30] + y * l_mat[Matrix4.M31] + z * l_mat[Matrix4.M32] + l_mat[Matrix4.M33]);
    
    set((x * l_mat[Matrix4.M00] + y * l_mat[Matrix4.M01] + z * l_mat[Matrix4.M02] + l_mat[Matrix4.M03]) * l_w, (x
      * l_mat[Matrix4.M10] + y * l_mat[Matrix4.M11] + z * l_mat[Matrix4.M12] + l_mat[Matrix4.M13])
      * l_w, (x * l_mat[Matrix4.M20] + y * l_mat[Matrix4.M21] + z * l_mat[Matrix4.M22] + l_mat[Matrix4.M23]) * l_w);
    
    return this;
  }
  
  /// Multiplies this vector by the first three columns of the matrix, essentially only applying rotation and scaling.
  Vec3 rotateMatrix4(Matrix4 matrix) {
    var l_mat = matrix.val;
    return this.set(x * l_mat[Matrix4.M00] + y * l_mat[Matrix4.M01] + z * l_mat[Matrix4.M02], x * l_mat[Matrix4.M10] + y
      * l_mat[Matrix4.M11] + z * l_mat[Matrix4.M12], x * l_mat[Matrix4.M20] + y * l_mat[Matrix4.M21] + z * l_mat[Matrix4.M22]);
  }
  
  /** Rotates this vector by the given angle in degrees around the given axis.
   * 
   * @param degrees the angle in degrees
   * @param axisX the x-component of the axis
   * @param axisY the y-component of the axis
   * @param axisZ the z-component of the axis
   * @return This vector for chaining */
  Vec3 rotateDeg(double degrees, double axisX, double axisY, double axisZ) => 
      this.mulMatrix4(tmpMat.setToRotation(axisX, axisY, axisZ, degrees));

  /** Rotates this vector by the given angle in radians around the given axis.
   * 
   * @param radians the angle in radians
   * @param axisX the x-component of the axis
   * @param axisY the y-component of the axis
   * @param axisZ the z-component of the axis
   * @return This vector for chaining */
  Vec3 rotateRad(double radians, double axisX, double axisY, double axisZ) {
    return this.mulMatrix4(tmpMat.setToRotationRad(axisX, axisY, axisZ, radians));
  }

  /** Rotates this vector by the given angle in degrees around the given axis.
   * 
   * @param axis the axis
   * @param degrees the angle in degrees
   * @return This vector for chaining */
  Vec3 rotateDegVector(Vec3 axis, double degrees) {
    tmpMat.setToRotation(axis.x, axis.y, axis.z, degrees);
    return this.mulMatrix4(tmpMat);
  }

  /** Rotates this vector by the given angle in radians around the given axis.
   * 
   * @param axis the axis
   * @param radians the angle in radians
   * @return This vector for chaining */
  Vec3 rotateRadVector(final Vec3 axis, double radians) {
    tmpMat.setToRotationRad(axis.x, axis.y, axis.z, radians);
    return this.mulMatrix4(tmpMat);
  }
  
  
  toString() => '[x: $x, y: $y, z: $z]';

}