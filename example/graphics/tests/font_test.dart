part of glib.tests;

class FontTest extends Test{
  
  Font arial;
  Font monospace;
  
  FontTest(gl):super(gl);
  
  init(){
    arial = new Font(new FontStyle(23, 'arial'))
//      ..debugTextures = true
      ..maxTextureWidth = 254;
    monospace = new Font(new FontStyle(20, 'monospace'))
      ..maxTextureWidth = 512;
  }
  
  render(){
    var batch = Test.batch;
    batch.begin();
    arial
      ..draw(batch, 'Arial 1', 20.0, 20.0)
      ..draw(batch, 'Arial 2', 20.0, 40.0);
    monospace
      ..draw(batch, 'monospace 1',  100.0, 20.0)
      ..draw(batch, 'monospace 2',  100.0, 40.0);
    
    arial.draw(batch, 'Arial 3', 20.0, 60.0);
    
    double y = 0.0;
    for (int i = 0; i < arial.textures.length; i++){
      batch.drawTexture(arial.textures[i], 20.0, 100.0 + y);
      y += arial.textures[i].height + 5.0;
    }
    
    for (int i = 0; i < monospace.textures.length; i++){
      batch.drawTexture(monospace.textures[i], 20.0, 100.0 + y);
      y += arial.textures[i].height + 5.0;
    }
    batch.end();
  }
  
  dispose(){
    arial.dispose();
    monospace.dispose();
  }
}