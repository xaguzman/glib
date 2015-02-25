part of glib.graphics;

class Sprite extends TextureRegion{
  
  /** 
  * 5 vertices per sprite:
  * 2: position.xy
  * 1: packed color
  * 2: texcoord0.xy
  */
  static const VERTEX_SIZE = 2 + 1 + 2;
  static const SPRITE_SIZE = 4 * VERTEX_SIZE;

  final Float32List _vertices = new Float32List(SPRITE_SIZE);
  
  final Color color = Color.WHITE.copy();
  double _width, _height;
  double _x = 0.0, _y = 0.0;
  double _rotation = 0.0, _scaleX = 1.0, _scaleY = 1.0;
  double _originX = 0.0, _originY = 0.0;
  
  Rect _bounds = new Rect();
    
  bool _dirty = false; 
    
  /// Creates an uninitialized sprite. The sprite will need a texture region and bounds set before it can be drawn
  Sprite.empty(): super.empty();
  
 
  /// Creates a sprite with width, height, and texture region equal to the specified size.
  /// 
  /// [x] the X-axis coordinate matching the lower left corner of the region
  /// [y] the Y-axis coordinate matching the lower left corner of the region
  /// [srcWidth] The width of the texture region. May be negative to flip the sprite when drawn.
  /// [srcHeight] The height of the texture region. May be negative to flip the sprite when drawn. */
  Sprite(Texture texture, [int x, int y, int srcWidth, int srcHeight]): super(texture, x, y, srcWidth, srcHeight) {
    setSize(srcWidth.abs().toDouble(), srcHeight.abs().toDouble());
    setOrigin(_width / 2, _height / 2);
  }


    // Note the region is copied.
  /// Creates a sprite based on a specific TextureRegion, the new sprite's region is a copy of the parameter region, altering one does not affect the other
  Sprite.fromRegion(TextureRegion region): super.copy(region) {
    setSize(region.regionWidth.toDouble(), region.regionHeight.toDouble());
    setOrigin( _width / 2, _height / 2);
  }

  /// Creates a sprite that is a copy in every way of the specified sprite
  Sprite.copy(Sprite sprite): super.empty() {
    set(sprite);
  }
  
  void set(Sprite other){
    if (other == null) throw new ArgumentError.notNull("other");
    
    _vertices.setAll(0, other._vertices);
   
    texture = other.texture;
    u = other.u;
    v = other.v;
    u2 = other.u2;
    v2 = other.v2;
    _x = other._x;
    _y = other._y;
    _width = other._width;
    _height = other._height;
    regionWidth = other.regionWidth;
    regionHeight = other.regionHeight;
    _originX = other._originX;
    _originY = other._originY;
    _rotation = other._rotation;
    _scaleX = other._scaleX;
    _scaleY = other._scaleY;
    color.set(other.color);
    _dirty = other._dirty;
  }
    
  /// Sets the position and size of the sprite when drawn, before scaling and rotation are applied. If origin, rotation, or scale
  /// are changed, it is slightly more efficient to set the bounds after those operations. 
  void setBounds (double x, double y, double width, double height) {
    this._x = x;
    this._y = y;
    this._width = width;
    this._height = height;

    if (_dirty) return;

    double x2 = x + width;
    double y2 = y + height;
    
    Float32List vertices = this._vertices;
    vertices[Batch.X1] = x;
    vertices[Batch.Y1] = y;

    vertices[Batch.X2] = x;
    vertices[Batch.Y2] = y2;

    vertices[Batch.X3] = x2;
    vertices[Batch.Y3] = y2;

    vertices[Batch.X4] = x2;
    vertices[Batch.Y4] = y;

    if (_rotation != 0 || _scaleX != 1 || _scaleY != 1) 
      _dirty = true;
  }
  
  void setSize(double width, double height){
    this._width = width;
    this._height = height;
    
    if (_dirty) return;
    
    double x2 = _x + width;
    double y2 = _y + height;
    Float32List vertices = this._vertices;
    vertices[Batch.X1] = _x;
    vertices[Batch.Y1] = _y;

    vertices[Batch.X2] = _x;
    vertices[Batch.Y2] = y2;

    vertices[Batch.X3] = x2;
    vertices[Batch.Y3] = y2;

    vertices[Batch.X4] = x2;
    vertices[Batch.Y4] = _y;

    if (_rotation != 0 || _scaleX != 1 || _scaleY != 1) 
      _dirty = true;
  }
  
  /// Sets the position where the sprite will be drawn. If origin, rotation, or scale are changed, it is slightly more efficient
  /// to set the position after those operations. If both position and size are to be changed, it is better to use [setBounds]
  void setPosition(double x, double y) => translate(x - _x, y - _y);
  
  /// Sets the x position where the sprite will be drawn. If origin, rotation, or scale are changed, it is slightly more efficient
  /// to set the position after those operations. If both position and size are to be changed, it is better to use [setBounds]
  void set x(double val) => translateX( val - _x);  
  
  /// Sets the y position where the sprite will be drawn. If origin, rotation, or scale are changed, it is slightly more efficient
  /// to set the position after those operations. If both position and size are to be changed, it is better to use [setBounds]
  void set y(double val) => translateY( val - _y);
  
  /// Sets the x position so that it is centered on the given [x] parameter
  void set centerX(double x){ 
    this.x = x - _width / 2; 
  }
  
  /// Sets the y position so that it is centered on the given [y] parameter
  void set centerY(double y){
    this.y = y - _height / 2;
  }
  
  /// Sets the position so that the sprite is centered on (x, y) */
  void setCenter(double x, double y){
    centerX = x;
    centerY = y;
  }
  
  /// Sets the x position relative to the current position where the sprite will be drawn. If origin, rotation, or scale are
  /// changed, it is slightly more efficient to translate after those operations. */
  void translateX (double xAmount) {
    this._x += xAmount;

    if (_dirty) return;

    Float32List vertices = this._vertices;
    vertices[Batch.X1] += xAmount;
    vertices[Batch.X2] += xAmount;
    vertices[Batch.X3] += xAmount;
    vertices[Batch.X4] += xAmount;
  }

  /// Sets the y position relative to the current position where the sprite will be drawn. If origin, rotation, or scale are
  /// changed, it is slightly more efficient to translate after those operations
  void translateY (double yAmount) {
    _y += yAmount;

    if (_dirty) return;

    Float32List vertices = this._vertices;
    vertices[Batch.Y1] += yAmount;
    vertices[Batch.Y2] += yAmount;
    vertices[Batch.Y3] += yAmount;
    vertices[Batch.Y4] += yAmount;
  }

  /// Sets the position relative to the current position where the sprite will be drawn. If origin, rotation, or scale are
  /// changed, it is slightly more efficient to translate after those operations
  void translate (double xAmount, double yAmount) {
    _x += xAmount;
    _y += yAmount;

    if (_dirty) return;

    Float32List vertices = this._vertices;
    vertices[Batch.X1] += xAmount;
    vertices[Batch.Y1] += yAmount;

    vertices[Batch.X2] += xAmount;
    vertices[Batch.Y2] += yAmount;

    vertices[Batch.X3] += xAmount;
    vertices[Batch.Y3] += yAmount;

    vertices[Batch.X4] += xAmount;
    vertices[Batch.Y4] += yAmount;
  }
  
  /// Sets the origin in relation to the sprite's position for scaling and rotation
  void setOrigin (double originX, double originY) {
    this._originX = originX;
    this._originY = originY;
    _dirty = true;
  }
  
  /// Place origin in the center of the sprite
  void setOriginCenter() {
    this._originX = _width / 2;
    this._originY = _height / 2;
    _dirty = true;
  }
  
  /// The rotation of the sprite in degrees. Rotation is centered on the origin set by [setOrigin]
  void set rotation(double degrees){
    this._rotation = degrees;
    _dirty = true;
   
  }
  
  /// The rotation of the sprite in degrees. Rotation is centered on the origin set by [setOrigin]
  double get rotation => _rotation;
  
  /// Sets the sprite's rotation in degrees relative to the current rotation. Rotation is centered on the origin set in [setOrigin]
  void rotate(double degrees){
    if (degrees == 0.0)
      return;
    _rotation += degrees;
    _dirty = true;
  }
  
  /// Rotates this sprite 90 degrees in-place by rotating the texture coordinates. This rotation is unaffected by [rotation] and [rotate]
  void rotate90(bool clockwise) {
    Float32List vertices = this._vertices;

    if (clockwise) {
      double temp = vertices[Batch.V1];
      vertices[Batch.V1] = vertices[Batch.V4];
      vertices[Batch.V4] = vertices[Batch.V3];
      vertices[Batch.V3] = vertices[Batch.V2];
      vertices[Batch.V2] = temp;

      temp = vertices[Batch.U1];
      vertices[Batch.U1] = vertices[Batch.U4];
      vertices[Batch.U4] = vertices[Batch.U3];
      vertices[Batch.U3] = vertices[Batch.U2];
      vertices[Batch.U2] = temp;
    } else {
      double temp = vertices[Batch.V1];
      vertices[Batch.V1] = vertices[Batch.V2];
      vertices[Batch.V2] = vertices[Batch.V3];
      vertices[Batch.V3] = vertices[Batch.V4];
      vertices[Batch.V4] = temp;

      temp = vertices[Batch.U1];
      vertices[Batch.U1] = vertices[Batch.U2];
      vertices[Batch.U2] = vertices[Batch.U3];
      vertices[Batch.U3] = vertices[Batch.U4];
      vertices[Batch.U4] = temp;
    }
  }
  
  /// Sets the sprite's scale for both X and Y. If [scaley] is not provided, scale on both, X and Y, will be set to [scalex]  
  /// The sprite scales out from the origin. This will not affect the values returned by [width] and [height]
  void setScale(double scalex, [double scaley]){
    this._scaleX = scalex;
    this._scaleY = scaley == null ? scalex : scaley;
    _dirty = true; 
  }
  
  /// Sets the sprite's scale relative to the current scale. for example: original scale 2 -> sprite.scale(4) -> final scale 6.
  /// The sprite scales out from the origin. This will not affect the values returned by [width] and [height]
  void scale (double amount) {
    this._scaleX += amount;
    this._scaleY += amount;
    _dirty = true;
  }
  
  Float32List getVertices () {
    if (_dirty) {
      _dirty = false;

      Float32List vertices = this._vertices;
      double localX = - _originX;
      double localY = - _originY;
      double localX2 = localX + _width;
      double localY2 = localY + _height;
      double worldOriginX = this._x - localX;
      double worldOriginY = this._y - localY;
      if (_scaleX != 1 || _scaleY != 1) {
        localX *= _scaleX;
        localY *= _scaleY;
        localX2 *= _scaleX;
        localY2 *= _scaleY;
      }
      if (rotation != 0) {
//        final double cos = MathUtils.cosDeg(rotation );
//        final double sin = MathUtils.sinDeg(rotation);
        
        final double cosine = cos(rotation * MathUtils.degreesToRadians);
        final double sine = sin(rotation * MathUtils.degreesToRadians);
        final double localXCos = localX * cosine;
        final double localXSin = localX * sine;
        final double localYCos = localY * cosine;
        final double localYSin = localY * sine;
        final double localX2Cos = localX2 * cosine;
        final double localX2Sin = localX2 * sine;
        final double localY2Cos = localY2 * cosine;
        final double localY2Sin = localY2 * sine;

        final double x1 = localXCos - localYSin + worldOriginX;
        final double y1 = localYCos + localXSin + worldOriginY;
        vertices[Batch.X1] = x1;
        vertices[Batch.Y1] = y1;

        final double x2 = localXCos - localY2Sin + worldOriginX;
        final double y2 = localY2Cos + localXSin + worldOriginY;
        vertices[Batch.X2] = x2;
        vertices[Batch.Y2] = y2;

        final double x3 = localX2Cos - localY2Sin + worldOriginX;
        final double y3 = localY2Cos + localX2Sin + worldOriginY;
        vertices[Batch.X3] = x3;
        vertices[Batch.Y3] = y3;

        vertices[Batch.X4] = x1 + (x3 - x2);
        vertices[Batch.Y4] = y3 - (y2 - y1);
      } else {
        final double x1 = localX + worldOriginX;
        final double y1 = localY + worldOriginY;
        final double x2 = localX2 + worldOriginX;
        final double y2 = localY2 + worldOriginY;

        vertices[Batch.X1] = x1;
        vertices[Batch.Y1] = y1;

        vertices[Batch.X2] = x1;
        vertices[Batch.Y2] = y2;

        vertices[Batch.X3] = x2;
        vertices[Batch.Y3] = y2;

        vertices[Batch.X4] = x2;
        vertices[Batch.Y4] = y1;
      }
    }
    return this._vertices;
  }
  
  /// Returns the bounding axis aligned [Rect] that bounds this sprite. The rectangles x and y coordinates describe its
  /// bottom left corner. If you change the position or size of the sprite, you have to fetch the triangle again for it to be
  /// recomputed.
  Rect getBoundingRectangle () {
    Float32List vertices = getVertices();

    double minx = vertices[Batch.X1];
    double miny = vertices[Batch.Y1];
    double maxx = vertices[Batch.X1];
    double maxy = vertices[Batch.Y1];

    minx = minx > vertices[Batch.X2] ? vertices[Batch.X2] : minx;
    minx = minx > vertices[Batch.X3] ? vertices[Batch.X3] : minx;
    minx = minx > vertices[Batch.X4] ? vertices[Batch.X4] : minx;

    maxx = maxx < vertices[Batch.X2] ? vertices[Batch.X2] : maxx;
    maxx = maxx < vertices[Batch.X3] ? vertices[Batch.X3] : maxx;
    maxx = maxx < vertices[Batch.X4] ? vertices[Batch.X4] : maxx;

    miny = miny > vertices[Batch.Y2] ? vertices[Batch.Y2] : miny;
    miny = miny > vertices[Batch.Y3] ? vertices[Batch.Y3] : miny;
    miny = miny > vertices[Batch.Y4] ? vertices[Batch.Y4] : miny;

    maxy = maxy < vertices[Batch.Y2] ? vertices[Batch.Y2] : maxy;
    maxy = maxy < vertices[Batch.Y3] ? vertices[Batch.Y3] : maxy;
    maxy = maxy < vertices[Batch.Y4] ? vertices[Batch.Y4] : maxy;

    _bounds
     ..x = minx
     ..y = miny
     ..width = maxx - minx
     ..height = maxy - miny;
    
    return _bounds;
  }
  
  void draw (SpriteBatch batch, [double alphaModulation]) {
    if (alphaModulation == null){
      batch.drawVertices(texture, getVertices(), 0, SPRITE_SIZE); 
    }else{
      double oldAlpha = getColor().a;
      setAlpha(oldAlpha * alphaModulation);
      
      batch.drawVertices(texture, getVertices(), 0, SPRITE_SIZE);
      
      setAlpha(oldAlpha);
    }
  }
  
  /// Returns the color of this sprite. Changing the returned color will have no affect, [setColor] must be used
  Color getColor () {
    return color
        ..setDouble(_vertices[Batch.C1]);
  }
  
}