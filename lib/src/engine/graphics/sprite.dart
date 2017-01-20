part of glib.graphics;

class Sprite extends TextureRegion{
  
  /** 
  * 5 vertices per sprite:
  * 2: position.xy
  * 1: packed color
  * 2: texcoord0.xy
  */
  static const int VERTEX_SIZE = 2 + 1 + 2;
  static const int SPRITE_SIZE = 4 * VERTEX_SIZE;

  final Float32List _vertices = new Float32List(SPRITE_SIZE);
  
  final Color _color = new Color();
  double _width = 0.0, _height = 0.0;
  double _x = 0.0, _y = 0.0;
  double _rotation = 0.0, _scaleX = 1.0, _scaleY = 1.0;
  double _originX = 0.0, _originY = 0.0;
  
  Rect _bounds = new Rect();
    
  bool _dirty = true; 
    
  /// Creates an uninitialized sprite. The sprite will need a texture region and bounds set before it can be drawn
  Sprite.empty(): super.empty();
  
 
  /// Creates a sprite with width, height, and texture region equal to the specified size.
  /// 
  /// [x] the X-axis coordinate matching the lower left corner of the region
  /// [y] the Y-axis coordinate matching the lower left corner of the region
  /// [srcWidth] The width of the texture region. May be negative to flip the sprite when drawn.
  /// [srcHeight] The height of the texture region. May be negative to flip the sprite when drawn. */
  Sprite(Texture texture, [int x = 0, int y = 0, int srcWidth, int srcHeight])
  : super(texture, x, y, srcWidth, srcHeight) {
    
    setColorValues(1.0, 1.0, 1.0, 1.0);
    
    if (texture.loaded){
      srcHeight = srcHeight == null ? texture.height : srcHeight;
      srcWidth = srcWidth == null ? texture.width : srcWidth;
      _init(srcWidth, srcHeight);
    }else{
      texture.onLoad.then((texture){
        srcHeight = srcHeight == null ? texture.height : srcHeight;
        srcWidth = srcWidth == null ? texture.width : srcWidth;
        _init(srcWidth, srcHeight);
      });
    } 
  }

    // Note the region is copied.
  /// Creates a sprite based on a specific TextureRegion, the new sprite's region is a copy of the parameter region, altering one does not affect the other
  Sprite.fromRegion(TextureRegion region)
  : super.copy(region) {
    setColorValues(1.0, 1.0, 1.0, 1.0);
    _init(region.regionWidth, region.regionHeight);
  }

  /// Creates a sprite that is a copy in every way of the specified sprite
  Sprite.copy(Sprite sprite): super.empty() {
    set(sprite);
  }
  
  _init(int width, int height){
    setSize(width.abs().toDouble(), height.abs().toDouble());
    setOrigin(_width / 2, _height / 2);
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
    _color.set(other._color);
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

    if (_rotation != 0.0 || _scaleX != 1.0 || _scaleY != 1.0) 
      _dirty = true;
  }
  
  double get width => _width;
  double get height => _height;
  
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
  /// changed, it is slightly more efficient to translate after those operations
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
  
  /// Sets the alpha portion of the color used to tint this sprite
  void setAlpha (double a) {
    int intBits = NumberUtils.floatToIntBits(_vertices[Batch.C1]);
    int alphaBits = 255 * a.toInt() << 24;

    // clear alpha on original color
    intBits = intBits & 0x00FFFFFF;
    // write new alpha
    intBits = intBits | alphaBits;
    double color = NumberUtils.intToFloatColor(intBits);
    _vertices[Batch.C1] = color;
    _vertices[Batch.C2] = color;
    _vertices[Batch.C3] = color;
    _vertices[Batch.C4] = color;
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
    if (scalex == null)
      throw new ArgumentError.notNull('scalex');
    
    scaley = scaley == null ? scalex : scaley;
    scaleX = scalex;
    scaleY = scaley;
  }
  
  double get scaleX => _scaleX;
  void set scaleX(double scalex){
    this._scaleX = scalex;
    _dirty = true;
  }
  
  double get scaleY => _scaleY;
  void set scaleY(double scaley){
    this._scaleY = scaley;
    _dirty = true;
  }
  
  
  /// Sets the sprite's scale relative to the current scale. for example: original scale 2 -> sprite.scale(4) -> final scale 6.
  /// The sprite scales out from the origin. This will not affect the values returned by [width] and [height]
  void scale (double amount) {
    this._scaleX += amount;
    this._scaleY += amount;
    _dirty = true;
  }
  
  /// Obtains the vertices which this sprite is composed off.
  /// 
  /// This getter performs some operations to obtain the vertices, so you should catch this result
  Float32List get vertices {
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
  /// 
  /// This getter performs some operations to obtain the rectangle, so you should catch this result
  Rect get boundingRectangle  {
    Float32List vertices = this.vertices;

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
      batch.drawVertices(texture, vertices, 0, SPRITE_SIZE); 
    }else{
      double oldAlpha = color.a;
      setAlpha(oldAlpha * alphaModulation);
      
      batch.drawVertices(texture, vertices, 0, SPRITE_SIZE);
      
      setAlpha(oldAlpha);
    }
  }
    
  /// Returns the color of this sprite. Changing the returned color will have no effect, you need to specifically assign it
  /// using the color setter or one of the methods: [setColorValues]
  Color get color => _color..setDouble(_vertices[Batch.C1]);
  
  /// Sets the color used to tint this sprite. [Color.WHITE].
  void set color (Color tint){
    double color = tint.toDouble();
    _vertices[Batch.C1] = color;
    _vertices[Batch.C2] = color;
    _vertices[Batch.C3] = color;
    _vertices[Batch.C4] = color;
  }
  
  /// Sets the color used to tint this sprite by assigning the [r] [g] [b] [a] channels. [Color.WHITE].
  void setColorValues(double r, double g, double b, double a){
//    int intBits = (255 * a.toInt()) << 24 | ((255 * b.toInt()) << 16) | ((int)(255 * g) << 8) | ((int)(255 * r));
    int intBits = Color._toInt(a) << 24 | Color._toInt(b) << 16 | Color._toInt(g) << 8 | Color._toInt(r);
    double color = NumberUtils.intToFloatColor(intBits);
    _vertices[Batch.C1] = color;
    _vertices[Batch.C2] = color;
    _vertices[Batch.C3] = color;
    _vertices[Batch.C4] = color;
  }
  
//  /// Sets the color used to tint this sprite, the passed [color] is assigned to all of the channels.
//  /// This means that setColorDouble(1.0) would give you white
//  void setColorDouble(double color){
//    var vertices = _vertices;
//    vertices[Batch.C1] = color;
//    vertices[Batch.C2] = color;
//    vertices[Batch.C3] = color;
//    vertices[Batch.C4] = color;
//  }
  
  @override
  void setUVs (double u, double v, double u2, double v2) {
    super.setUVs(u, v, u2, v2);

    Float32List vertices = _vertices;
    vertices[Batch.U1] = u;
    vertices[Batch.V1] = v2;

    vertices[Batch.U2] = u;
    vertices[Batch.V2] = v;

    vertices[Batch.U3] = u2;
    vertices[Batch.V3] = v;

    vertices[Batch.U4] = u2;
    vertices[Batch.V4] = v2;
  }
  
  @override
  void set u (double u) {
    super.u = u;
    _vertices[Batch.U1] = u;
    _vertices[Batch.U2] = u;
  }

  @override
  void set v (double v) {
    super.v  = v;
    _vertices[Batch.V2] = v;
    _vertices[Batch.V3] = v;
  }

  @override
  void set u2 (double u2) {
    super.u2 = u2;
    _vertices[Batch.U3] = u2;
    _vertices[Batch.U4] = u2;
  }

  @override
  void set v2 (double v2) {
    super.v2 = v2;
    _vertices[Batch.V1] = v2;
    _vertices[Batch.V4] = v2;
  }
  
  /// Set the sprite's flip state regardless of current condition
  /// [x] the desired horizontal flip state
  /// [y] the desired vertical flip state
  void setFlip (bool x, bool y) {
    bool performX = false;
    bool performY = false;
    if (isFlipX != x) {
      performX = true;
    }
    if (isFlipY != y) {
      performY = true;
    }
    flip(performX, performY);
  }
  
  @override
  /// bool parameters x,y are not setting a state, but performing a flip
  /// [onX] perform horizontal flip
  /// [onY] perform vertical flip */
  void flip (bool onX, bool onY) {
    super.flip(onX, onY);
    Float32List vertices = _vertices;
    if (onX) {
      double temp = vertices[Batch.U1];
      vertices[Batch.U1] = vertices[Batch.U3];
      vertices[Batch.U3] = temp;
      temp = vertices[Batch.U2];
      vertices[Batch.U2] = vertices[Batch.U4];
      vertices[Batch.U4] = temp;
    }
    if (onY) {
      double temp = vertices[Batch.V1];
      vertices[Batch.V1] = vertices[Batch.V3];
      vertices[Batch.V3] = temp;
      temp = vertices[Batch.V2];
      vertices[Batch.V2] = vertices[Batch.V4];
      vertices[Batch.V4] = temp;
    }
  }
  
  void scroll (double xAmount, double yAmount) {
    Float32List vertices = _vertices;
    if (xAmount != 0) {
      double u = (vertices[Batch.U1] + xAmount) % 1;
      double u2 = u + _width / texture.width;
      this.u = u;
      this.u2 = u2;
      vertices[Batch.U1] = u;
      vertices[Batch.U2] = u;
      vertices[Batch.U3] = u2;
      vertices[Batch.U4] = u2;
    }
    if (yAmount != 0) {
      double v = (vertices[Batch.V2] + yAmount) % 1;
      double v2 = v + _height / texture.height;
      this.v = v;
      this.v2 = v2;
      vertices[Batch.V1] = v2;
      vertices[Batch.V2] = v;
      vertices[Batch.V3] = v;
      vertices[Batch.V4] = v2;
    }
  }
}