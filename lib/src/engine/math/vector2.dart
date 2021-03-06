part of glib.math;

class Vector2{
  static final Vector2 Zero = new Vector2._internal([0.0, 0.0]);
  static final Vector2 X = new Vector2._internal([1.0, 0.0]);
  static final Vector2 Y = new Vector2._internal([0.0, 1.0]);
  
  final Float32List val;
  
  double get x => val[0];
  void set x(double value){ 
    val[0] = value;
  }
  
  double get y => val[1];
  void set y(double value){
    val[1] = value;
  }
    
  Vector2([double x = 0.0, double y = 0.0])
    :val = new Float32List(2)
  {
    val[0] = x;
    val[1] = y;
  }
  
  Vector2._internal(this.val);

  Vector2.from(Vector2 v): this(v.x, v.y);
  
  Vector2.fromVector3(Vector3 v): this(v.x, v.y);
  
  Vector2 copy () {
    return new Vector2.from(this);
  }
  
  bool get isZero => this == Vector2.Zero;
  Vector2 setZero () => set(Vector2.Zero);
  
 /// the negation of this vector
 Vector2 operator -() => copy().scl(-1);
 Vector2 operator -(v) => copy().sub(v);
 Vector2 operator +(v) => copy().add(v);
 Vector2 operator *(v) => copy().scl(v);
 bool operator ==(Vector2 other) => other.x == x && other.y == y;
  
  num length() => sqrt(x * x + y * y);
  
  num length2() => x * x + y * y;
  
  Vector2 set(x_OR_vec2, [num y]) {
    if (x_OR_vec2 is Vector2)
      setFrom(x_OR_vec2);
    else if(x_OR_vec2 is num)
      setValues(x_OR_vec2, y != null ? y : x_OR_vec2);
    return this;
  }
  
  Vector2 setFrom(Vector2 other) => setValues(other.x, other.y);
  
  Vector2 setValues(double x, double y){
    this.x = x;
    this.y = y;
    return this;
  }
  
  /// Adds the given components to this vector
  Vector2 add(x_OR_vec2, [num y]) {
    if (x_OR_vec2 is Vector2)
      addValues(x_OR_vec2.x, x_OR_vec2.y);
    else if(x_OR_vec2 is num)
      addValues(x_OR_vec2, y != null ? y : x_OR_vec2);
    return this;
  }
  
  Vector2 addVector(Vector2 other) => addValues(other.x, other.y);
  
  Vector2 addValues(num x, num y){
    return this
      ..x += x
      ..y += y;
  }

  /// substracts the given components from this vector
  Vector2 sub(x_OR_vec2, [num y]) {
    if (x_OR_vec2 is Vector2)
      subValues(x_OR_vec2.x, x_OR_vec2.y);
    else if(x_OR_vec2 is num)
      subValues(x_OR_vec2, y != null ? y : x_OR_vec2);
    return this;
  }
  
  Vector2 subVector(Vector2 other) => subValues(other.x, other.y);
  
  Vector2 subValues(num x, num y){ 
    return this..x -= x ..y -= y;
  }
  
  ///multiplies this vector by the given components
  Vector2 scl( x_OR_vec2, [num y]) {
    if (x_OR_vec2 is Vector2){
      sclValues(x_OR_vec2.x, x_OR_vec2.y);
    }else if(x_OR_vec2 is num){
      sclValues(x_OR_vec2, y != null ? y : x_OR_vec2);
    }
    return this;
  }
  
  Vector2 sclVector(Vector2 other) => sclValues(other.x, other.y);
  
  Vector2 sclValues(num x, num y){
    this.x *= x;
    this.y *= y;
    return this;
  }

  /// Normalizes this vector. Does nothing if it is zero.
  Vector2 nor () {
    num len = length();
    if (len != 0) {
      x /= len;
      y /= len;
    }
    return this;
  }

  num dot (x_OR_vec2, [num y]) {
    if(x_OR_vec2 is Vector2)
      return x * x_OR_vec2.x + y * x_OR_vec2.y;  
    
    return this.x * x_OR_vec2 + this.y * y;
  }
  
  /// returns the distance between this and the other vector
  num dst (x_OR_vec2, [num y]) {
    return sqrt(dst2(x_OR_vec2, y));
  }
  
  /// returns the squared distance between this and the other vector
  num dst2 (x_OR_vec2, [num y]) {
      num dx, dy;
      if(x_OR_vec2 is Vector2){
        dx = x_OR_vec2.x - this.x;
        dy = x_OR_vec2.y - this.y;
      }else if(x_OR_vec2 is num){
        dx = x_OR_vec2 - this.x;
        dy = y - this.y;
      }
      
      return dx * dx + dy * dy;
    }

  Vector2 limit (num limit) {
    if (length2() > limit * limit) {
      nor().scl(limit);
    }
    return this;
  }

  /// clamps x and y to be min <= val <= max
  clamp (num min, num max) {
    num l2 = length2();
    if (l2 == 0) return this;
    if (l2 > max * max) 
      nor().scl(max);
    if (l2 < min * min) 
      nor().scl(min);
  }

  /// returns the cross product against the other vector
  num crs (x_OR_vec2, [num y]) {
    if(x_OR_vec2 is Vector2){
      return this.x * x_OR_vec2.y - this.y * x_OR_vec2.x;
    }else if(x_OR_vec2 is num){
      return this.x * y - this.y * x_OR_vec2;
    }
    
    throw new ArgumentError();
  }

  /// the angle in degrees of this vector (point) relative to the x-axis. Angles are towards the positive y-axis (typically counter-clockwise) and between 0 and 360
  num angle() {

    num angle = atan2(y, x) * MathUtils.radiansToDegrees;
    if (angle < 0) angle += 360;
    return angle;
  }

  /// the angle in degrees of this vector (point) relative to the given vector. Angles are towards the positive y-axis (typically counter-clockwise.) between -180 and +180
  num angleAgainst(Vector2 reference) => atan2(crs(reference), dot(reference)) * MathUtils.radiansToDegrees;

  /// the angle in radians of this vector (point) relative to the x-axis. Angles are towards the positive y-axis. (typically counter-clockwise)
  num angleRad () => atan2(y, x);

  /// the angle in radians of this vector (point) relative to the given vector. Angles are towards the positive y-axis. (typically counter-clockwise.)
  num angleRadAgainst(Vector2 reference) => atan2(crs(reference), dot(reference));

  /// Sets the angle of the vector in degrees relative to the x-axis, towards the positive y-axis (typically counter-clockwise).
  Vector2 setAngle (num degrees) => setAngleRad(degrees * MathUtils.degreesToRadians);

  /// Sets the angle of the vector in radians relative to the x-axis, towards the positive y-axis (typically counter-clockwise)
  Vector2 setAngleRad(num radians) => set(length(), 0).rotateRad(radians);

  /// Rotates the Vec2 by the given angle, counter-clockwise assuming the y-axis points up
  Vector2 rotate (num degrees) => rotateRad(degrees * MathUtils.degreesToRadians);

  /// Rotates the Vec2 by the given angle, counter-clockwise assuming the y-axis points up
  Vector2 rotateRad (num radians) {
    num cosine = cos(radians);
    num sine = sin(radians);

    num newX = this.x * cosine - this.y * sine;
    num newY = this.x * sine + this.y * cosine;

    this.x = newX;
    this.y = newY;

    return this;
  }

  /// rotates the Vec2 by 90 degrees in the specified direction
  Vector2 rotate90 (bool clockwise) {
    num x = this.x;
    if (!clockwise ) {
      this.x = -y;
      y = x;
    } else {
      this.x = y;
      y = -x;
    }
    return this;
  }

  /// linear interpolation between this vector and the [target] vector, scaled by alpha
  Vector2 lerp (Vector2 target, num alpha) {
    final num invAlpha = 1 - alpha;
    this.x = (x * invAlpha) + (target.x * alpha);
    this.y = (y * invAlpha) + (target.y * alpha);
    return this;
  }

  /// Compares this vector with the other vector, using the supplied epsilon for fuzzy equality testing
  bool epsilonEqualsVector(Vector2 other, num epsilon) => other != null && epsilonEquals(other.x, other.y, epsilon);

  /// Compares this vector with the vector defined by (x,y), using the supplied epsilon for fuzzy equality testing
  bool epsilonEquals (num x, num y, num epsilon) {
    if ((x - this.x).abs() > epsilon) return false;
    if ((y - this.y).abs() > epsilon) return false;
    return true;
  }
  
  bool isPerpendicularTo(Vector2 vector) => dot(vector) == 0;
  
  bool hasSameDirection (Vector2 vector) => dot(vector) > 0; 

  bool hasOppositeDirection (Vector2 vector) => dot(vector) < 0; 
  
  toString() => '[x: $x, y: $y]';
}





