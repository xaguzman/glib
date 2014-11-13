library glib.graphics;

import 'dart:html';
import 'dart:web_gl' as GL;
export 'dart:web_gl';
import 'dart:core';
import 'dart:typed_data';
import 'dart:math' as Math;

import 'math.dart';
export 'math.dart';
import 'common.dart';


part 'graphics/glutils/mesh.dart';
part 'graphics/glutils/gl_texture.dart';
part 'graphics/texture.dart';
part 'graphics/texture_region.dart';
part 'graphics/glutils/vertex_attribute.dart';
part 'graphics/glutils/shader_program.dart';
part 'graphics/glutils/vertex_buffer_object.dart';
part 'graphics/glutils/index_buffer_object.dart';
part 'graphics/2d/sprite_batch.dart';
part 'graphics/font.dart';
part 'graphics/camera.dart';
part 'graphics/orthographic_camera.dart';
part 'graphics/loaders/texture_loader.dart';
part 'graphics/color.dart';


GL.RenderingContext _gl;
Map<String, Texture> _textures;
int _width, _height;

abstract class Graphics{
  
  CanvasElement canvas;
  
  double _deltatime = 0.0;
  double get deltaTime =>_deltatime;
  
  double elapsedTime = 0.0;
  Stopwatch _watch;
  
  int _fps = 0, _frames = 0;
  /// the current frames per second
  int get fps => _fps;
  
  /// updates the elapsed time since the last rendering, also the frames per second.
  /// you should not directly call this
  update(){
    _deltatime = _watch.elapsedMilliseconds / 1000; 
    elapsedTime += deltaTime;
    _frames++;
    if (elapsedTime > 1) {
      elapsedTime = 0.0;
      _fps = _frames;
      _frames = 0;
    }
    _watch.reset();
  }
  
  /// initializes the graphics context 
  initGraphics(CanvasElement canvas, 
      {bool stencil:false, bool antialiasing:false, bool preserveDrawingBuffer:false}){
    if(this.canvas == canvas)
      return;
    this.canvas = canvas;
    _gl = this.canvas.getContext("webgl");
    if (_gl == null) 
      _gl = this.canvas.getContext("experimental-webgl");
    
    _textures = new Map();
    
    _width = canvas.width;
    _height = canvas.height;
    
    GL.ContextAttributes attribs = _gl.getContextAttributes();
    
    attribs
      ..antialias = antialiasing
      ..stencil = stencil
      ..premultipliedAlpha = false
      ..alpha = false
      ..preserveDrawingBuffer = preserveDrawingBuffer;
    
    _gl.viewport(0, 0, canvas.width, canvas.height);
    
    _watch = new Stopwatch()..start(); 
  }
  
  disposeGraphics(){
    textures.values.forEach( (texture) => texture._dispose());
    textures.clear();
    _watch.stop();
  }
  
  GL.RenderingContext get gl => _gl;
  Map<String, Texture> get textures => _textures;
  
  int get width => _width;
  int get height => _height;
    
}

class WebGraphics extends Graphics{

  WebGraphics();

  WebGraphics.config(int width, int height, [bool stencil=false, bool antialiasing=false, bool preserveDrawingBuffer=false]){
    
    var canvas = new CanvasElement(width: width, height: height);
    initGraphics(canvas, stencil: stencil, antialiasing: antialiasing, preserveDrawingBuffer: preserveDrawingBuffer);
  }
 
}
