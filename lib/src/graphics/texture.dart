part of glib.graphics;

class Texture extends GLTexture { 
  String url;
  
  int get id => _id;
  int _id;
  
  bool loaded = false;
  
  Texture(): super(GL.TEXTURE_2D);

  factory Texture.fromUrl(String url, [String name]) {
    if (_textures.containsKey(url)){
      return _textures[url];
    }
    
    var loader = new TextureLoader(url);
    
    var t = new Texture()
      ..url = url
      ..uploadData(1, 1)
      .._attachFutureHandlers(loader);
    
    loader.load();
    return t;
  }
  
  void _attachFutureHandlers (TextureLoader loader) {
    loader.done.then((img){
      width = img.width;
      height = img.height;
      bind();
      uploadImage(img);
      setFilter(minFilter, magFilter, force: true);
      setWrap(uWrap, uWrap, force: true);
      _gl.bindTexture(glTarget, null);
      _textures[url] = this;
      loaded = true;
      _loadCompleter.complete(this);
    });
  }
  
  Completer<Texture> _loadCompleter = new Completer();
  Future<Texture> get onLoad => _loadCompleter.future;
  
  void uploadData(int width, int height,{int level:0, int format:GL.RGBA, int type:GL.UNSIGNED_BYTE, bool genMipMaps:false, data:null}){
    if (width == null)
      width = 0;
    if (height == null)
      height = 0;
    
    this.width = width;
    this.height = height;
    
    bind();
    _gl.texImage2DTyped(glTarget, level, format, width, height, 0, format, type, data);
    if (genMipMaps)
      _gl.generateMipmap(glTarget);
  }
  
  void uploadCanvas(CanvasElement canvas, {int level:0, int format:GL.RGBA, int type:GL.UNSIGNED_BYTE, bool genMipMaps:false}){
    width = canvas.width;
    height = canvas.height;
    
    _gl.texImage2DCanvas(glTarget, level, format, format, type, canvas);
    
    if(genMipMaps)
      _gl.generateMipmap(glTarget);
  }
    
  void uploadImage(ImageElement img, {int level:0, int format:GL.RGBA, int type:GL.UNSIGNED_BYTE, bool genMipMaps:false}){
    
    width = img.width;
    height = img.height;
    
//    _gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 1);
    _gl.texImage2DImage(glTarget,  level,  format,  format,  type, img);
    
    
    
    if(genMipMaps)
      _gl.generateMipmap(glTarget);
  }
  
//    if (this.data != null && data.isManaged() != this.data.isManaged())
//      throw new GdxRuntimeException("New data must have the same managed status as the old data");
//    this.data = data;
//
//    if (!data.isPrepared()) data.prepare();
//
//    bind();
//    uploadImageData(GL20.GL_TEXTURE_2D, data);
//
//    setFilter(minFilter, magFilter);
//    setWrap(uWrap, vWrap);
//    Gdx.gl.glBindTexture(glTarget, 0);
//  }

//  /** Used internally to reload after context loss. Creates a new GL handle then calls {@link #load(TextureData)}. Use this only
//   * if you know what you do! */
//  
//  void _reload () {
//    if (!isManaged()) throw new GdxRuntimeException("Tried to reload unmanaged Texture");
//    glHandle = createGLTexture();
//    load(data);
//  }

//  /** Draws the given {@link Pixmap} to the texture at position x, y. No clipping is performed so you have to make sure that you
//   * draw only inside the texture region. Note that this will only draw to mipmap level 0!
//   * 
//   * @param pixmap The Pixmap
//   * @param x The x coordinate in pixels
//   * @param y The y coordinate in pixels */
//  void draw (Pixmap pixmap, int x, int y) {
//    if (data.isManaged()) throw new GdxRuntimeException("can't draw to a managed texture");
//
//    bind();
//    Gdx.gl.glTexSubImage2D(glTarget, 0, x, y, pixmap.getWidth(), pixmap.getHeight(), pixmap.getGLFormat(), pixmap.getGLType(),
//      pixmap.getPixels());
//  }

//  TextureData get textureData => data;

//  /// @return whether this texture is managed or not.
//  bool get isManaged => data.isManaged();

  /// Disposes all resources associated with this texture. If autoremove is set to true, it will
  /// be immediatly removed from Graphics.textures, otherwise you need to remove it yourself
  void dispose ([bool autoRemove = true]) {
    super.dispose();
    if(autoRemove)
      _textures.remove(glTexture);
  }

//  /// Invalidate all managed textures. This is an internal method. Do not use it!
//  static void invalidateAllTextures (Application app) {
//    Array<Texture> managedTextureArray = managedTextures.get(app);
//    if (managedTextureArray == null) return;
//
//    if (assetManager == null) {
//      for (int i = 0; i < managedTextureArray.size; i++) {
//        Texture texture = managedTextureArray.get(i);
//        texture.reload();
//      }
//    } else {
//      // first we have to make sure the AssetManager isn't loading anything anymore,
//      // otherwise the ref counting trick below wouldn't work (when a texture is
//      // currently on the task stack of the manager.)
//      assetManager.finishLoading();
//
//      // next we go through each texture and reload either directly or via the
//      // asset manager.
//      Array<Texture> textures = new Array<Texture>(managedTextureArray);
//      for (Texture texture : textures) {
//        String fileName = assetManager.getAssetFileName(texture);
//        if (fileName == null) {
//          texture.reload();
//        } else {
//          // get the ref count of the texture, then set it to 0 so we
//          // can actually remove it from the assetmanager. Also set the
//          // handle to zero, otherwise we might accidentially dispose
//          // already reloaded textures.
//          final int refCount = assetManager.getReferenceCount(fileName);
//          assetManager.setReferenceCount(fileName, 0);
//          texture.glHandle = 0;
//
//          // create the parameters, passing the reference to the texture as
//          // well as a callback that sets the ref count.
//          TextureParameter params = new TextureParameter();
//          params.textureData = texture.getTextureData();
//          params.minFilter = texture.getMinFilter();
//          params.magFilter = texture.getMagFilter();
//          params.wrapU = texture.getUWrap();
//          params.wrapV = texture.getVWrap();
//          params.genMipMaps = texture.data.useMipMaps(); // not sure about this?
//          params.texture = texture; // special parameter which will ensure that the references stay the same.
//          params.loadedCallback = new LoadedCallback() {
//            
//            void finishedLoading (AssetManager assetManager, String fileName, Class type) {
//              assetManager.setReferenceCount(fileName, refCount);
//            }
//          };
//
//          // unload the texture, create a new gl handle then reload it.
//          assetManager.unload(fileName);
//          texture.glHandle = Texture.createGLTexture();
//          assetManager.load(fileName, Texture.class, params);
//        }
//      }
//      managedTextureArray.clear();
//      managedTextureArray.addAll(textures);
//    }
//  }

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