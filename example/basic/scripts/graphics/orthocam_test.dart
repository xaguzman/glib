part of glib.tests;

class OrthographicCameraTest extends Test{
 
  Texture texture;
  OrthographicCamera camera;
  double cameraDelta;
  SpriteBatch batch;
    
  OrthographicCameraTest():super("Orthographic camera test"){
    cameraDelta = 2.0;
  }
  
  create(){
    texture = new Texture.from('spritesheet-body.png');
    camera = new OrthographicCamera()..setToOrtho();
    batch = new SpriteBatch(); 
  }
    
  render(){
    super.render();
    camera.update();
    batch.projection.setMatrix(camera.combined);
    batch
      ..begin()
      ..drawTexture(texture, 50.0, 50.0)
      ..end();
    
    if(cameraDelta > 0.0 && camera.position.x > 600)
      cameraDelta *= -1;
    if(cameraDelta < 0.0 && camera.position.x < 10.0)
      cameraDelta *= -1;
    
    camera.position.x += cameraDelta;
  }
  
  dispose(){
    texture.dispose();
  }
  
  String get name=> "Orthographic Camera test";
}