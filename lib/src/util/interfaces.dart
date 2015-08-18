part of glib.common;

abstract class Disposable{
  void dispose();
}

abstract class AssetLoader<T>{
  Future<T> load();
}

abstract class Logger{
  /** The application's logging level. [LOG_NONE] will mute all log output. [LOG_ERROR] will only let error messages through.
   * [LOG_INFO] will let all non-debug messages through, and [LOG_DEBUG] will let all messages through.
   */
  int logLevel;

  void log(String tag, String message);

  void error(String tag, String message);

  void debug(String tag, String message);
}