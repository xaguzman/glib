part of glib.graphics;

class Texture extends GLTexture { 
  String url;
  
  int get id => _id;
  int _id;
  
  /// wether this texture is ready to be rendered. Usually, you should only see this as false when the constructor
  /// [Texture.from] is used, and the image hasn't been totally downloaded from the remote server
  bool loaded = true;
  
  Texture(): super(GL.TEXTURE_2D){
    this.width = this.height = 1;
  }
  
  ///creates a GL texture of the specified size. 
  Texture.size(int width, int height):super(GL.TEXTURE_2D){
    this.width = width;
    this.height = height;
  }
  
  /// creates a texture from an image stored in the given [url]. Not cross-domain friendly
  Texture.from(this.url): super(GL.TEXTURE_2D), loaded = false {
    var loader = new TextureLoader(url);
    uploadData(1, 1); //create dummy data so rendering doesn't break when using this constructor
    loader.done.then(_loadImageElement);
    loader.load();
  }
  
  void _loadImageElement(ImageElement img){
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
  
//  /// @return whether this texture is managed or not.
//  bool get isManaged => data.isManaged();

  /// Disposes all resources associated with this texture. If autoremove is set to true, it will
  /// be immediatly removed from Graphics.textures, otherwise you need to remove it yourself
  void dispose ([bool autoRemove = true]) {
    super.dispose();
    if(autoRemove)
      _textures.remove(glTexture);
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