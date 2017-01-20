part of glib.graphics;

class SpriteCache implements Disposable{
  final Float32List _tempVertices = new Float32List(Sprite.VERTEX_SIZE * 6);

	Mesh mesh;
	bool _drawing;
	final Matrix4 _transformMatrix = new Matrix4();
	final Matrix4 _projectionMatrix = new Matrix4();
  List<_Cache> _caches = new List();

  Matrix4 get projection => _projectionMatrix;

	final Matrix4 _combinedMatrix = new Matrix4();
	final ShaderProgram _shader;

	_Cache _currentCache;
	final List<Texture> _textures = new List(8);
  final List<int> _counts = new List(8);

	double _colorDouble = Color.WHITE.toDouble();
  Color _color = new Color(1.0, 1.0, 1.0, 1.0);

	ShaderProgram _customShader = null;

	/** Number of render calls since the last {@link #begin()}. **/
	int renderCalls = 0;

	/** Number of rendering calls, ever. Will not be reset unless set manually. **/
	int totalRenderCalls = 0;

  SpriteCache ({ int size: 1000, SpriteBatch shader, bool useIndices: false}) {
    _shader = shader != null ? shader : SpriteBatch.createDefaultShader();
		if (useIndices && size > 8191) 
      throw new ArgumentError("Can't have more than 8191 sprites per batch: " + size);

    var attributes = new VertexAttributes([
       new VertexAttribute(Usage.Position, 2,ShaderProgram.POSITION_ATTRIBUTE), 
       new VertexAttribute(Usage.ColorPacked, 4, ShaderProgram.COLOR_ATTRIBUTE),
       new VertexAttribute(Usage.TextureCoordinates, 2, ShaderProgram.TEXCOORD_ATTRIBUTE + "0")
     ]);

		mesh = new Mesh(true, size * (useIndices ? 4 : 6), useIndices ? size * 6 : 0, attributes);
		mesh.autoBind = false;

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
    mesh.setIndices(indices);

		_projectionMatrix.setToOrtho2D(0.0, 0.0, _graphics.width, _graphics.height);
	}

  Color get color => _color..setDouble(_colorDouble);
  void set color(Color color){
    _color.set(color);
    _colorDouble = _color.toDouble();
  }



  // /** Starts the redefinition of an existing cache, allowing the [add] and [endCache] methods to be called. If this is not
	//  * the last cache created, it cannot have more entries added to it than when it was first created. To do that, use
	//  * [clear] and then [begin].
  //  * */
	// void beginCache (int cacheID) {
	// 	if (_currentCache != null) 
  //     throw new StateError("endCache must be called before begin.");
		
  //   if (cacheID == _caches.length - 1) {
	// 		Cache oldCache = _caches.removeAt(cacheID);
	// 		// mesh.getVerticesBuffer().limit(oldCache.offset);
	// 		beginCache();
	// 		return;
	// 	}
  //   _currentCache = _caches[cacheID];
	// 	// mesh.getVerticesBuffer().position(currentCache.offset);
	// }

  /// Starts the definition of a new cache, allowing the add and [endCache] methods to be called.
	void beginCache () {
		if (_currentCache != null) 
      throw new StateError("endCache must be called before begin.");
		int verticesPerImage = mesh.getNumIndices() > 0 ? 4 : 6;
    _currentCache = new _Cache(_caches.length, mesh.getVerticesBuffer().offsetInBytes / 4);
    
		_caches.add(_currentCache);
		// mesh.getVerticesBuffer().compact();
	}

  /// Prepares the OpenGL state for SpriteCache rendering.
	void begin () {
		if (_drawing) 
      throw new StateError("end must be called before begin.");
		renderCalls = 0;
		_combinedMatrix.setMatrix(_projectionMatrix).multiply(_transformMatrix);

    _graphics.gl.depthMask(false);

		if (_customShader != null) {
			_customShader.begin();
			_customShader.setUniformMatrix4fv("u_proj", _projectionMatrix);
			_customShader.setUniformMatrix4fv("u_trans", _transformMatrix);
			_customShader.setUniformMatrix4fv("u_projTrans", _combinedMatrix);
			_customShader.setUniformi("u_texture", 0);
			mesh.bind(_customShader);
		} else {
			_shader.begin();
			_shader.setUniformMatrix4fv("u_projectionViewMatrix", _combinedMatrix);
			_shader.setUniformi("u_texture", 0);
			mesh.bind(_shader);
		}
		_drawing = true;
	}

  /** Draws all the images defined for the specified cache ID. */
	void draw (int cacheID, [int offset, int length]) {
		if (!_drawing) 
      throw new StateError("SpriteCache.begin must be called before draw.");

    if (offset != null && length != null){
      _Cache cache = _caches[cacheID];
      offset = offset * 6 + cache.offset;
      length *= 6;
      List<Texture> textures = cache.textures;
      List<int> counts = cache.counts;
      int textureCount = cache.textureCount;
      for (int i = 0; i < textureCount; i++) {
        textures[i].bind();
        int count = counts[i];
        if (count > length) {
          i = textureCount;
          count = length;
        } else
          length -= count;
        if (_customShader != null)
          mesh.render(_customShader, GL.TRIANGLES, offset, count);
        else
          mesh.render(_shader, GL.TRIANGLES, offset, count);
        offset += count;
		  }
      renderCalls += cache.textureCount;
      totalRenderCalls += textureCount;
    }else{
      _Cache cache = _caches[cacheID];
      int verticesPerImage = mesh.getNumIndices() > 0 ? 4 : 6;
      int offset = cache.offset / (verticesPerImage * Sprite.VERTEX_SIZE) * 6;
      List<Texture> textures = cache.textures;
      List<int> counts = cache.counts;
      int textureCount = cache.textureCount;
      for (int i = 0; i < textureCount; i++) {
        int count = counts[i];
        textures[i].bind();
        if (_customShader != null)
          mesh.render(_customShader, GL.TRIANGLES, offset, count);
        else
          mesh.render(_shader, GL.TRIANGLES, offset, count);
        offset += count;
      }
      renderCalls += textureCount;
      totalRenderCalls += textureCount;
    }
		
	}

  /// Completes rendering for this SpriteCache.
	void end () {
		if (!_drawing) 
      throw new StateError("begin must be called before end.");
		
    _drawing = false;

		_shader.end();
		GL gl = _graphics.gl;
		gl.depthMask(true);
		if (_customShader != null)
			mesh.unbind(_customShader);
		else
			mesh.unbind(_shader);
	}

  /// Ends the definition of a cache, returning the cache ID to be used with [draw].
	int endCache () {
		if (_currentCache == null) 
      throw new StateError("beginCache must be called before endCache.");
		_Cache cache = _currentCache;
		
    // int cacheCount = mesh.getVerticesBuffer().position() - cache.offset;
    int cacheCount = mesh.getVerticesBuffer().length;
		if (cache.textures == null) {
			// New cache.
			cache.maxCount = cacheCount;
			cache.textureCount = _textures.length;
			cache.textures = _textures;
      cache.counts = new List(cache.textureCount);
			for (int i = 0, n = _counts.length; i < n; i++)
        cache.counts[i] = _counts[i];

			// mesh.getVerticesBuffer().flip();
		} else {
			// Redefine existing cache.
			if (cacheCount > cache.maxCount) {
				throw new GlibException(
					"If a cache is not the last created, it cannot be redefined with more entries than when it was first created: $cacheCount ( ${cache.maxCount} max)");
			}

			cache.textureCount = _textures.length;

      if (cache.textures.length < cache.textureCount) 
        cache.textures = new List(cache.textureCount);
			for (int i = 0, n = cache.textureCount; i < n; i++)
        cache.textures[i] = _textures[i];

			if (cache.counts.length < cache.textureCount) 
        cache.counts = new List(cache.textureCount);
			for (int i = 0, n = cache.textureCount; i < n; i++)
        cache.counts[i] = _counts[i];

			// Float32List vertices = mesh.getVerticesBuffer();
			// vertices.position(0);
			// _Cache lastCache = _caches.last;
			// vertices.limit(lastCache.offset + lastCache.maxCount);
		}

		_currentCache = null;
		_textures.clear();
		_counts.clear();

		return cache.id;
	}

  /// Adds the specified sprite to the cache.
	void addSprite (Sprite sprite) {
		if (mesh.getNumIndices() > 0) {
			addTextureVertices(sprite.texture, sprite.vertices, 0.0, Sprite.SPRITE_SIZE);
			return;
		}

		Float32List spriteVertices = sprite.vertices;

    _tempVertices.setRange(0, 3 * Sprite.VERTEX_SIZE, spriteVertices);
    _tempVertices.setRange(3 * Sprite.VERTEX_SIZE, (3 * Sprite.VERTEX_SIZE) + Sprite.VERTEX_SIZE, spriteVertices, 2 * Sprite.VERTEX_SIZE);
    _tempVertices.setRange(4 * Sprite.VERTEX_SIZE, (4 * Sprite.VERTEX_SIZE) + Sprite.VERTEX_SIZE, spriteVertices, 3 * Sprite.VERTEX_SIZE);
    _tempVertices.setRange(5 * Sprite.VERTEX_SIZE, (5 * Sprite.VERTEX_SIZE) + Sprite.VERTEX_SIZE, spriteVertices, 0);
    addTextureVertices(sprite.texture, _tempVertices, 0, 30);

		// System.arraycopy(spriteVertices, 0, _tempVertices, 0, 3 * Sprite.VERTEX_SIZE); // temp0,1,2=sprite0,1,2
		// System.arraycopy(spriteVertices, 2 * Sprite.VERTEX_SIZE, _tempVertices, 3 * Sprite.VERTEX_SIZE, Sprite.VERTEX_SIZE); // temp3=sprite2
		// System.arraycopy(spriteVertices, 3 * Sprite.VERTEX_SIZE, _tempVertices, 4 * Sprite.VERTEX_SIZE, Sprite.VERTEX_SIZE); // temp4=sprite3
		// System.arraycopy(spriteVertices, 0, _tempVertices, 5 * Sprite.VERTEX_SIZE, Sprite.VERTEX_SIZE); // temp5=sprite0
		// addTextureVertices(sprite.texture, _tempVertices, 0, 30);
	}

  /// Adds the specified region to the cache
	void addRegion (TextureRegion region, double x, double y, double width, double height) {
		final double fx2 = x + width;
		final double fy2 = y + height;
		final double u = region.u;
		final double v = region.v2;
		final double u2 = region.u2;
		final double v2 = region.v;

		_tempVertices[0] = x;
		_tempVertices[1] = y;
		_tempVertices[2] = color;
		_tempVertices[3] = u;
		_tempVertices[4] = v;

		_tempVertices[5] = x;
		_tempVertices[6] = fy2;
		_tempVertices[7] = color;
		_tempVertices[8] = u;
		_tempVertices[9] = v2;

		_tempVertices[10] = fx2;
		_tempVertices[11] = fy2;
		_tempVertices[12] = color;
		_tempVertices[13] = u2;
		_tempVertices[14] = v2;

		if (mesh.getNumIndices() > 0) {
			_tempVertices[15] = fx2;
			_tempVertices[16] = y;
			_tempVertices[17] = color;
			_tempVertices[18] = u2;
			_tempVertices[19] = v;
			addTextureVertices(region.texture, _tempVertices, 0, 20);
		} else {
			_tempVertices[15] = fx2;
			_tempVertices[16] = fy2;
			_tempVertices[17] = color;
			_tempVertices[18] = u2;
			_tempVertices[19] = v2;

			_tempVertices[20] = fx2;
			_tempVertices[21] = y;
			_tempVertices[22] = color;
			_tempVertices[23] = u2;
			_tempVertices[24] = v;

			_tempVertices[25] = x;
			_tempVertices[26] = y;
			_tempVertices[27] = color;
			_tempVertices[28] = u;
			_tempVertices[29] = v;
			addTextureVertices(region.texture, _tempVertices, 0, 30);
		}
	}

  /** Adds the specified vertices to the cache. Each vertex should have 5 elements, one for each of the attributes: x, y, color,
	 * u, and v. If indexed geometry is used, each image should be specified as 4 vertices, otherwise each image should be
	 * specified as 6 vertices. */
	void addTextureVertices (Texture texture, Float32List vertices, int offset, int length) {
		if (_currentCache == null) throw new StateError("beginCache must be called before add.");

		int verticesPerImage = mesh.getNumIndices() > 0 ? 4 : 6;
		int count = length / (verticesPerImage * Sprite.VERTEX_SIZE) * 6;
		int lastIndex = _textures.length - 1;
		if (lastIndex < 0 || _textures[lastIndex] != texture) {
			_textures.add(texture);
			_counts.add(count);
		} else
      _counts[lastIndex] += count;

    mesh.getVerticesBuffer().setRange(lastIndex, lastIndex + count, vertices, offset);
	}
}

class _Cache {
		final int id;
		final int offset;
		int maxCount;
		int textureCount;
    List<Texture> textures;
    List<int> counts;

		_Cache(this.id, this.offset);
	}

