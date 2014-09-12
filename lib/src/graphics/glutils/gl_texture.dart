part of glib.graphics;


abstract class GLTexture implements Disposable {

  /// The target of this texture, used when binding the texture, e.g. TEXTURE_2D
  final int glTarget;
  GL.Texture glTexture;
  
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

  /// Generates a new webgl texture with the specified target. */
  GLTexture(this.glTarget, [this.glTexture = null]){
    if( glTexture == null )
      glTexture = _gl.createTexture();
  }

  /// return whether this texture is managed or not.
//  bool get isManaged;

  /** 
   * Binds the texture to the given texture unit. Sets the currently active texture unit via WebGL's activeTexture(Texture)
   * [unit] - 0 to MAX_TEXTURE_UNIT 
  */
  void bind ([int unit = null]) {
    if ( unit != null )
      _gl.activeTexture(GL.TEXTURE0 + unit);
    _gl.bindTexture(glTarget, glTexture);
  }

//  /** @return The OpenGL handle for this texture. */
//  WebGL.Texture getTextureObjectHandle () {
//    return glTexture;
//  }

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
      _gl.texParameterf(glTarget, GL.TEXTURE_WRAP_S, u.glEnum);
    }
    if (updateV){
      vWrap = v;
      _gl.texParameterf(glTarget, GL.TEXTURE_WRAP_T, v.glEnum);
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
      _gl.texParameterf(glTarget, GL.TEXTURE_MIN_FILTER, minFilter.glEnum);
    }
    if (updateMag){
      magFilter = mag;
      _gl.texParameterf(glTarget, GL.TEXTURE_MAG_FILTER, magFilter.glEnum);
    }
  }

  void dispose () {
    if (glTexture == null) 
          return;
        
    _gl.deleteTexture(glTexture);
    glTexture = null;
  }
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
