part of glib.graphics;

class Texture implements Disposable{
  static int _texturesCount = 0;

  String path;

  int get id => _id;
  int _id;

  /// The target of this texture, used when binding the texture, e.g. TEXTURE_2D
  final int glTarget;
  GLTexture glTexture;

  TextureFilter minFilter = TextureFilter.Nearest;
  TextureFilter magFilter = TextureFilter.Nearest;
  TextureWrap uWrap = TextureWrap.ClampToEdge;
  TextureWrap vWrap = TextureWrap.ClampToEdge;

  /// width of the texture in pixels
  int width;

  /// height of the texture in pixels
  int height;

//  /// depth of the texture in pixels
//  int get depth;

  /// return whether this texture is managed or not.
//  bool get isManaged;
    
  /// wether this texture is ready to be rendered. Usually, you should only see this as false when the constructor
  /// [Texture.from] is used, and the image hasn't been totally downloaded from the remote server
  bool loaded = true;

  Completer<Texture> loadCompleter = new Completer();
  Future<Texture> get onLoad => loadCompleter.future;

  /// Generates a new webgl texture with the specified target. */
  Texture([this.glTarget = GL.TEXTURE_2D, this.glTexture = null]){
    if( glTexture == null )
      glTexture = _graphics.gl.createTexture();
    _assignId();
  }

  ///creates a GL texture of the specified size. 
  factory Texture.size(int width, int height)
  {
    Texture texture = new Texture(GL.TEXTURE_2D);
    texture
      ..width = width
      ..height = height;
    return texture;
  }

  /// creates a texture from an image stored in the given path (string) or a fileHandle
  factory Texture.from(path_OR_fileHandle){
    // Texture texture = new Texture(GL.TEXTURE_2D);

    // if (path_OR_fileHandle is FileHandle){
    //   path_OR_fileHandle = path_OR_fileHandle.path;
    // }

    // texture
    //   ..path = path_OR_fileHandle
    //   ..loaded = false;

    return _graphics.uploadTexture( _files.load(path_OR_fileHandle));
  }

  /// creates a texture from an image stored in the given path (string) or a fileHandle
  // external Texture.from(path_OR_fileHandle);

  
  Texture.copy(Texture other) : this(other.glTarget, other.glTexture);
  
  _assignId(){
    _id = Texture._texturesCount++;
    _graphics.textures[_id] = this;
  }

  void uploadData(int width, int height,{int level:0, int format:GL.RGBA, int type:GL.UNSIGNED_BYTE, bool genMipMaps:false, data:null}){
    if (width == null)
      width = 0;
    if (height == null)
      height = 0;
    
    this.width = width;
    this.height = height;
    
    bind();
    _graphics.gl.texImage2DTyped(glTarget, level, format, width, height, 0, format, type, data);
    if (genMipMaps)
      _graphics.gl.generateMipmap(glTarget);
  }

  /// Disposes all resources associated with this texture. it will be immediatly removed from [Graphics.textures]
  void dispose () {
    _dispose();
    _graphics.textures.remove(id);
  }
  
  ///internal disposal used by [Graphics.disposeGraphics]
  void _dispose(){
    if (glTexture == null)
      return;

    _graphics.gl.deleteTexture(glTexture);
    glTexture = null;
  }

  /**
   * Binds the texture to the given texture unit. Sets the currently active texture unit via WebGL's activeTexture(Texture)
   * [unit] - 0 to MAX_TEXTURE_UNIT
   */
  void bind ([int unit = null]) {
    if ( unit != null )
      _graphics.gl.activeTexture(GL.TEXTURE0 + unit);
    _graphics.gl.bindTexture(glTarget, glTexture);
  }

  /** Sets the {@link TextureWrap} for this texture on the u and v axis. This will bind this texture!
   * [u] the u wrap
   * [v] the v wrap
   * [bind] wether to bind the texture before setting the wraps, set it to false if texture is already bound
   * [force] true to always set the values, even if they are the same as the current ones
   */
  void setWrap (TextureWrap u, TextureWrap v, {bool bind:false, bool force: false}) {
    bool updateU = false, updateV = false;
    if (force || uWrap != u)
      updateU = true;

    if (force || vWrap != v)
      updateV = true;

    if ( updateV && updateU == false )
      return;

    if (bind)
      this.bind();

    if(updateU){
      uWrap = u;
      _graphics.gl.texParameterf(glTarget, GL.TEXTURE_WRAP_S, u.glEnum);
    }
    if (updateV){
      vWrap = v;
      _graphics.gl.texParameterf(glTarget, GL.TEXTURE_WRAP_T, v.glEnum);
    }
  }

  /** Sets the [TextureFilter] for this texture for minification and magnification
   * [min] the minification filter
   * [mag] the magnification filter
   * [bind] wether to bind the texture before setting the filters, set it to false if texture is already bound
   * [force] true to always set the values, even if they are the same as the current ones
   */
  void setFilter (TextureFilter min, TextureFilter mag, {bool bind: false, bool force: false}) {
    bool updateMin = false, updateMag = false;
    if (force || this.minFilter != min)
      updateMin = true;

    if (force || this.magFilter != mag)
      updateMag = true;

    if ( updateMag && updateMin == false )
      return;

    if (bind)
      this.bind();

    if(updateMin){
      minFilter = min;
      _graphics.gl.texParameterf(glTarget, GL.TEXTURE_MIN_FILTER, minFilter.glEnum);
    }
    if (updateMag){
      magFilter = mag;
      _graphics.gl.texParameterf(glTarget, GL.TEXTURE_MAG_FILTER, magFilter.glEnum);
    }
  }

//  /** Sets the {@link AssetManager}. When the context is lost, textures managed by the asset manager are reloaded by the manager
//   * on a separate thread (provided that a suitable {@link AssetLoader} is registered with the manager). Textures not managed by
//   * the AssetManager are reloaded via the usual means on the rendering thread.
//   * @param manager the asset manager. */
//  static void setAssetManager (AssetManager manager) {
//    Texture.assetManager = manager;
//  }

//  static String getManagedStatus () {
//    StringBuilder builder = new StringBuilder();
//    builder.append("Managed textures/app: { ");
//    for (Application app : managedTextures.keySet()) {
//      builder.append(managedTextures.get(app).size);
//      builder.append(" ");
//    }
//    builder.append("}");
//    return builder.toString();
//  }

//  /// @return the number of managed textures currently loaded
//  static int getNumManagedTextures () {
//    return managedTextures.get(Gdx.app).size;
//  }
}



class TextureFilter{
  final num glEnum;
  bool isMipMap() => glEnum != GL.NEAREST && glEnum != GL.LINEAR;

  const TextureFilter._internal(this.glEnum);

  bool operator ==(other) => other is TextureFilter && other.glEnum == this.glEnum;

  static final Nearest = const TextureFilter._internal(GL.NEAREST);
  static final Linear = const TextureFilter._internal(GL.NEAREST);
  static final MipMap = const TextureFilter._internal(GL.LINEAR_MIPMAP_LINEAR);
  static final MipMapNearestNearest = const TextureFilter._internal(GL.NEAREST_MIPMAP_NEAREST);
  static final MipMapLinearNearest = const TextureFilter._internal(GL.LINEAR_MIPMAP_NEAREST);
  static final MipMapNearestLinear = const TextureFilter._internal(GL.NEAREST_MIPMAP_LINEAR);
  static final MipMapLinearLinear = const TextureFilter._internal(GL.LINEAR_MIPMAP_LINEAR);
}

class TextureWrap{
  final num glEnum;
  bool isMiMap() => glEnum != GL.NEAREST && glEnum != GL.LINEAR;

  const TextureWrap._internal(this.glEnum);

  bool operator ==(other) => other is TextureWrap && other.glEnum == this.glEnum;

  static final MirroredRepeat = const TextureWrap._internal(GL.MIRRORED_REPEAT);
  static final ClampToEdge    = const TextureWrap._internal(GL.CLAMP_TO_EDGE);
  static final Repeat         = const TextureWrap._internal(GL.REPEAT);
}