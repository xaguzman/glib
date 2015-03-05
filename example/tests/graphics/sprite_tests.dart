part of glib.tests;

class SpriteTransformTest extends Test{
  
  SpriteBatch batch;
  Sprite sprRot1, sprRot2, sprRot3, sprRot4, sprRot5, sprRot6;
  
  Sprite sprScl1, sprScl2, sprScl3;
  
  Sprite spriteAll;
  
  Random colorRandom = new Random();
  
  Font fps;
  double accum = 0.0;
  
  SpriteTransformTest():super("Texture test");
  
  create(){    
    var texture = new Texture.from("assets/head.png");
    sprRot1 = new Sprite(texture);
    sprRot2 = new Sprite(texture);
    sprRot3 = new Sprite(texture);
    sprRot4 = new Sprite(texture);
    sprRot5 = new Sprite(texture);
    sprRot6 = new Sprite(texture);
    
    sprScl1 = new Sprite(texture);
    sprScl2 = new Sprite(texture);
    sprScl3 = new Sprite(texture);
    
    spriteAll = new Sprite(texture);
    
    batch = new SpriteBatch();
    fps = new Font();
    
    
    sprRot1.setPosition(20.0, 30.0);
    sprRot2.setPosition(60.0, 30.0);
    sprRot3.setPosition(20.0, 70.0);
    sprRot4.setPosition(60.0, 70.0);
    sprRot5.setPosition(100.0,  30.0);
    sprRot6.setPosition(140.0,  30.0);
    
    sprScl1.setPosition(100.0, 100.0);
    sprScl2.setPosition(170.0, 100.0);
    sprScl3.setPosition(240.0, 100.0);
    
    spriteAll.setPosition(300.0, 300.0);
  }
  
  render(){
    super.render();
    
    accum += Glib.graphics.deltaTime;
            
    
    sprRot1.rotate(1.0);
    sprRot2.rotate(-1.0);
    
    if (accum >= 2.0){
      sprRot3.rotate90(true);      
      sprRot4.rotate90(false);
    }
    
  // fixed rotation
    sprRot5.rotation = 45.0;
    sprRot6.rotation = -45.0;
    
    
    if (sprScl1.scaleX  <= 2.0){
      sprScl1.scale(0.01); 
    }
    
    if (sprScl2.scaleX <= 2.0){
      sprScl2.setScale(sprScl2.scaleX * 1.02);
    }
    
    if (sprScl3.width <= 70){
      sprScl3.setSize(sprScl3.width + 0.1, sprScl3.height + 0.1);
    }
    
    if (spriteAll.scaleX <= 3.0){
      spriteAll.scale(0.08);
    }
    
    spriteAll
      ..rotate(3.0)
      ..setColorValues( colorRandom.nextDouble() , colorRandom.nextDouble(), colorRandom.nextDouble(), 1.0);
    
    batch.begin();
      sprRot1.draw(batch);
      sprRot2.draw(batch);
      sprRot3.draw(batch);
      sprRot4.draw(batch);
      sprRot5.draw(batch);
      sprRot6.draw(batch);
  
      sprScl1.draw(batch);
      sprScl2.draw(batch);
      sprScl3.draw(batch);
      
      spriteAll.draw(batch);
      
      fps.draw(batch, "Fps: ${Glib.graphics.fps}", 5.0, 5.0);
    batch.end();
    
    if (accum >= 2.0)
      accum = 0.0;
  }
  
  dispose(){
    sprRot1.texture.dispose();
    batch.dispose();
    fps.dispose();
  }
  
  String get name => 'Sprite transform tests';
}

