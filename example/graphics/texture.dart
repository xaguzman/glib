import 'package:glib/glib_graphics.dart';
import 'package:glib/glib_math.dart';
import 'dart:html';
import 'dart:web_gl' as GL;
import 'dart:typed_data';


GraphicsTest test;

void main(){
  test = new GraphicsTest(querySelector("#canvas")); 
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
    texture = new Texture.fromUrl("assets/bunny.png");
  }
  
  render(){
    gl.clearColor(0, 0, 0, 1);
    gl.clear(GL.COLOR_BUFFER_BIT);
    
    batch
        ..begin()
        ..drawTexture(texture, 50.0, 50.0)
        ..end();
    
  }
}