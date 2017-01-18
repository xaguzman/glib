part of glib;

abstract class Application extends Disposable implements Logger{

  static const int LOG_NONE = 0;
  static const int LOG_DEBUG = 3;
  static const int LOG_INFO = 2;
  static const int LOG_ERROR = 1;

  ApplicationListener get listener;

  Graphics get graphics;
//  Audio get audio;
  Input get input;
  Files get files;
  GL get gl;

  /// Posts a function on the main loop thread, which will be executed on the next game loop
  void postAction(Function runnable);
}

