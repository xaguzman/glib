part of glib.tests;

class OrthographicCameraTest extends Test{
 
  Texture texture;
  OrthographicCamera camera;
  double cameraDelta;
    
  OrthographicCameraTest(gl):super(gl){
    cameraDelta = 2.0;
  }
  
  init(){
    texture = new Texture.from('assets/spritesheet-body.png');
    camera = new OrthographicCamera()..setToOrtho();
    
  }
    
  render(){
    var batch = Test.batch;
    camera.update();
    batch.projection.setFrom(camera.combined);
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