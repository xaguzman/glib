part of glib;

class Glib{
  static Application _app;
  static Application get app => _app;
  
  static Graphics _graphics;
  static Graphics get graphics => _graphics;
  
  //Audio get audio;
  static Input _input;
  static Input get input => _input;
  
  static RenderingContext _gl;
  static RenderingContext get gl =>_gl;

  static bool _init = false;

  static void init(app, graphics, input, gl){
//    if (_init){
//      throw new GlibException("Can only initialize once");
//    }
    _app = app;
    _graphics = graphics;
    _input = input;
    _gl = gl;
//    _init = true;
  }
}
