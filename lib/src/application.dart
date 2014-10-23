part of glib;

abstract class Application{
  
  static const int LOG_NONE = 0;
  static const int LOG_DEBUG = 3;
  static const int LOG_INFO = 2;
  static const int LOG_ERROR = 1;

//  ApplicationHandler get appHandler;

  Graphics get graphics;
//  Audio get audio;
  Input get input;
  
  /// Logs an information message to the console
  void log (String tag, String message);
  /// Logs an error message to the console
  void error (String tag, String message);
  /** Logs a debug message to the console*/
  void debug (String tag, String message);


  /** The application's logging level. [LOG_NONE] will mute all log output. [LOG_ERROR] will only let error messages through.
   * [LOG_INFO] will let all non-debug messages through, and [LOG_DEBUG] will let all messages through.
   */
  int logLevel;

  /// Posts a function on the main loop thread, which will be executed on the next game loop
  void postAction (Function runnable);
  
}


class WebApplication extends Application{
//  ApplicationHandler _handler;
  final WebApplicationConfiguration config;
  int _lastWidth, _lastHeight;
  
  Stopwatch _watch;
  Duration _duration;
  
  
  @override
  Graphics graphics;
  
  @override  
  Input get input => _input;
  CanvasInput _input;
  
  List<Function> actions = new List();
  
  
  WebApplication(this.config){
    graphics = new WebGraphics.config(config.width, config.height, config.stencil, config.antialiasing, config.preserveDrawingBuffer);
    _lastWidth = graphics.width;
    _lastHeight = graphics.height;
    
    _input = new CanvasInput(graphics.canvas);
    
    _watch = new Stopwatch();
    var duration = new Duration(milliseconds: ((1 / config.fps) * 1000).toInt());
    new Timer.periodic(duration, (_) => _mainLoop);
  }
  
  void _mainLoop(){
    graphics.update();
    if (graphics.width != _lastWidth || graphics.height != _lastHeight) {
//      listener.resize(Gdx.graphics.getWidth(), Gdx.graphics.getHeight());
      _lastWidth = graphics.width;
      _lastHeight = graphics.height;
      graphics.gl.viewport(0, 0, _lastWidth, _lastHeight);
    }
    actions.forEach( (func) => func() );
    actions.clear();
//    listener.render();
    _input.reset();
  }
  
  
  
  void log (String tag, String message){
    window.console.log("$tag : $message");
  }
  
  void error (String tag, String message){
    window.console.error("$tag : $message");
  }
    
  void debug (String tag, String message){
    window.console.debug("$tag : $message");
  }
  
  void postAction (Function runnable){
    
  }
  
}