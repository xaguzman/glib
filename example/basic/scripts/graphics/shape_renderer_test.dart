part of glib.tests;

class ShapeRendererTest extends Test{

  ShapeRendererTest() : super('Shape Renderer test');

  ShapeRenderer shapeRenderer;
  OrthographicCamera cam;

  @override
  void create() {
    cam = new OrthographicCamera()..setToOrtho();
    shapeRenderer = new ShapeRenderer();
  }

  @override
  void render(){
    super.render();
    cam.update();
    shapeRenderer
      ..projectionMatrix.setMatrix(cam.combined)
      ..begin(ShapeType.Filled)
      ..setColorValues(1.0, 1.0, 1.0, 1.0)
      ..rect(3.0, 3.0, 100.0, 100.0)
      ..setColorValues(1.0, 0.0, 0.0 , 1.0)
      ..circle(53.0, 180.0, 50.0)
      ..end();
  }

  @override
  void dispose() {

  }
}