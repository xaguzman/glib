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
  static RenderingContext get gl => _gl;
}