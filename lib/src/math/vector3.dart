part of glib;


class Vec3 extends VMath.Vector3{
  num x, y, z;

  static final Vec3 X = new Vec3(1, 0, 0);
  static final Vec3 Y = new Vec3(0, 1, 0);
  static final Vec3 Z = new Vec3(0, 0, 1);
  static final Vec3 Zero = new Vec3(0, 0, 0);


  Vec3([x = 0, y = 0, z = 0]) : super(x,y,z);

  Vec3.from(final Vec3 vector): this(vector.x, vector.y, vector.z) ;
  
  Vec3.fromVector2(Vec2 vector, [num z = 0]): this(vector.x, vector.y, z) ;
  
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
  
  Vec3 setValues(num x, num y, num z){
    this.x = x;
    this.y = y;
    this.z = z;
    return this;
  }
  
  Vec3 add (x_OR_vec3, [double y, double z]) {
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
  
  Vec3 sub (x_OR_vec3, [double y, double z]) {
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
  
  Vec3 scl (x_OR_vec3, [double y, double z]) {
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
  
  Vec3 multiplyByMatrix4(Matrix4 matrix){
    var l_mat = matrix.storage;
    
    set(x * l_mat[Matrix4.M00] + y * l_mat[Matrix4.M01] + z * l_mat[Matrix4.M02] + l_mat[Matrix4.M03], 
        x * l_mat[Matrix4.M10] + y * l_mat[Matrix4.M11] + z * l_mat[Matrix4.M12] + l_mat[Matrix4.M13], 
        x * l_mat[Matrix4.M20] + y * l_mat[Matrix4.M21] + z * l_mat[Matrix4.M22] + l_mat[Matrix4.M23]);
    
    return this;
  }
  
  Vec3 setZero () => set(Vec3.Zero);
  
  toString() => '[x: $x, y: $y, z: $z]';

}