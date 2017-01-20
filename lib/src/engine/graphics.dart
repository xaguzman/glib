library glib.graphics;

// import 'dart:html';
//export 'dart:web_gl' hide Texture;
import 'dart:core';
import 'dart:typed_data';
import 'dart:math' as Math;

import 'files.dart';
import 'math.dart';
import 'common.dart';

part 'graphics/glutils/immediate_mode_renderer.dart';
part 'graphics/glutils/index_buffer_object.dart';
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
part 'graphics/2d/sprite_cache.dart';
//part 'graphics/font.dart';
part 'graphics/camera.dart';
part 'graphics/orthographic_camera.dart';
part 'graphics/color.dart';
part 'graphics/viewport/viewport.dart';
part 'graphics/glutils/vertex_buffer_object.dart';
part 'graphics/gl.dart';

part 'graphics/fonts/bitmap_font.dart';
part 'graphics/fonts/bitmap_font_format.dart';
part 'graphics/fonts/bitmap_font_loader.dart';

part 'graphics/maps/map.dart';
part 'graphics/maps/tiled/tiled_map.dart';
part 'graphics/maps/tiled/tiled_map_layers.dart';
part 'graphics/maps/tiled/tiled_map_tile.dart';
part 'graphics/maps/tiled/tiled_map_tileset.dart';
//part 'graphics/maps/tiled/tmx_map_loader.dart';

Graphics _graphics;
Files _files;

typedef Texture TextureUploadFunction(Object textureSource);

abstract class Graphics implements Disposable{

  /// the time elapsed between the last frame and the current frame, in seconds!
  double get deltaTime;

  /// the current frames per second
  int get fps;

  TextureUploadFunction uploadTexture;

  Graphics(this.uploadTexture);

  /// updates the elapsed time since the last rendering, also the frames per second.
  /// you should not directly call this
  void update();

  GL get gl;
  Map<int, Texture> get textures;

  int get width;
  int get height;

  initGraphics(Graphics instance, Files files){
   _graphics = instance;
    _files = files;
  }

  @override
  void dispose(){
    textures.values.forEach( (texture) => texture._dispose());
    textures.clear();
  }
}
