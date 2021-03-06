part of glib.graphics;


class SpriteBatch extends Batch implements Disposable{

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
   
  SpriteBatch ([int size = 1000, ShaderProgram defaultShader]) {
    
    // 32767 is max vertex index, so 32767 / 4 vertices per sprite = 8191 sprites max.
    if (size > 8191)
      throw new ArgumentError("Can't have more than 8191 sprites per batch: " + size);
    
    var attributes = new VertexAttributes([
       new VertexAttribute(Usage.Position, 2, ShaderProgram.POSITION_ATTRIBUTE), 
       new VertexAttribute.ColorPacked(), 
       new VertexAttribute.TexCoords(0)
     ]);
    
    _mesh = new Mesh(false, size * 4, size * 6, attributes);
    
    projection.setToOrtho2D(0.0, 0.0, _graphics.width.toDouble(),  _graphics.height.toDouble());

    _vertices = new Float32List(size * Sprite.VERTEX_SIZE);

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
    
    _graphics.gl.depthMask(false);
    
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

    _graphics.gl.depthMask(true);
    if (!isBlendingEnabled) 
      _graphics.gl.disable(GL.BLEND);

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

  /** Draws a rectangle with the bottom left corner at x,y and stretching the region to cover the given width and height. 
   * 
   * [originX] and [originY] are both default to 0.5 (center of the region)
   * 
   * The rectangle is offset by [originX], [originY] relative to the origin. 
   * 
   * Scale specifies the scaling factor by which the rectangle
	 * should be scaled around [originX], [originY]. 
   * 
   * [rotation] specifies the angle of rotation of the rectangle around [originX], [originY]
   * 
   * [clockwise] determines if the rotation should be done clockwise or counter-clockwise
   * */
  void drawRegionTransform(TextureRegion region, double x, double y, double width, double height, {double originX: 0.5, double originY: 0.5, 
    double scaleX: 1.0, double scaleY: 1.0, double rotation: 0.0, clockwise: false}) {
    if (!_drawing) 
      throw new StateError("SpriteBatch.begin must be called before drawTexture");

    var vertices = this._vertices;
    
    if (region.texture != _prevTexture)
      _changeTexture(region.texture);
    else if (_currentVertex == _vertices.length) //
      flush();
    
    // bottom left and top right corner points relative to origin
		final double worldOriginX = x + originX;
		final double worldOriginY = y + originY;
		double fx = -originX;
		double fy = -originY;
		double fx2 = width - originX;
		double fy2 = height - originY;

		// scale
		if (scaleX != 1 || scaleY != 1) {
			fx *= scaleX;
			fy *= scaleY;
			fx2 *= scaleX;
			fy2 *= scaleY;
		}

		// construct corner points, start from top left and go counter clockwise
		final double p1x = fx;
		final double p1y = fy;
		final double p2x = fx;
		final double p2y = fy2;
		final double p3x = fx2;
		final double p3y = fy2;
		final double p4x = fx2;
		final double p4y = fy;

		double x1;
		double y1;
		double x2;
		double y2;
		double x3;
		double y3;
		double x4;
		double y4;

		// rotate
		if (rotation != 0) {
			final double cos = MathUtils.cosDeg(rotation);
			final double sin = MathUtils.sinDeg(rotation);

			x1 = cos * p1x - sin * p1y;
			y1 = sin * p1x + cos * p1y;

			x2 = cos * p2x - sin * p2y;
			y2 = sin * p2x + cos * p2y;

			x3 = cos * p3x - sin * p3y;
			y3 = sin * p3x + cos * p3y;

			x4 = x1 + (x3 - x2);
			y4 = y3 - (y2 - y1);
		} else {
			x1 = p1x;
			y1 = p1y;

			x2 = p2x;
			y2 = p2y;

			x3 = p3x;
			y3 = p3y;

			x4 = p4x;
			y4 = p4y;
		}

		x1 += worldOriginX;
		y1 += worldOriginY;
		x2 += worldOriginX;
		y2 += worldOriginY;
		x3 += worldOriginX;
		y3 += worldOriginY;
		x4 += worldOriginX;
		y4 += worldOriginY;

		double u1, v1, u2, v2, u3, v3, u4, v4;
		if (clockwise) {
			u1 = region.u2;
			v1 = region.v2;
			u2 = region.u;
			v2 = region.v2;
			u3 = region.u;
			v3 = region.v;
			u4 = region.u2;
			v4 = region.v;
		} else {
			u1 = region.u;
			v1 = region.v;
			u2 = region.u2;
			v2 = region.v;
			u3 = region.u2;
			v3 = region.v2;
			u4 = region.u;
			v4 = region.v2;
		}

		double color = this.color;
		int idx = _currentVertex;
		vertices[idx] = x1;
		vertices[idx + 1] = y1;
		vertices[idx + 2] = color;
		vertices[idx + 3] = u1;
		vertices[idx + 4] = v1;

		vertices[idx + 5] = x2;
		vertices[idx + 6] = y2;
		vertices[idx + 7] = color;
		vertices[idx + 8] = u2;
		vertices[idx + 9] = v2;

		vertices[idx + 10] = x3;
		vertices[idx + 11] = y3;
		vertices[idx + 12] = color;
		vertices[idx + 13] = u3;
		vertices[idx + 14] = v3;

		vertices[idx + 15] = x4;
		vertices[idx + 16] = y4;
		vertices[idx + 17] = color;
		vertices[idx + 18] = u4;
		vertices[idx + 19] = v4;
		this._currentVertex = idx + 20;
    
  }
  
  void drawVertices(Texture texture, Float32List spriteVertices, int offset, int count) {
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

    _vertices.setRange(_currentVertex, _currentVertex + copyCount, spriteVertices, offset);
    _currentVertex += copyCount;
    count -= copyCount;
    
    while (count > 0) {
      offset += copyCount;
      flush();
      copyCount = Math.min(verticesLength, count);
      _vertices.setRange(_currentVertex, copyCount, spriteVertices, offset);
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
      _graphics.gl.enable(GL.BLEND);
      if (_blendSrcFunc != -1)
        _graphics.gl.blendFunc(_blendSrcFunc, _blendDstFunc);
    } else {
      _graphics.gl.disable(GL.BLEND);
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
    combined.setMatrix(projection).multiply(transform);
    currentShader.setUniformMatrix4fv('u_proj', combined);
    currentShader.setUniformi("u_texture", 0);
  }
  
  dispose(){
    _mesh.dispose();
    if(_ownsShader && _defaultShader != null)
      _defaultShader.dispose();
  }
  
}

class Batch{
  static const int X1 = 0;
  static const int Y1 = 1;
  static const int C1 = 2;
  static const int U1 = 3;
  static const int V1 = 4;
  static const int X2 = 5;
  static const int Y2 = 6;
  static const int C2 = 7;
  static const int U2 = 8;
  static const int V2 = 9;
  static const int X3 = 10;
  static const int Y3 = 11;
  static const int C3 = 12;
  static const int U3 = 13;
  static const int V3 = 14;
  static const int X4 = 15;
  static const int Y4 = 16;
  static const int C4 = 17;
  static const int U4 = 18;
  static const int V4 = 19;
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
    v_color.a = v_color.a * (255.0 / 254.0);
    v_texCoords = ${ShaderProgram.TEXCOORD_ATTRIBUTE}0;
    gl_Position = u_proj * ${ShaderProgram.POSITION_ATTRIBUTE};
  }
  """;

