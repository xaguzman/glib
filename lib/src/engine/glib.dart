library glib;

import 'graphics.dart';
import 'input.dart';
import 'files.dart';
import 'common.dart';

part 'application/application.dart';
part 'application/application_configuration.dart';
part 'application/application_listener.dart';
part 'application/game.dart';


class Glib{
  static Application _app;
  static Application get app => _app;
  
  static Graphics _graphics;
  static Graphics get graphics => _graphics;
  
  //Audio get audio;
  static Input _input;
  static Input get input => _input;
  
  static GL _gl;
  static GL get gl =>_gl;

  static Files _files;
  static Files get files => _files;

  static void init(app, graphics, input, gl, files){
    _app = app;
    _graphics = graphics;
    _input = input;
    _gl = gl;
    _files = files;
  }
}
