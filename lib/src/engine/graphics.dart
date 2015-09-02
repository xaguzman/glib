library glib.graphics;

import 'dart:html';
import 'dart:web_gl' as GL;
export 'dart:web_gl' hide Texture;
import 'dart:core';
import 'dart:typed_data';
import 'dart:math' as Math;

import 'math.dart';
import 'common.dart';

//part 'graphics/gl_20.dart';
part 'graphics/glutils/gl_texture.dart';
part 'graphics/glutils/immediate_mode_renderer.dart';
part 'graphics/glutils/index_buffer_object.dart';
//part 'graphics/glutils/webgl_wrappers.dart';
part 'graphics/texture.dart';
part 'graphics/texture_region.dart';
part 'graphics/sprite.dart';
//part 'graphics/texture_atlas.dart';
part 'graphics/glutils/mesh.dart';
part 'graphics/glutils/shader_program.dart';
part 'graphics/glutils/shape_renderer.dart';
part 'graphics/glutils/vertex_attribute.dart';
part 'graphics/2d/animation.dart';
part 'graphics/2d/sprite_batch.dart';
part 'graphics/font.dart';
part 'graphics/camera.dart';
part 'graphics/orthographic_camera.dart';
part 'graphics/color.dart';
part 'graphics/viewport/viewport.dart';
part 'graphics/glutils/vertex_buffer_object.dart';


part 'graphics/maps/map.dart';
part 'graphics/maps/tiled/tiled_map.dart';
part 'graphics/maps/tiled/tiled_map_layers.dart';
part 'graphics/maps/tiled/tiled_map_tile.dart';
part 'graphics/maps/tiled/tiled_map_tileset.dart';
//part 'graphics/maps/tiled/tmx_map_loader.dart';

Graphics _graphics;

abstract class Graphics implements Disposable{
  
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