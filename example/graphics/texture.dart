import 'package:glib/glib_graphics.dart';
import 'package:glib/glib_math.dart';
import 'dart:html';
import 'dart:web_gl' as GL;
import 'dart:typed_data';


GraphicsTest test;

void main(){
  CanvasElement canvas = querySelector("#canvas");
  test = new GraphicsTest(canvas);
  window.animationFrame.then(update);
}

void update(num delta){
  test.render();
  window.animationFrame.then(update);
}

class GraphicsTest extends Object with Graphics{
  
  Texture texture;
  SpriteBatch batch;
  Matrix4 matrix = new Matrix4();
  
  GraphicsTest(canvas){
    initGraphics(canvas);
    
    batch = new SpriteBatch();
    texture = new Texture.fromUrl("assets/head.png");
  }
  
  render(){
    gl.clearColor(0, 0, 0, 1);
    gl.clear(GL.COLOR_BUFFER_BIT);
    
    batch
        ..begin()
        ..drawTexture(texture, 0.0, 0.0)
        ..drawTexture(texture, 27.0, 38.0)
        ..drawTexture(texture, 54.0, 76.0)
        ..drawTexture(texture, 54 + 27.0, 76+38.0)
        ..end();
    
  }
}