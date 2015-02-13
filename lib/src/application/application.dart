part of glib;

abstract class Application extends Disposable{

  static const int LOG_NONE = 0;
  static const int LOG_DEBUG = 3;
  static const int LOG_INFO = 2;
  static const int LOG_ERROR = 1;

  ApplicationListener get listener;

  Graphics get graphics;
//  Audio get audio;
  Input get input;

  /// Logs an information message to the console
  void log(String tag, String message);
  /// Logs an error message to the console
  void error(String tag, String message);
  /** Logs a debug message to the console*/
  void debug(String tag, String message);


  /** The application's logging level. [LOG_NONE] will mute all log output. [LOG_ERROR] will only let error messages through.
   * [LOG_INFO] will let all non-debug messages through, and [LOG_DEBUG] will let all messages through.
   */
  int logLevel;

  /// Posts a function on the main loop thread, which will be executed on the next game loop
  void postAction(Function runnable);
  
}

abstract class WebApplication implements Application {
  ApplicationListener _listener;
  final WebApplicationConfiguration config;
  int _lastWidth, _lastHeight;

  Stopwatch _watch;
  Duration _duration;
  CanvasInput _input;
  WebGraphics _graphics;
  List<Function> actions;
  Timer _timer;

  @override int logLevel;
  @override WebGraphics get graphics => _graphics;
  @override Input get input => _input;
  @override ApplicationListener get listener => _listener;
  
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
    _input = new CanvasInput(graphics.canvas);

    _watch = new Stopwatch();
    var duration = new Duration(milliseconds: ((1 / config.fps) * 1000).toInt());
    
    Glib._app = this;
    Glib._gl = graphics.gl;
    Glib._graphics = graphics;
    Glib._input = input;
    
    listener.create();
    listener.resize(graphics.width, graphics.height);
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
