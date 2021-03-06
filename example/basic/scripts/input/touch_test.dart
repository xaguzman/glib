part of glib.tests;

class TouchTest extends Test{
  
  BitmapFont font;
  SpriteBatch _batch;
  MyInputHandler _handler;
  
  TouchTest():super("Touch test");
  
  create(){
    font = new BitmapFont();
    _batch = new SpriteBatch();
    _handler = new MyInputHandler();
    Glib.input.processor = _handler;
  }
    
  resize(width, height){
 
  }
  
  render(){
    super.render();
    _batch.begin();
    
    font.draw(_batch, "Mouse position: ${_handler.mousePos}", x: 20.0, y: 5.0);
    font.draw(_batch, "Last mouse down: ${_handler.vMousedown}", x: 20.0, y: 20.0);
    font.draw(_batch, "Last mouse up: ${_handler.vMouseUp}", x: 20.0, y: 35.0);
    font.draw(_batch, "Mouse drag: ${_handler.mouseDrag}", x: 20.0, y: 50.0);
    
    
    _batch.end();
  }
  
  dispose(){
    font.dispose();
    _handler = null;
  }
}

class MyInputHandler extends EmptyProcessor{
  Vector2 vMousedown = new Vector2();
  Vector2 vMouseUp = new Vector2();
  Vector2 mousePos = new Vector2();
  Vector2 mouseDrag = new Vector2();
  
  @override
  bool touchDown(int screenX, int screenY, int button) {
    vMousedown.setValues(screenX.toDouble(), screenY.toDouble());
    
    return true;
  }

  @override
  bool touchUp(int screenX, int screenY, int button) {
    vMouseUp.setValues(screenX.toDouble(), screenY.toDouble());
    
    return true;
  }
  
  @override
  bool mouseMoved(int screenX, int screenY){
    mousePos.setValues(screenX.toDouble(), screenY.toDouble());
    
    return true;
  }
  
  @override 
  bool touchDragged(int screenX, int screenY, int button){
    mouseDrag.setValues(screenX.toDouble(), screenY.toDouble());
    return true;
  }
}