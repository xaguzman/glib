part of glib.tests;

class KeyboardTest extends Test{
  
  Font font;
  SpriteBatch _batch;
  KbdInputHandler _handler;
  
  KeyboardTest():super("Keyboard test");
  
  create(){
    font = new Font();
    _batch = new SpriteBatch();
    _handler = new KbdInputHandler();
    Glib.input.processor = _handler;
  }
  
  pause(){}
  
  resume(){}
  
  resize(width, height){
 
  }
  
  render(){
    super.render();
    _batch.begin();
    
    font
      ..draw(_batch, "Last key up: ${_handler.lastKeyUp}", 20.0, 5.0)
      ..draw(_batch, "Last key down: ${_handler.lastKeyDown}", 20.0, 20.0)
      ..draw(_batch, "Last key typed: ${_handler.lastKeyTyped}", 20.0, 35.0);
      
//      ..draw(_batch, "keycode down: ${_handler.keydown}", 20.0, 80.0)
//      ..draw(_batch, "keycode typed: ${_handler.keytyped}", 20.0, 95.0);
    _batch.end();
  }
  
  dispose(){
    font.dispose();
    _handler = null;
  }
}

class KbdInputHandler extends EmptyProcessor{
  String lastKeyDown, lastKeyUp, lastKeyTyped;
//  int keydown, keyup, keytyped;
  
  bool keyDown(int keycode){
    lastKeyDown = Glib.input.keyCodeToString(keycode);
//    keydown = keycode;
    return true;
  }
  
  bool keyUp(int keycode){
    lastKeyUp = Glib.input.keyCodeToString(keycode);
//    keyup = keycode;
    return true;
  }
  
  bool keyTyped(String key){
    lastKeyTyped = key;
    return true;
  }
}