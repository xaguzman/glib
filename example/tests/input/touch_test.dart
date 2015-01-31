part of glib.tests;

class TouchTest extends Test{
  
  Font font;
  SpriteBatch _batch;
  MyInputHandler _handler;
  
  TouchTest():super("Touch test");
  
  create(){
    font = new Font();
    _batch = new SpriteBatch();
    _handler = new MyInputHandler();
    Glib.input.processor = _handler;
  }
  
  pause(){}
  
  resume(){}
  
  resize(width, height){
 
  }
  
  render(){
//    super.render();
    Glib.gl.clearColor(0, 0, 0, 1);
    Glib.gl.clear(GL.COLOR_BUFFER_BIT);
    _batch.begin();
    
    font.draw(_batch, "Mouse position: ${_handler.mousePos}", 20.0, 5.0);
    font.draw(_batch, "Last mouse down: ${_handler.vMousedown}", 20.0, 20.0);
    font.draw(_batch, "Last mouse up: ${_handler.vMouseUp}", 20.0, 35.0);
    font.draw(_batch, "Mouse drag: ${_handler.mouseDrag}", 20.0, 50.0);
    
    
    _batch.end();
  }
  
  dispose(){
    font.dispose();
    _handler = null;
  }
}

class MyInputHandler extends EmptyProcessor{
  Vector2 vMousedown = new Vector2.zero();
  Vector2 vMouseUp = new Vector2.zero();
  Vector2 mousePos = new Vector2.zero();
  Vector2 mouseDrag = new Vector2.zero();
  
  @override
  bool mouseDown(int screenX, int screenY, int button) {
    
    vMousedown.setValues(screenX.toDouble(), screenY.toDouble());
    
    return true;
  }

  @override
  bool mouseUp(int screenX, int screenY, int button) {
    vMouseUp.setValues(screenX.toDouble(), screenY.toDouble());
    
    return true;
  }
  
  @override
  bool mouseMoved(int screenX, int screenY){
    mousePos.setValues(screenX.toDouble(), screenY.toDouble());
    
    return true;
  }
  
  @override 
  bool mouseDragged(int screenX, int screenY, int button){
    mouseDrag.setValues(screenX.toDouble(), screenY.toDouble());
    return true;
  }
}