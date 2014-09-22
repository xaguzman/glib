part of glib.graphics;


class SpriteBatch implements Disposable{

  bool isBlendingEnabled = true;
  final Matrix4 transform = new Matrix4.identity();
  final Matrix4 projection = new Matrix4.identity();
  final Matrix4 combined = new Matrix4.identity();
  
  Mesh _mesh;
  Float32List _vertices;
  int _currentVertex = 0;
  ShaderProgram _defaultShader, _customShader;
  bool _ownsShader = false;
  bool _drawing = false;
  
  Texture _prevTexture;
  num _invTexWidth, _invTexHeight;
  
  double _colorDouble = Color.WHITE.toDouble();
  Color _color = new Color(1.0, 1.0, 1.0, 1.0);
  int _totalRenderCalls = 0;
  int _textureSwaps, _batchRenderCalls;
  
  int _blendSrcFunc = GL.SRC_ALPHA;
  int _blendDstFunc = GL.ONE_MINUS_SRC_ALPHA;
  
 
  
  /** 
   * 5 vertices per sprite:
   * 2: position.xy
   * 1: packed color
   * 2: texcoord0.xy
   */
  static const int _vertexPerSprite = 5;
  
  
  SpriteBatch ([int size = 500, ShaderProgram defaultShader]) {
    
    // 65535 is max index, so 65535 / 6 = 10922.
    if (size > 10922)
      throw new ArgumentError("Can't have more than 10922 sprites per batch: $size");
    
    var attributes = new VertexAttributes([
       new VertexAttribute(Usage.Position, 2, ShaderProgram.POSITION_ATTRIBUTE), 
       new VertexAttribute.ColorPacked(), 
       new VertexAttribute.TexCoords(0)
     ]);
    
    _mesh = new Mesh(false, size * 4, size * 6, attributes);
    setOrthographicMatrix(projection, 0.0, _width.toDouble(), 0.0, _height.toDouble(), 0.0, 1.0);
//    projection.setToOrtho2D(0.0, _width.toDouble(), 0.0, _height.toDouble());

    _vertices = new Float32List(size * _vertexPerSprite);

    int len = size * 6;
    Int16List indices = new Int16List(len);
    for (int i = 0, j = 0; i < len; i += 6, j += 4) {
      indices[i] = j;
      indices[i + 1] = (j + 1);
      indices[i + 2] = (j + 2);
      indices[i + 3] = (j + 2);
      indices[i + 4] = (j + 3);
      indices[i + 5] = j;
    }
    _mesh.setIndices(indices);

    if (defaultShader == null) {
      _defaultShader = createDefaultShader();
      _ownsShader = true;
    } else
      _defaultShader = defaultShader;
  }
  
  static ShaderProgram createDefaultShader () {
      ShaderProgram shader = new ShaderProgram(_defaultVertexShader, _defaultFragShader);
      if (shader.isCompiled == false) 
        throw new ArgumentError("Error compiling shader: ${shader.log}");
      return shader;
  }
  
  Color get color => _color..setDouble(_colorDouble);
  void set color(Color color){
    _color.set(color);
    _colorDouble = _color.toDouble();
  }
  
  void begin(){
    if (_drawing) 
      throw new StateError('Spritebatch.end() should be called before calling Spritebatch.begin() a second time');
    
    _gl.depthMask(false);
    
    var currentShader = (_customShader == null ? _defaultShader: _customShader)
        ..begin();
    _setupMatrices(currentShader);
    
    _drawing = true;
    _textureSwaps = 0;
    _batchRenderCalls = 0;
  }
  
  void end(){
    if (!_drawing) 
      throw new StateError("SpriteBatch.begin must be called before end.");
    
    if (_currentVertex > 0) 
      flush();
    _prevTexture = null;
    _drawing = false;

    _gl.depthMask(true);
    if (!isBlendingEnabled) 
      _gl.disable(GL.BLEND);

    var currentShader = _customShader == null ? _defaultShader: _customShader;
    currentShader.end();
        
//    print('Total Render calls: ${_totalRenderCalls} ');
//    print('Render calls: $_batchRenderCalls');
//    print('Texture swaps: $_textureSwaps');
  }
  
  
  void drawTexture(Texture texture, double x, double y, [double width, double height, double u1 = 0.0, double v1 = 1.0, double u2 = 1.0, double v2 = 0.0]) {
    if (!_drawing) 
      throw new StateError("SpriteBatch.begin must be called before drawTexture");

    if (texture != _prevTexture)
      _changeTexture(texture);
    else if (_currentVertex == _vertices.length) //
      flush();
    
    if (width == null)
      width = texture.width.toDouble();
    if (height == null)
      height = texture.height.toDouble();

    final num x2 = x + width;
    final num y2 = y + height;
    
    num color = _colorDouble;
    _vertices[_currentVertex++] = x;
    _vertices[_currentVertex++] = y;
    _vertices[_currentVertex++] = color;
    _vertices[_currentVertex++] = u1;
    _vertices[_currentVertex++] = v1;

    _vertices[_currentVertex++] = x;
    _vertices[_currentVertex++] = y2;
    _vertices[_currentVertex++] = color;
    _vertices[_currentVertex++] = u1;
    _vertices[_currentVertex++] = v2;

    _vertices[_currentVertex++] = x2;
    _vertices[_currentVertex++] = y2;
    _vertices[_currentVertex++] = color;
    _vertices[_currentVertex++] = u2;
    _vertices[_currentVertex++] = v2;

    _vertices[_currentVertex++] = x2;
    _vertices[_currentVertex++] = y;
    _vertices[_currentVertex++] = color;
    _vertices[_currentVertex++] = u2;
    _vertices[_currentVertex++] = v1;
    
    _batchRenderCalls++;
      
  }
  
  void drawRegion(TextureRegion region, double x, double y, [double width, double height]){
    if(width == null)
      width = region.regionWidth.toDouble();
    
    if(height == null)
      height = region.regionHeight.toDouble();
    
    drawTexture(region.texture, x, y, width, height, region.u, region.v2, region.u2, region.v);
  }
  
  void drawVertices(Texture texture, Float32List vertices, int offset, int count) {
    if (!_drawing) 
      throw new StateError("SpriteBatch.begin must be called before draw.");

    int verticesLength = _vertices.length;
    int remainingVertices = verticesLength;
    if (texture != _prevTexture)
      _changeTexture(texture);
    else {
      remainingVertices -= _currentVertex;
      if (remainingVertices == 0) {
        flush();
        remainingVertices = verticesLength;
      }
    }
    int copyCount = Math.min(remainingVertices, count);

    _vertices.setRange(_currentVertex, _currentVertex + copyCount, vertices, offset + 1);
    
    _currentVertex += copyCount;
    count -= copyCount;
    while (count > 0) {
      offset += copyCount;
      flush();
      copyCount = Math.min(verticesLength, count);
      _vertices.setRange(0, copyCount, vertices, offset + 1);
      _currentVertex += copyCount;
      count -= copyCount;
    }
  }
 
  
  void flush(){
    if (_currentVertex == 0) return;

    int spritesInBatch = _currentVertex ~/ 20;
    int count = spritesInBatch * 6;

    _prevTexture.bind();
    _mesh.setVertices(_vertices, 0, _currentVertex);

    if (isBlendingEnabled) {
      _gl.enable(GL.BLEND);
      if (_blendSrcFunc != -1)
        _gl.blendFunc(_blendSrcFunc, _blendDstFunc);
    } else {
      _gl.disable(GL.BLEND);
    }

    _mesh.render(_customShader != null ? _customShader : _defaultShader, GL.TRIANGLES, 0, count);

    _currentVertex = 0;
    _totalRenderCalls++;
  }
  
  void _changeTexture(Texture texture){
    flush();
    _prevTexture = texture;
    _invTexWidth = 1 / texture.width;
    _invTexHeight = 1 / texture.height;
    _textureSwaps++;
  }
  
  void set shader(ShaderProgram newShader){
    if (_drawing) {
      flush();
      var currentShader = (_customShader == null ? _defaultShader: _customShader);
      currentShader.end();
    }
    _customShader = newShader;
    if (_drawing) {
      var currentShader = (_customShader == null ? _defaultShader: _customShader);
      currentShader.begin();
      _setupMatrices(currentShader);
    }
  }
  
  void _setupMatrices(ShaderProgram currentShader){
    combined.setFrom(projection).multiply(transform);
    currentShader.setUniformMatrix4fv('u_proj', combined);
    currentShader.setUniformi("u_texture", 0);
  }
  
  dispose(){
    _mesh.dispose();
    if(_ownsShader && _defaultShader != null)
      _defaultShader.dispose();
      
  }
  
}









  final String _defaultFragShader = 
  """
  precision mediump float;
  varying vec2 v_texCoords;
  varying vec4 v_color;
  uniform sampler2D u_texture;
  
  void main(void){
    gl_FragColor = v_color * texture2D(u_texture, v_texCoords);
  }
  """;

  final String _defaultVertexShader = 
  """
  attribute vec4 ${ShaderProgram.POSITION_ATTRIBUTE};
  attribute vec2 ${ShaderProgram.TEXCOORD_ATTRIBUTE}0;
  attribute vec4 ${ShaderProgram.COLOR_ATTRIBUTE};
  
  uniform mat4 u_proj;
  varying vec2 v_texCoords;
  varying vec4 v_color;
  
  void main(){
    v_color = ${ShaderProgram.COLOR_ATTRIBUTE};
    v_color.a = v_color.a * (256.0 / 255.0);
    v_texCoords = ${ShaderProgram.TEXCOORD_ATTRIBUTE}0;
    gl_Position = u_proj * ${ShaderProgram.POSITION_ATTRIBUTE};
  }
  """;

