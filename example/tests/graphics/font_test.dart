part of glib.tests;

class FontTest extends Test{
  
  Font arial;
  Font monospace;
  String testmsg = 'The quick brown fox jumps over the lazy dog 0123456789';
  SpriteBatch batch;
  
  FontTest():super("Font test");
  
  create(){
    arial = new Font(new FontStyle(28, 'arial'))
//      ..debugTextures = true
      ..maxTextureWidth = 512;
    monospace = new Font(new FontStyle(20, 'monospace'))
      ..maxTextureWidth = 512;
    
    batch = new SpriteBatch();
  }
  
  render(){
    super.render();
    batch.begin();
    arial
      ..draw(batch, testmsg, 20.0, 20.0)
      ..draw(batch, 'Arial', 20.0, 45.0);
    monospace
      ..draw(batch, testmsg,  20.0, 80.0)
      ..draw(batch, 'monospace',  20.0, 100.0);
        
    double y = 0.0;
    for (int i = 0; i < arial.textures.length; i++){
      batch.drawTexture(arial.textures[i], 250.0, 100.0 + y);
      y += arial.textures[i].height + 5.0;
    }
    
    for (int i = 0; i < monospace.textures.length; i++){
      batch.drawTexture(monospace.textures[i], 250.0, 100.0 + y);
      y += arial.textures[i].height + 5.0;
    }
    batch.end();
  }
  
  dispose(){
    arial.dispose();
    monospace.dispose();
  }
  
  String get name => 'Font test';
}