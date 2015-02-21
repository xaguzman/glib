part of glib.graphics;

///A rectangular subregion or area of a texture. The coordinate system has 0, 0 at the top left corner
class TextureRegion{
  Texture texture;
  double _u, _v, _u2, _v2;
  int _regionWidth, _regionHeight;
  
  TextureRegion.empty(){
    _regionWidth = _regionHeight = 0;
    _u = _v = _u2 = _v2 = 0.0;
  }
  
  /** 
   * Creates a new subregion out of the passed [texture]
   * 
   * [texture] is the [Texture] the data will be taken from when drawing
   * [x] the left side of the area we want to substract, if ommited it's set to 0
   * [y] the top side of the area we want to substract, if ommited it's set to 0
   * [width] if ommited, it will be set to the [texture]'s width
   * [height] if ommited, it will be set to the [texture]'s height
   */ 
  TextureRegion(this.texture, [int x = 0, int y = 0 , int width, int height]){   
    if(texture == null)
      throw new ArgumentError.notNull("texture");
    
    if (texture.loaded){
      if ( height == null)
        height = texture.height;
      if (width == null)
        width = texture.width;
          
      setRegion(x, y, width, height);
    }else{
      setRegion(0, 0, 1, 1);
      texture.onLoad.then((texture){
        if ( height == null)
          height = texture.height;
        if (width == null)
          width = texture.width;
        setRegion(x, y, width, height);
      });
    }
  }
  
  TextureRegion.copy(TextureRegion other){
    texture = other.texture;
    setUVs(other.u, other.v, other.u2, other.v2);
  }
  
  void setRegion(num x, num y, num width, num height){
    num invTexWidth = 1.0 / texture.width;
    num invTexHeight = 1.0 / texture.height;
    setUVs(x * invTexWidth, y * invTexHeight, (x + width) * invTexWidth, (y + height) * invTexHeight);
    _regionWidth = width.abs();
    _regionHeight = height.abs();
  }
  
  void setUVs(double u1, double v1, double u2, double v2){
    int texWidth = texture.width, texHeight = texture.height;
    
    _regionWidth = ((u2 - u1).abs() * texWidth).round();
    _regionHeight = ((v2 - v1).abs() * texHeight).round();

    // For a 1x1 region, adjust UVs toward pixel center to avoid filtering artifacts on AMD GPUs when drawing very stretched.
    if (_regionWidth == 1 && _regionHeight == 1) {
      num adjustX = 0.25 / texWidth;
      u1 += adjustX;
      u2 -= adjustX;
      num adjustY = 0.25 / texHeight;
      v1 += adjustY;
      v2 -= adjustY;
    }

    _u = u1;
    _v = v1;
    _u2 = u2;
    _v2 = v2;
  }
  
  double get u => _u;
  void set u(double u){
    _u = u;
    _regionWidth = ((_u2 - _u).abs() * texture.width).round();
  }
  
  double get v => _v;
  void set v(double v){
    _v = v;
    _regionHeight = ((_v2 - _v).abs() * texture.height).round();
  }
  
  double get u2 => _u2;
  void set u2(double u2){
    _u2 = u2;
    _regionWidth = ((_u2 - _u).abs() * texture.width).round();
  }
  
  double get v2 => _v2;
  void set v2 (double v2) {
    _v2 = v2;
    _regionHeight = ((_v2 - _v).abs() * texture.height).round();
  }
  
  int get regionX => (_u * texture.width).round();
  void set regionX(int x) {
    u = x / texture.width;
  }
  
  int get regionY => (_v * texture.height).round();
  void set regionY(int y){
    v = y / texture.height;
  }
  
  int get regionWidth => _regionWidth;
  void set regionWidth(int width){
    u2 = _u + width / texture.width;
  }
  
  int get regionHeight => _regionHeight;
  void set regionHeight(int height){
    v2 = _u + height / texture.height;
  }
  
  void flip(bool x, bool y){
    if (x) {
      num temp = u;
      u = u2;
      u2 = temp;
    }
    if (y) {
      num temp = v;
      v = v2;
      v2 = temp;
    }
  }
  
  bool get isFlipX => _u > _u2;
  bool get isFlipY => _v > _v2;
  
  List<List<TextureRegion>> split(int tileWidth, int tileHeight){
    int x = regionX;
    int y = regionY;
    int width = regionWidth;
    int height = regionHeight;

    int rows = _regionHeight ~/ tileHeight;
    int cols = _regionWidth ~/ tileWidth;

    int startX = x;
    List<List<TextureRegion>> tiles = new List.generate(rows, (_) => new List(cols));
    for (int row = 0; row < rows; row++, y += tileHeight) {
      x = startX;
      for (int col = 0; col < cols; col++, x += tileWidth) {
        tiles[row][col] = new TextureRegion(texture, x, y, tileWidth, tileHeight);
      }
    }

    return tiles;
  }
  
  static List<List<TextureRegion>> splitted(Texture texture, int tileWidth, int tileHeight){
    var region = new TextureRegion(texture);
    return region.split(tileWidth, tileHeight);
  }
}