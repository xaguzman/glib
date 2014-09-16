part of glib.tests; 

class TextureTest extends Test{
  
  Texture texture;
  Texture spriteSheet;
  TextureRegion firstFrame;
  
  TextureTest(gl):super(gl);
  
  init(){    
    texture = new Texture.fromUrl("assets/head.png");
    spriteSheet = new Texture.fromUrl('assets/spritesheet-body.png');
    firstFrame = new TextureRegion(spriteSheet, 0, 0, 64, 64);
  }
  
  render(){
    Test.batch
      ..begin()
      ..drawTexture(texture, 0.0, 0.0)
      ..drawRegion(firstFrame, 40.0, 1.0)
      ..drawTexture(texture, 27.0, 38.0)
      ..drawTexture(texture, 54.0, 76.0)
      ..drawTexture(texture, 54 + 27.0, 76+38.0)
      ..drawRegion(firstFrame, 67.0, 38.0)
      ..drawRegion(firstFrame, 80.0, 76.0)
      ..drawTexture(spriteSheet, 100.0, 100.0)
      ..end();
  }
  
  dispose(){
    texture.dispose();
    spriteSheet.dispose();
  }
}