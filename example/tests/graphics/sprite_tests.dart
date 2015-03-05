part of glib.tests;

class SpriteRotationTest extends Test{
  
  SpriteBatch batch;
  Sprite sprite1, sprite2, sprite3, sprite4, sprite5, sprite6, sprite7;
  Font fps;
  double accum = 0.0;
  
  SpriteRotationTest():super("Texture test");
  
  create(){    
    var texture = new Texture.from("assets/head.png");
    sprite1 = new Sprite(texture, 0, 0, 64, 64);
    sprite2 = new Sprite(texture, 0, 0, 64, 64);
    sprite3 = new Sprite(texture, 0, 0, 64, 64);
    sprite4 = new Sprite(texture, 0, 0, 64, 64);
    sprite5 = new Sprite(texture, 0, 0, 64, 64);
    sprite6 = new Sprite(texture, 0, 0, 64, 64);
    sprite7 = new Sprite(texture, 0, 0, 64, 64);
    batch = new SpriteBatch();
    fps = new Font();
  }
  
  render(){
    super.render();
    
    accum += Glib.graphics.deltaTime;
            
    // sprite1 tests rotation
    sprite1
      ..rotate(1.0)
      ..setPosition(10.0,  10.0);
    
    sprite2
      ..rotate(-1.0)
      ..setPosition(45.0, 10.0 );
    
    sprite3
      ..rotate90(true)
      ..setPosition(80.0, 10.0 );
    
    sprite4
      ..rotate90(false)
      ..setPosition(115.0, 10.0 );
    
  // fixed rotation
    sprite5
      ..rotation = 45.0
      ..setPosition(140.0, 10.0 );
    
    sprite6
      ..rotation = -45.0
      ..setPosition(175.0, 10.0 );
    
    sprite7.setPosition(20.0, 180.0 ); //unchanged sprite
    
    
    batch.begin();
      sprite1.draw(batch);
      sprite2.draw(batch);
      sprite3.draw(batch);
      sprite4.draw(batch);
      sprite5.draw(batch);
      sprite6.draw(batch);
    batch.end();
  }
  
  dispose(){
    sprite1.texture.dispose();
    batch.dispose();
  }
  
  String get name => 'Sprite rotation test';
}