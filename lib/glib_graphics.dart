library glib.graphics;

import 'dart:html';
import 'dart:web_gl' as GL;
export 'dart:web_gl';
import 'dart:core';
import 'dart:typed_data';
import 'dart:math' as Math;

import 'src/maths.dart';
export 'src/maths.dart';
import 'src/common.dart';


part 'src/graphics/glutils/mesh.dart';
part 'src/graphics/glutils/gl_texture.dart';
part 'src/graphics/texture.dart';
part 'src/graphics/texture_region.dart';
part 'src/graphics/glutils/vertex_attribute.dart';
part 'src/graphics/glutils/shader_program.dart';
part 'src/graphics/glutils/vertex_buffer_object.dart';
part 'src/graphics/glutils/index_buffer_object.dart';
part 'src/graphics/2d/sprite_batch.dart';
part 'src/graphics/font.dart';
part 'src/graphics/camera.dart';
part 'src/graphics/orthographic_camera.dart';
part 'src/graphics/loaders/texture_loader.dart';
part 'src/graphics/color.dart';


GL.RenderingContext _gl;
Map<String, Texture> _textures;
int _width, _height;

abstract class Graphics{
  
  CanvasElement canvas;
  
  render();
  
  /// initializes the graphics context 
  initGraphics(CanvasElement canvas){
    if(this.canvas == canvas)
      return;
    this.canvas = canvas;
    _gl = this.canvas.getContext("webgl");
    if (_gl == null) 
      _gl = this.canvas.getContext("experimental-webgl");
    
    _textures = new Map();
    
    _width = canvas.width;
    _height = canvas.height; 
  }
  
  disposeGraphics(){
    textures.values.forEach( (texture) => texture.dispose(false));
    textures.clear();
  }
  
  GL.RenderingContext get gl => _gl;
  Map<String, Texture> get textures => _textures;
  
  int get width => _width;
  int get height => _height;
    
}
