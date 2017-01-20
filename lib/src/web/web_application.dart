part of glib.web;

abstract class WebApplication implements Application {
  ApplicationListener _listener;
  final WebApplicationConfiguration config;
  int _lastWidth, _lastHeight;

  CanvasInput _input;
  WebGraphics _graphics;
  List<Function> actions;
  Timer _timer;
  WebFiles _files;

  @override int logLevel;
  @override Graphics get graphics => _graphics;
  @override Input get input => _input;
  @override ApplicationListener get listener => _listener;
  @override Files get files => _files;
  @override GL get gl => _graphics.gl;

  ///Creates a new application with the given configuration. If [canvas] is not specified, it will automatically
  ///use the [config.width] and [config.height] to create a new canvas, which you can then access through [graphics.canvas]
  WebApplication(this._listener, this.config, {CanvasElement canvas}) {
    if (canvas != null){
      _graphics = new WebGraphics.withCanvas(canvas, config.stencil, config.antialiasing, config.preserveDrawingBuffer);
    }else{
      _graphics = new WebGraphics.config(config.width, config.height,
      config.stencil, config.antialiasing, config.preserveDrawingBuffer);
    }
    _lastWidth = graphics.width;
    _lastHeight = graphics.height;
    actions = new List();

    document.onVisibilityChange.listen( _visibilityChanged );

    appLogger = this;
    _Preloader preloader = new _Preloader('assets');
    preloader.preload("assets.txt", (PreloaderState state){
      // TODO show some loading ui?
      if(state.hasEnded()){
        startLoop();
      }
    }, (String errorMsg){
      error("Error when loading assets", errorMsg);
    });

    _files = new WebFiles(preloader);
    _input = new CanvasInput(_graphics.canvas);
    _webApp = this;
    _graphics.initGraphics(_graphics, _files);
  }

  void startLoop(){
    Glib.init(this, graphics, input, graphics.gl, _files);

    listener.create();
    listener.resize(graphics.width, graphics.height);

    var duration = new Duration(milliseconds:  1000 ~/ config.fps);
    _timer = new Timer.periodic(duration, _mainLoop);
  }

  void _mainLoop(timer) {
    if (!_timer.isActive) return;

    graphics.update();
    if (graphics.width != _lastWidth || graphics.height != _lastHeight) {
      _listener.resize(graphics.width, graphics.height);
      _lastWidth = graphics.width;
      _lastHeight = graphics.height;
      graphics.gl.viewport(0, 0, _lastWidth, _lastHeight);
    }
    actions.forEach((func) => func());
    actions.clear();
    _listener.render();
    _input.reset();
  }

  void _visibilityChanged(Event e){
    bool visible = !document.hidden;

    if (visible){
//      graphics.watch.start();
      listener.resume();
    }else{
//      graphics.watch.stop();
      listener.pause();
    }
  }

  void log(String tag, String message) {
    window.console.log("$tag : $message");
  }

  void error(String tag, String message) {
    window.console.error("$tag : $message");
  }

  void debug(String tag, String message) {
    window.console.debug("$tag : $message");
  }

  void postAction(Function runnable) {
    actions.add(runnable);
  }

  void dispose(){
    _timer.cancel();
    graphics.dispose();
    input.dispose();
  }

}

WebApplication _webApp;