part of glib.web;

WebGraphics _graphics;

class WebGraphics extends Graphics{
  /// updates the elapsed time between frames, DO NOT ALTER THIS
  final Stopwatch watch = new Stopwatch();
  CanvasElement canvas;
  WebGL _gl;
  Map<int, Texture> _textures;
  int _width, _height;

  double _deltatime = 0.0, _elapsedTime = 0.0;
  ///time elapsed (in seconds) since the last frame
  @override double get deltaTime =>_deltatime;

  int _fps = 0, _frames = 0;

  @override int get fps => _fps;
  @override int get width => _width;
  @override int get height => _height;
  @override GL get gl => _gl;
  @override Map<int, Texture> get textures => _textures;

  WebGraphics() : super(_loadImageElement);

  WebGraphics.config(int width, int height, [bool stencil=false, bool antialiasing=false, bool preserveDrawingBuffer=false]) : super(_loadImageElement){
    this.canvas = new CanvasElement(width: width, height: height);
    _initGraphics(stencil: stencil, antialiasing: antialiasing, preserveDrawingBuffer: preserveDrawingBuffer);
  }

  WebGraphics.withCanvas(this.canvas, [bool stencil=false, bool antialiasing=false, bool preserveDrawingBuffer=false]): super(_loadImageElement){
    _initGraphics(stencil: stencil, antialiasing: antialiasing, preserveDrawingBuffer: preserveDrawingBuffer);
  }

  @override
  void update(){
    _deltatime = watch.elapsedMilliseconds / 1000;
    _elapsedTime += deltaTime;
    _frames++;
    if (_elapsedTime > 1) {
      _elapsedTime = 0.0;
      _fps = _frames;
      _frames = 0;
    }
    watch.reset();
  }

  /// initializes the graphics context
  _initGraphics( {bool stencil:false, bool antialiasing:false, bool preserveDrawingBuffer:false}){
    if (this.canvas == null)
      throw new GlibException("No canvas element assigned");

    var glCtx = this.canvas.getContext3d(
        alpha: false,
        antialias: antialiasing,
        premultipliedAlpha: false,
        stencil: stencil,
        preserveDrawingBuffer: preserveDrawingBuffer
    );

    _gl = new WebGL(glCtx);

    _textures = new Map();

    _width = canvas.width;
    _height = canvas.height;

    _gl.viewport(0, 0, canvas.width, canvas.height);

    initGraphics(this, Glib.files);
    _graphics = this;
    watch.start();
  }

  @override
  void dispose(){
    super.dispose();
    watch.stop();
  }

}

