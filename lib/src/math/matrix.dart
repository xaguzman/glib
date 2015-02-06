part of glib.math;

class Matrix4{
  
  /** XX: Typically the unrotated X component for scaling, also the cosine of the angle when rotated on the Y and/or Z axis. On
   * Vector3 multiplication this value is multiplied with the source X component and added to the target X component. */
  static final int M00 = 0;
  /** XY: Typically the negative sine of the angle when rotated on the Z axis. On Vector3 multiplication this value is multiplied
   * with the source Y component and added to the target X component. */
  static final int M01 = 4;
  /** XZ: Typically the sine of the angle when rotated on the Y axis. On Vector3 multiplication this value is multiplied with the
   * source Z component and added to the target X component. */
  static final int M02 = 8;
  /** XW: Typically the translation of the X component. On Vector3 multiplication this value is added to the target X component. */
  static final int M03 = 12;
  /** YX: Typically the sine of the angle when rotated on the Z axis. On Vector3 multiplication this value is multiplied with the
   * source X component and added to the target Y component. */
  static final int M10 = 1;
  /** YY: Typically the unrotated Y component for scaling, also the cosine of the angle when rotated on the X and/or Z axis. On
   * Vector3 multiplication this value is multiplied with the source Y component and added to the target Y component. */
  static final int M11 = 5;
  /** YZ: Typically the negative sine of the angle when rotated on the X axis. On Vector3 multiplication this value is multiplied
   * with the source Z component and added to the target Y component. */
  static final int M12 = 9;
  /** YW: Typically the translation of the Y component. On Vector3 multiplication this value is added to the target Y component. */
  static final int M13 = 13;
  /** ZX: Typically the negative sine of the angle when rotated on the Y axis. On Vector3 multiplication this value is multiplied
   * with the source X component and added to the target Z component. */
  static final int M20 = 2;
  /** ZY: Typical the sine of the angle when rotated on the X axis. On Vector3 multiplication this value is multiplied with the
   * source Y component and added to the target Z component. */
  static final int M21 = 6;
  /** ZZ: Typically the unrotated Z component for scaling, also the cosine of the angle when rotated on the X and/or Y axis. On
   * Vector3 multiplication this value is multiplied with the source Z component and added to the target Z component. */
  static final int M22 = 10;
  /** ZW: Typically the translation of the Z component. On Vector3 multiplication this value is added to the target Z component. */
  static final int M23 = 14;
  /** WX: Typically the value zero. On Vector3 multiplication this value is ignored. */
  static final int M30 = 3;
  /** WY: Typically the value zero. On Vector3 multiplication this value is ignored. */
  static final int M31 = 7;
  /** WZ: Typically the value zero. On Vector3 multiplication this value is ignored. */
  static final int M32 = 11;
  /** WW: Typically the value one. On Vector3 multiplication this value is ignored. */
  static final int M33 = 15;
  
  static final Float32List tmp = new Float32List(16);
  final Float32List val = new Float32List(16);
  
  static final Vector3 _tmpVec = new Vector3();
  static final Matrix4 _tmpMat = new Matrix4();
  static Quaternion _quat = new Quaternion();
  static Quaternion _quat2 = new Quaternion();
  static final Vector3 _l_vez = new Vector3();
  static final Vector3 _l_vey = new Vector3();
  static final Vector3 _l_vex = new Vector3();

  ///creates an identity matrix
  Matrix4(){
    setIdentity();
  }
  
  factory Matrix4.identity() => new Matrix4();

  /// Constructs a matrix from the given matrix.
  Matrix4.from(Matrix4 matrix){
    setMatrix(matrix);
  }

  /**
   * Constructs a matrix from the given double array. The array must have at least 16 elements; the first 16 will be copied.
   * 
   * [values] The double array to copy. Remember that this matrix is in [column major](http://en.wikipedia.org/wiki/Row-major_order) 
   * order. (The double array is not modified)
   */
  Matrix4.fromValues(Float32List values){
    setValues(values);
  }
  
  /** 
   * Constructs a rotation matrix from the given {@link Quaternion}.
   * 
   * [quat] The [Quaternion] to be copied. (The quaternion is not modified) 
   */
  Matrix4.rotation(Quaternion quat){
    setRotationQuat(quat);
  }
  
  /** 
   * Construct a matrix from the given translation, rotation and scale.
   * [position] The translation
   * [rotation] The rotation, must be normalized
   * [scale] The scale */
  Matrix4.transform (Vector3 position, Quaternion rotation, Vector3 scale) {
    setTransform(position, rotation, scale);
  }
  
  Matrix4 copy(Matrix4 matrix) => new Matrix4.from(matrix);
  
  /**
   * Sets the matrix to the given matrix as a double array. The double array must have at least 16 elements; the first 16 will be
   * copied.
   * 
   * [values] The double array to copy. Remember that this matrix is in [column major](http://en.wikipedia.org/wiki/Row-major_order) 
   * order. (The double array is not modified)
   */
  Matrix4 setValues(Float32List values) => this..val.setAll(0, values);
  
  /// Sets this matrix to the given matrix
  Matrix4 setMatrix(Matrix4 matrix) => setValues(matrix.val);
  
  /** Sets the matrix to a rotation matrix representing the quaternion.
   * 
   * [quaternion] The quaternion that is to be used to set this matrix.
   */
  Matrix4 setRotationQuat(Quaternion quaternion) => 
      setTransformValues(0.0, 0.0, 0.0, quaternion.x, quaternion.y, quaternion.z, quaternion.w);
  
  /** 
   * Sets the matrix to a rotation matrix representing the translation and quaternion, with the specified scale
   * 
   * [translationX] The X component of the translation that is to be used to set this matrix.
   * [translationY] The Y component of the translation that is to be used to set this matrix.
   * [translationZ] The Z component of the translation that is to be used to set this matrix.
   * [quaternionX] The X component of the quaternion that is to be used to set this matrix.
   * [quaternionY] The Y component of the quaternion that is to be used to set this matrix.
   * [quaternionZ] The Z component of the quaternion that is to be used to set this matrix.
   * [quaternionW] The W component of the quaternion that is to be used to set this matrix.
   * [scaleX] The X component of the scaling that is to be used to set this matrix (defaults to 1).
   * [scaleY] The Y component of the scaling that is to be used to set this matrix (defaults to 1).
   * [scaleZ] The Z component of the scaling that is to be used to set this matrix (defaults to 1).
   */
  Matrix4 setTransformValues(double translationX, double translationY, double translationZ, double quaternionX, double quaternionY,
                            double quaternionZ, double quaternionW, [double scaleX = 1.0, double scaleY = 1.0, double scaleZ = 1.0]) {
    final double xs = quaternionX * 2, ys = quaternionY * 2, zs = quaternionZ * 2;
    final double wx = quaternionW * xs, wy = quaternionW * ys, wz = quaternionW * zs;
    final double xx = quaternionX * xs, xy = quaternionX * ys, xz = quaternionX * zs;
    final double yy = quaternionY * ys, yz = quaternionY * zs, zz = quaternionZ * zs;

    val[M00] = scaleX * (1.0 - (yy + zz));
    val[M01] = scaleY * (xy - wz);
    val[M02] = scaleZ * (xz + wy);
    val[M03] = translationX;

    val[M10] = scaleX * (xy + wz);
    val[M11] = scaleY * (1.0 - (xx + zz));
    val[M12] = scaleZ * (yz - wx);
    val[M13] = translationY;

    val[M20] = scaleX * (xz - wy);
    val[M21] = scaleY * (yz + wx);
    val[M22] = scaleZ * (1.0 - (xx + yy));
    val[M23] = translationZ;

    val[M30] = 0.0;
    val[M31] = 0.0;
    val[M32] = 0.0;
    val[M33] = 1.0;
    return this;
  }
  
  Matrix4 setTransform(Vector3 position, Quaternion orientation, Vector3 scale) =>
      setTransformValues(position.z, position.y, position.z, orientation.x, orientation.y, orientation.z, orientation.w,  scale.x, scale.y, scale.z);
  
  /** Sets the four columns of the matrix which correspond to the x-, y- and z-axis of the vector space this matrix creates as
   * well as the 4th column representing the translation of any point that is multiplied by this matrix.
   * 
   * [xAxis] The x-axis.
   * [yAxis] The y-axis.
   * [zAxis] The z-axis.
   * [pos] The translation vector. */
  Matrix4 setColumns(Vector3 xAxis, Vector3 yAxis, Vector3 zAxis, Vector3 pos) {
    val[M00] = xAxis.x;
    val[M01] = xAxis.y;
    val[M02] = xAxis.z;
    val[M10] = yAxis.x;
    val[M11] = yAxis.y;
    val[M12] = yAxis.z;
    val[M20] = zAxis.x;
    val[M21] = zAxis.y;
    val[M22] = zAxis.z;
    val[M03] = pos.x;
    val[M13] = pos.y;
    val[M23] = pos.z;
    val[M30] = 0.0;
    val[M31] = 0.0;
    val[M32] = 0.0;
    val[M33] = 1.0;
    return this;
  }
  
  Matrix4 translate(num x, num y, num z){
    val[M03] += x;
    val[M13] += y;
    val[M23] += z;
    return this;
  }
  
  /** Postmultiplies this matrix with the given matrix, storing the result in this matrix. For example:
   * 
   * A.mul(B) results in A := AB.
   */
  Matrix4 multiply (Matrix4 matrix) {
    _mul(val, matrix.val);
    return this;
  }
  
  /// multiples both matrices and stores result in [a]
  _mul(Float32List a, Float32List b){
    double 
        a00 = a[M00], a01 = a[M01], a02 = a[M02], a03 = a[M03],
        a10 = a[M10], a11 = a[M11], a12 = a[M12], a13 = a[M13],
        a20 = a[M20], a21 = a[M21], a22 = a[M22], a23 = a[M23],
        a30 = a[M30], a31 = a[M31], a32 = a[M32], a33 = a[M33];
    
    double
        b00 = b[M00], b01 = b[M01], b02 = b[M02], b03 = b[M03],
        b10 = b[M10], b11 = b[M11], b12 = b[M12], b13 = b[M13],
        b20 = b[M20], b21 = b[M21], b22 = b[M22], b23 = b[M23],
        b30 = b[M30], b31 = b[M31], b32 = b[M32], b33 = b[M33];
    
    a[M00] = a00 * b00 + a01 * b10 + a02 * b20 +  a03 * b30;
    a[M01] = a00 * b01 + a01 * b11 + a02 * b21 +  a03 * b31; 
    a[M02] = a00 * b02 + a01 * b12 + a02 * b22 +  a03 * b32;
    a[M03] = a00 * b03 + a01 * b13 + a02 * b23 +  a03 * b33;
    
    a[M10] = a10 * b00 + a11 * b10 + a12 * b20 +  a13 * b30;
    a[M11] = a10 * b01 + a11 * b11 + a12 * b21 +  a13 * b31; 
    a[M12] = a10 * b02 + a11 * b12 + a12 * b22 +  a13 * b32;
    a[M13] = a10 * b03 + a11 * b13 + a12 * b23 +  a13 * b33;
    
    a[M20] = a20 * b00 + a21 * b10 + a22 * b20 +  a23 * b30;
    a[M21] = a20 * b01 + a21 * b11 + a22 * b21 +  a23 * b31; 
    a[M22] = a20 * b02 + a21 * b12 + a22 * b22 +  a23 * b32;
    a[M23] = a20 * b03 + a21 * b13 + a22 * b23 +  a23 * b33;
    
    a[M30] = a30 * b00 + a31 * b10 + a32 * b20 +  a33 * b30;
    a[M31] = a30 * b01 + a31 * b11 + a32 * b21 +  a33 * b31; 
    a[M32] = a30 * b02 + a31 * b12 + a32 * b22 +  a33 * b32;
    a[M33] = a30 * b03 + a31 * b13 + a32 * b23 +  a33 * b33;
  }
  
  /** Premultiplies this matrix with the given matrix, storing the result in this matrix. For example:
  * 
  * A.mulLeft(B) results in A := BA.
  */
  Matrix4 multiplyLeft (Matrix4 matrix) {
    _tmpMat.setMatrix(matrix);
    _mul(_tmpMat.val, this.val);
    return setMatrix(_tmpMat);
  }
  
  
  Matrix4 transpose () {
    tmp[M00] = val[M00];
    tmp[M01] = val[M10];
    tmp[M02] = val[M20];
    tmp[M03] = val[M30];
    tmp[M10] = val[M01];
    tmp[M11] = val[M11];
    tmp[M12] = val[M21];
    tmp[M13] = val[M31];
    tmp[M20] = val[M02];
    tmp[M21] = val[M12];
    tmp[M22] = val[M22];
    tmp[M23] = val[M32];
    tmp[M30] = val[M03];
    tmp[M31] = val[M13];
    tmp[M32] = val[M23];
    tmp[M33] = val[M33];
    return setValues(tmp);
  }
  
  Matrix4 setIdentity () {
    val[M00] = 1.0;
    val[M01] = 0.0;
    val[M02] = 0.0;
    val[M03] = 0.0;
    val[M10] = 0.0;
    val[M11] = 1.0;
    val[M12] = 0.0;
    val[M13] = 0.0;
    val[M20] = 0.0;
    val[M21] = 0.0;
    val[M22] = 1.0;
    val[M23] = 0.0;
    val[M30] = 0.0;
    val[M31] = 0.0;
    val[M32] = 0.0;
    val[M33] = 1.0;
    return this;
  }
  
  /** Inverts the matrix. Stores the result in this matrix.
   * 
   * @return This matrix for the purpose of chaining methods together.
   * @throws RuntimeException if the matrix is singular (not invertible) */
  Matrix4 invert () {
    double l_det = val[M30] * val[M21] * val[M12] * val[M03] - val[M20] * val[M31] * val[M12] * val[M03] - val[M30] * val[M11]
      * val[M22] * val[M03] + val[M10] * val[M31] * val[M22] * val[M03] + val[M20] * val[M11] * val[M32] * val[M03] - val[M10]
      * val[M21] * val[M32] * val[M03] - val[M30] * val[M21] * val[M02] * val[M13] + val[M20] * val[M31] * val[M02] * val[M13]
      + val[M30] * val[M01] * val[M22] * val[M13] - val[M00] * val[M31] * val[M22] * val[M13] - val[M20] * val[M01] * val[M32]
      * val[M13] + val[M00] * val[M21] * val[M32] * val[M13] + val[M30] * val[M11] * val[M02] * val[M23] - val[M10] * val[M31]
      * val[M02] * val[M23] - val[M30] * val[M01] * val[M12] * val[M23] + val[M00] * val[M31] * val[M12] * val[M23] + val[M10]
      * val[M01] * val[M32] * val[M23] - val[M00] * val[M11] * val[M32] * val[M23] - val[M20] * val[M11] * val[M02] * val[M33]
      + val[M10] * val[M21] * val[M02] * val[M33] + val[M20] * val[M01] * val[M12] * val[M33] - val[M00] * val[M21] * val[M12]
      * val[M33] - val[M10] * val[M01] * val[M22] * val[M33] + val[M00] * val[M11] * val[M22] * val[M33];
    
    if (l_det == 0.0) 
      throw new GlibException("non-invertible matrix");
    double inv_det = 1.0 / l_det;
    tmp[M00] = val[M12] * val[M23] * val[M31] - val[M13] * val[M22] * val[M31] + val[M13] * val[M21] * val[M32] - val[M11]
      * val[M23] * val[M32] - val[M12] * val[M21] * val[M33] + val[M11] * val[M22] * val[M33];
    tmp[M01] = val[M03] * val[M22] * val[M31] - val[M02] * val[M23] * val[M31] - val[M03] * val[M21] * val[M32] + val[M01]
      * val[M23] * val[M32] + val[M02] * val[M21] * val[M33] - val[M01] * val[M22] * val[M33];
    tmp[M02] = val[M02] * val[M13] * val[M31] - val[M03] * val[M12] * val[M31] + val[M03] * val[M11] * val[M32] - val[M01]
      * val[M13] * val[M32] - val[M02] * val[M11] * val[M33] + val[M01] * val[M12] * val[M33];
    tmp[M03] = val[M03] * val[M12] * val[M21] - val[M02] * val[M13] * val[M21] - val[M03] * val[M11] * val[M22] + val[M01]
      * val[M13] * val[M22] + val[M02] * val[M11] * val[M23] - val[M01] * val[M12] * val[M23];
    tmp[M10] = val[M13] * val[M22] * val[M30] - val[M12] * val[M23] * val[M30] - val[M13] * val[M20] * val[M32] + val[M10]
      * val[M23] * val[M32] + val[M12] * val[M20] * val[M33] - val[M10] * val[M22] * val[M33];
    tmp[M11] = val[M02] * val[M23] * val[M30] - val[M03] * val[M22] * val[M30] + val[M03] * val[M20] * val[M32] - val[M00]
      * val[M23] * val[M32] - val[M02] * val[M20] * val[M33] + val[M00] * val[M22] * val[M33];
    tmp[M12] = val[M03] * val[M12] * val[M30] - val[M02] * val[M13] * val[M30] - val[M03] * val[M10] * val[M32] + val[M00]
      * val[M13] * val[M32] + val[M02] * val[M10] * val[M33] - val[M00] * val[M12] * val[M33];
    tmp[M13] = val[M02] * val[M13] * val[M20] - val[M03] * val[M12] * val[M20] + val[M03] * val[M10] * val[M22] - val[M00]
      * val[M13] * val[M22] - val[M02] * val[M10] * val[M23] + val[M00] * val[M12] * val[M23];
    tmp[M20] = val[M11] * val[M23] * val[M30] - val[M13] * val[M21] * val[M30] + val[M13] * val[M20] * val[M31] - val[M10]
      * val[M23] * val[M31] - val[M11] * val[M20] * val[M33] + val[M10] * val[M21] * val[M33];
    tmp[M21] = val[M03] * val[M21] * val[M30] - val[M01] * val[M23] * val[M30] - val[M03] * val[M20] * val[M31] + val[M00]
      * val[M23] * val[M31] + val[M01] * val[M20] * val[M33] - val[M00] * val[M21] * val[M33];
    tmp[M22] = val[M01] * val[M13] * val[M30] - val[M03] * val[M11] * val[M30] + val[M03] * val[M10] * val[M31] - val[M00]
      * val[M13] * val[M31] - val[M01] * val[M10] * val[M33] + val[M00] * val[M11] * val[M33];
    tmp[M23] = val[M03] * val[M11] * val[M20] - val[M01] * val[M13] * val[M20] - val[M03] * val[M10] * val[M21] + val[M00]
      * val[M13] * val[M21] + val[M01] * val[M10] * val[M23] - val[M00] * val[M11] * val[M23];
    tmp[M30] = val[M12] * val[M21] * val[M30] - val[M11] * val[M22] * val[M30] - val[M12] * val[M20] * val[M31] + val[M10]
      * val[M22] * val[M31] + val[M11] * val[M20] * val[M32] - val[M10] * val[M21] * val[M32];
    tmp[M31] = val[M01] * val[M22] * val[M30] - val[M02] * val[M21] * val[M30] + val[M02] * val[M20] * val[M31] - val[M00]
      * val[M22] * val[M31] - val[M01] * val[M20] * val[M32] + val[M00] * val[M21] * val[M32];
    tmp[M32] = val[M02] * val[M11] * val[M30] - val[M01] * val[M12] * val[M30] - val[M02] * val[M10] * val[M31] + val[M00]
      * val[M12] * val[M31] + val[M01] * val[M10] * val[M32] - val[M00] * val[M11] * val[M32];
    tmp[M33] = val[M01] * val[M12] * val[M20] - val[M02] * val[M11] * val[M20] + val[M02] * val[M10] * val[M21] - val[M00]
      * val[M12] * val[M21] - val[M01] * val[M10] * val[M22] + val[M00] * val[M11] * val[M22];
    val[M00] = tmp[M00] * inv_det;
    val[M01] = tmp[M01] * inv_det;
    val[M02] = tmp[M02] * inv_det;
    val[M03] = tmp[M03] * inv_det;
    val[M10] = tmp[M10] * inv_det;
    val[M11] = tmp[M11] * inv_det;
    val[M12] = tmp[M12] * inv_det;
    val[M13] = tmp[M13] * inv_det;
    val[M20] = tmp[M20] * inv_det;
    val[M21] = tmp[M21] * inv_det;
    val[M22] = tmp[M22] * inv_det;
    val[M23] = tmp[M23] * inv_det;
    val[M30] = tmp[M30] * inv_det;
    val[M31] = tmp[M31] * inv_det;
    val[M32] = tmp[M32] * inv_det;
    val[M33] = tmp[M33] * inv_det;
    return this;
  }
  
  double determinant(){
    return 
        val[M30] * val[M21] * val[M12] * val[M03] - val[M20] * val[M31] * val[M12] * val[M03] - val[M30] * val[M11]
      * val[M22] * val[M03] + val[M10] * val[M31] * val[M22] * val[M03] + val[M20] * val[M11] * val[M32] * val[M03] - val[M10]
      * val[M21] * val[M32] * val[M03] - val[M30] * val[M21] * val[M02] * val[M13] + val[M20] * val[M31] * val[M02] * val[M13]
      + val[M30] * val[M01] * val[M22] * val[M13] - val[M00] * val[M31] * val[M22] * val[M13] - val[M20] * val[M01] * val[M32]
      * val[M13] + val[M00] * val[M21] * val[M32] * val[M13] + val[M30] * val[M11] * val[M02] * val[M23] - val[M10] * val[M31]
      * val[M02] * val[M23] - val[M30] * val[M01] * val[M12] * val[M23] + val[M00] * val[M31] * val[M12] * val[M23] + val[M10]
      * val[M01] * val[M32] * val[M23] - val[M00] * val[M11] * val[M32] * val[M23] - val[M20] * val[M11] * val[M02] * val[M33]
      + val[M10] * val[M21] * val[M02] * val[M33] + val[M20] * val[M01] * val[M12] * val[M33] - val[M00] * val[M21] * val[M12]
      * val[M33] - val[M10] * val[M01] * val[M22] * val[M33] + val[M00] * val[M11] * val[M22] * val[M33];
  }
  
  double determinant3x3(){
    return 
        val[M00] * val[M11] * val[M22] + val[M01] * val[M12] * val[M20] + val[M02] * val[M10] * val[M21] - val[M00]
      * val[M12] * val[M21] - val[M01] * val[M10] * val[M22] - val[M02] * val[M11] * val[M20];
  }
  
  /** Sets the matrix to a projection matrix with a near- and far plane, a field of view in degrees and an aspect ratio.
   * 
   * [near] The near plane
   * [far] The far plane
   * [fov] The field of view in degrees
   * [aspectRatio] The "width over height" aspect ratio
   */
  Matrix4 setToProjection (double near, double far, double fov, double aspectRatio) {
    setIdentity();
    double l_fd = (1.0 / tan( (fov * (PI/180) ) / 2.0));
    double l_a1 = (far + near) / (near - far);
    double l_a2 = (2 * far * near) / (near - far);
    val[M00] = l_fd / aspectRatio;
    val[M10] = 0.0;
    val[M20] = 0.0;
    val[M30] = 0.0;
    val[M01] = 0.0;
    val[M11] = l_fd;
    val[M21] = 0.0;
    val[M31] = 0.0;
    val[M02] = 0.0;
    val[M12] = 0.0;
    val[M22] = l_a1;
    val[M32] = -1.0;
    val[M03] = 0.0;
    val[M13] = 0.0;
    val[M23] = l_a2;
    val[M33] = 0.0;

    return this;
  }
  
  /** Sets this matrix to an orthographic projection matrix with the origin at (x,y) extending by width and height, having a near
   * and far plane.
   * 
   * [x] The x-coordinate of the origin
   * [y] The y-coordinate of the origin
   * [width] The width
   * [height] The height
   * [near] The near plane
   * [far] The far plane
   */
  Matrix4 setToOrtho2D (double x, double y, double width, double height, [double near = 0.0, double far = 1.0]) {
    setToOrtho(x, x + width, y, y + height, near, far);
    return this;
  }
  
  /** Sets the matrix to an orthographic projection like glOrtho (http://www.opengl.org/sdk/docs/man/xhtml/glOrtho.xml) following
   * the OpenGL equivalent
   * 
   * [left] The left clipping plane
   * [right] The right clipping plane
   * [bottom] The bottom clipping plane
   * [top] The top clipping plane
   * [near] The near clipping plane
   * [far] The far clipping plane
   */
  Matrix4 setToOrtho (double left, double right, double bottom, double top, double near, double far) {
    setIdentity();
    double x_orth = 2 / (right - left);
    double y_orth = 2 / (top - bottom);
    double z_orth = -2 / (far - near);

    double tx = -(right + left) / (right - left);
    double ty = -(top + bottom) / (top - bottom);
    double tz = -(far + near) / (far - near);

    val[M00] = x_orth;
    val[M10] = 0.0;
    val[M20] = 0.0;
    val[M30] = 0.0;
    val[M01] = 0.0;
    val[M11] = y_orth;
    val[M21] = 0.0;
    val[M31] = 0.0;
    val[M02] = 0.0;
    val[M12] = 0.0;
    val[M22] = z_orth;
    val[M32] = 0.0;
    val[M03] = tx;
    val[M13] = ty;
    val[M23] = tz;
    val[M33] = 1.0;

    return this;
  }
  
  /** Sets the 4th column to the translation vector.
   * 
   * [vector] The translation vector
   */
  Matrix4 setTranslationVector(Vector3 vector) {
    val[M03] = vector.x;
    val[M13] = vector.y;
    val[M23] = vector.z;
    return this;
  }
  
  /** Sets the 4th column to the translation vector.
   * 
   * [vector] The translation vector
   */
  Matrix4 setTranslationValues(double x, double y, double z) {
    val[M03] = x;
    val[M13] = y;
    val[M23] = z;
    return this;
  }
  
  /// Sets this matrix to a translation matrix, overwriting it first by an identity matrix and then setting the 4th column to the 
  /// translation vector.
  Matrix4 setToTranslation (vec3_OR_x, [double y, double z]) {
    setIdentity();
    if (vec3_OR_x is Vector3){
      val[M03] = vec3_OR_x.x;
      val[M13] = vec3_OR_x.y;
      val[M23] = vec3_OR_x.z;
    }else if (vec3_OR_x is num){
      val[M03] = vec3_OR_x;
      val[M13] = y == null ? vec3_OR_x : y;
      val[M23] = z == null ? vec3_OR_x : z;
    }
    return this;
  }
  
  /** Sets the matrix to a rotation matrix around the given axis.
   * 
   * [axisX] The x-component of the axis
   * [axisY] The y-component of the axis
   * [axisZ] The z-component of the axis
   * [degrees] The angle in degrees
   */
  Matrix4 setToRotation (double axisX, double axisY, double axisZ, double degrees) {
    if (degrees == 0) {
      setIdentity();
      return this;
    }
    return setRotationQuat( _quat.setFromAxis(axisX, axisY, axisZ, degrees) );
  }
  
  Matrix4 setToRotationRad (double axisX, double axisY, double axisZ, double radians) {
    if (radians == 0) {
      setIdentity();
      return this;
    }
    return setRotationQuat( _quat.setFromAxisRad(axisX, axisY, axisZ, radians));
  }
  
  Matrix4 setToLookAt(Vector3 position_OR_direction, Vector3 up, { Vector3 target: null} ){

    if (target != null){
      _tmpVec.set(target).sub(position_OR_direction);
      _setToLookAt(_tmpVec, up);
      this.multiply(_tmpMat.setToTranslation(-position_OR_direction.x, -position_OR_direction.y, -position_OR_direction.z));
    }else{
      _setToLookAt(position_OR_direction, up);
    }

    return this;
  }
  
  Matrix4 _setToLookAt(Vector3 direction, Vector3 up){
    _l_vez.set(direction).nor();
    _l_vex.set(direction).nor();
    _l_vex.crs(up).nor();
    _l_vey.set(_l_vex).crs(_l_vez).nor();
    setIdentity();
    val[M00] = _l_vex.x;
    val[M01] = _l_vex.y;
    val[M02] = _l_vex.z;
    val[M10] = _l_vey.x;
    val[M11] = _l_vey.y;
    val[M12] = _l_vey.z;
    val[M20] = -_l_vez.x;
    val[M21] = -_l_vez.y;
    val[M22] = -_l_vez.z;
    
    return this;
  }
  
  /// projects all the Vector3 in [vecs] using this matrix by calling [Vector3.project]
  void projectAll(List<Vector3> vecs, [int offset = 0]){
    for( int i = offset; i < vecs.length; i++){
      Vector3 vec = vecs[i];
      vec.project(this);
    }
  }
  
  /** Multiplies the vectors with the given matrix, performing a division by w. The matrix array is assumed to hold a 4x4 column
     * major matrix as you can get from [Matrix4.val]. The [vecs] array is assumed to hold [Vector3]s, [offset]
     * specifies the offset into the array where the x-component of the first vector is located. The [numVecs] parameter specifies
     * the number of vectors stored in the vectors array. The stride parameter specifies the number of floats between subsequent
     * vectors and must be >= 3. This is the same as [Vector3.project] applied to multiple vectors.
     * 
     * [mat] the matrix
     * [vecs] the vectors
     * [offset] the offset into the vectors array
     * [numVecs] the number of vectors
     * [stride] distance between each vector 
    */
  static void project(Float32List mat, Float32List vecs, int offset, int numVecs, int stride){
    for(int i = 0; i < numVecs; i++){
      _project(mat, vecs, offset);
      offset += stride;
    }
  }
  
  static void _project(Float32List mat, Float32List vec, int offset){
    double inv_w = 1.0 / (vec[0] * mat[M30] + vec[1] * mat[M31] + vec[2] * mat[M32] + mat[M33]);
    int idx0 = offset;
    int idx1 = offset + 1;
    int idx2 = offset + 2;
    
    double x = (vec[idx0] * mat[M00] + vec[idx1] * mat[M01] + vec[idx2] * mat[M02] + mat[M03]) * inv_w;
    double y = (vec[idx0] * mat[M10] + vec[idx1] * mat[M11] + vec[idx2] * mat[M12] + mat[M13]) * inv_w; 
    double z = (vec[idx0] * mat[M20] + vec[idx1] * mat[M21] + vec[idx2] * mat[M22] + mat[M23]) * inv_w;
    vec[idx0] = x;
    vec[idx1] = y;
    vec[idx2] = z;
  }
}


class Matrix3{
  static final int M00 = 0;
  static final int M01 = 3;
  static final int M02 = 6;
  static final int M10 = 1;
  static final int M11 = 4;
  static final int M12 = 7;
  static final int M20 = 2;
  static final int M21 = 5;
  static final int M22 = 8;
  
  Float32List val = new Float32List(9);
  Float32List _tmp = new Float32List(9);
}