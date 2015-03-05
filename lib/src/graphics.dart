library glib.graphics;

import 'dart:html';
import 'dart:web_gl' as GL;
export 'dart:web_gl';
import 'dart:core';
import 'dart:typed_data';
import 'dart:math' as Math;

import 'math.dart';
import 'common.dart';


part 'graphics/glutils/mesh.dart';
part 'graphics/glutils/gl_texture.dart';
part 'graphics/texture.dart';
part 'graphics/texture_region.dart';
part 'graphics/sprite.dart';
//part 'graphics/texture_atlas.dart';
part 'graphics/glutils/vertex_attribute.dart';
part 'graphics/glutils/shader_program.dart';
part 'graphics/glutils/vertex_buffer_object.dart';
part 'graphics/glutils/index_buffer_object.dart';
part 'graphics/2d/sprite_batch.dart';
part 'graphics/2d/animation.dart';
part 'graphics/font.dart';
part 'graphics/camera.dart';
part 'graphics/orthographic_camera.dart';
part 'graphics/loaders/texture_loader.dart';
part 'graphics/color.dart';
part 'graphics/viewport/viewport.dart';
part 'graphics/glutils/immediate_mode_renderer.dart';
part 'graphics/glutils/shape_renderer.dart';


//GL.RenderingContext _gl;
//Map<String, Texture> _textures;
//int _width, _height;

Graphics _graphics;

abstract class Graphics extends Disposable{
  
  /// the time elapsed between the last frame and the current frame, in seconds!
  double get deltaTime;
  
  /// the current frames per second
  int get fps;
  
  /// updates the elapsed time since the last rendering, also the frames per second.
  /// you should not directly call this
  void update();
     
  GL.RenderingContext get gl; 
  Map<int, Texture> get textures; 
  
  int get width;
  int get height;
}

class WebGraphics extends Graphics{
  Stopwatch _watch;
  CanvasElement canvas;
  GL.RenderingContext _gl;
  Map<int, Texture> _textures;
  int _width, _height;
    
  double _deltatime = 0.0, _elapsedTime = 0.0;
  ///time elapsed (in seconds) since the last frame
  @override double get deltaTime =>_deltatime;
  
  int _fps = 0, _frames = 0;
  
  @override int get fps => _fps;
  @override int get width => _width;
  @override int get height => _height;
  @override GL.RenderingContext get gl => _gl;
  @override Map<int, Texture> get textures => _textures;
  
  WebGraphics();

  WebGraphics.config(int width, int height, [bool stencil=false, bool antialiasing=false, bool preserveDrawingBuffer=false]){
    this.canvas = new CanvasElement(width: width, height: height);
    _initGraphics(stencil: stencil, antialiasing: antialiasing, preserveDrawingBuffer: preserveDrawingBuffer);
  }
  
  WebGraphics.withCanvas(this.canvas, [bool stencil=false, bool antialiasing=false, bool preserveDrawingBuffer=false]){
    _initGraphics(stencil: stencil, antialiasing: antialiasing, preserveDrawingBuffer: preserveDrawingBuffer);
  }
  
  @override 
  void update(){
    _deltatime = _watch.elapsedMilliseconds / 1000; 
    _elapsedTime += deltaTime;
    _frames++;
    if (_elapsedTime > 1) {
      _elapsedTime = 0.0;
      _fps = _frames;
      _frames = 0;
    }
    _watch.reset();
  }
  
  /// initializes the graphics context 
  _initGraphics( {bool stencil:false, bool antialiasing:false, bool preserveDrawingBuffer:false}){
    if (this.canvas == null)
      throw new GlibException("No canvas element assigned");
    
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
    
    _graphics = this;
    _watch = new Stopwatch()..start(); 
  }
  
  @override
  void dispose(){
      textures.values.forEach( (texture) => texture._dispose());
      textures.clear();
      _watch.stop();
  }
   
}
