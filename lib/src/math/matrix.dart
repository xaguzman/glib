part of glib;

class Matrix4 extends VMath.Matrix4{
  
  /** XX: Typically the unrotated X component for scaling, also the cosine of the angle when rotated on the Y and/or Z axis. On
     * Vec3 multiplication this value is multiplied with the source X component and added to the target X component. */
      static final int M00 = 0;
    
    /** XY: Typically the negative sine of the angle when rotated on the Z axis. On Vec3 multiplication this value is multiplied
     * with the source Y component and added to the target X component. */
    static final int M01 = 4;
    
    /** XZ: Typically the sine of the angle when rotated on the Y axis. On Vec3 multiplication this value is multiplied with the
     * source Z component and added to the target X component. */
    static final int M02 = 8;
    
    /** XW: Typically the translation of the X component. On Vec3 multiplication this value is added to the target X component. */
    static final int M03 = 12;
    
    /** YX: Typically the sine of the angle when rotated on the Z axis. On Vec3 multiplication this value is multiplied with the
     * source X component and added to the target Y component. */
    static final int M10 = 1;
    
    /** YY: Typically the unrotated Y component for scaling, also the cosine of the angle when rotated on the X and/or Z axis. On
     * Vec3 multiplication this value is multiplied with the source Y component and added to the target Y component. */
    static final int M11 = 5;
    
    /** YZ: Typically the negative sine of the angle when rotated on the X axis. On Vec3 multiplication this value is multiplied
     * with the source Z component and added to the target Y component. */
    static final int M12 = 9;
    
    /** YW: Typically the translation of the Y component. On Vec3 multiplication this value is added to the target Y component. */
    static final int M13 = 13;
    
    /** ZX: Typically the negative sine of the angle when rotated on the Y axis. On Vec3 multiplication this value is multiplied
     * with the source X component and added to the target Z component. */
    static final int M20 = 2;
    
    /** ZY: Typical the sine of the angle when rotated on the X axis. On Vec3 multiplication this value is multiplied with the
     * source Y component and added to the target Z component. */   
    static final int M21 = 6;
    
    /** ZZ: Typically the unrotated Z component for scaling, also the cosine of the angle when rotated on the X and/or Y axis. On
     * Vec3 multiplication this value is multiplied with the source Z component and added to the target Z component. */
    static final int M22 = 10;
    
    /// ZW: Typically the translation of the Z component. On Vec3 multiplication this value is added to the target Z component. */
    static final int M23 = 14;
    
    /// WX: Typically the value zero. On Vec3 multiplication this value is ignored. */
    static final int M30 = 3;
    
    /// WY: Typically the value zero. On Vec3 multiplication this value is ignored. */
    static final int M31 = 7;
    
    /// WZ: Typically the value zero. On Vec3 multiplication this value is ignored. */
    static final int M32 = 11;
    
    /// WW: Typically the value one. On Vec3 multiplication this value is ignored. */
    static final int M33 = 15;
  
    ///creates an identity matrix
    Matrix4():super.identity();
}


class Matrix3 extends VMath.Matrix3{
  Matrix3():super.identity();
}