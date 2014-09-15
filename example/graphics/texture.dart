import 'package:glib/glib_graphics.dart';
import 'package:glib/glib_math.dart';
import 'dart:html';
import 'dart:web_gl' as GL;
import 'dart:typed_data';


GraphicsTest test;
int drawCount = 10;

void main(){
  CanvasElement canvas = querySelector("#canvas");
  test = new GraphicsTest(canvas);
  window.animationFrame.then(update);
}

void update(num delta){
  test.render();
  if(--drawCount > 0)
    window.animationFrame.then(update);
}

class GraphicsTest extends Object with Graphics{
  
  Texture texture;
  Texture spriteSheet;
  TextureRegion firstFrame;
  SpriteBatch batch;
  Font font, font2;
  
  GraphicsTest(canvas){
    initGraphics(canvas);
    
    batch = new SpriteBatch();
    texture = new Texture.fromUrl("assets/head.png");
    spriteSheet = new Texture.fromUrl('assets/spritesheet-body.png');
    firstFrame = new TextureRegion(spriteSheet, 0, 0, 64, 64);
    font = new Font();
    font2 = new Font();
  }
  
  render(){
    gl.clearColor(0, 0, 0, 1);
    gl.clear(GL.COLOR_BUFFER_BIT);
    
    batch
      ..begin()
      ..drawTexture(texture, 0.0, 0.0)
      ..drawRegion(firstFrame, 40.0, 1.0)
      ..drawTexture(texture, 27.0, 38.0)
      ..drawTexture(texture, 54.0, 76.0)
      ..drawTexture(texture, 54 + 27.0, 76+38.0)
      ..drawRegion(firstFrame, 67.0, 38.0)
      ..drawRegion(firstFrame, 80.0, 76.0)
      ..drawTexture(spriteSheet, 100.0, 100.0);
    
    font
      ..draw(batch, "hello canvas text", 250.0, 50.0)
      ..draw(batch, "text 2", 100.0, 25.0);
    
    batch.end();
    
  }
}