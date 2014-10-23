part of glib.input;

/** 
 * Interface to the input facilities. This allows polling the state of the keyboard and mouse.
 * Instead of polling for events, one can process all input in an event-driven by setting the [handler] (see [InputHandler]) 
 * 
 * Keyboard keys are translated to the constants in [KeyCode], while mouse buttons make reference to [Buttons] to provided the mouse clicked button
 */
abstract class Input{
  
  /// The current mouse position over the x-axis in screen coordinates. The screen origin is the top left corner.
  int get x;
  
  /// The difference between the current and the last mouse position on the x-axis.
  int get deltaX;
  
  /// The current mouse position in screen coordinates. The screen origin is the top left corner.
  int get y;

  /// The difference between the current and the last mouse position on the x-axis.
  int get deltaY;
  
  /// whether the screen is currently being clicked
  bool get isClicked;
  
  /// whether a new mouse down event just occurred
  bool get justClicked;
  
  /// wether the passed in mouse [Button] is pressed
  bool isButtonPressed(int button);

  /// wether the [keycode] is pressed. For a list of keys, you can see [KeyCode].
  /// if no keycode is specified, this will check if any key is pressed
  bool isKeyPressed([int keycode]);
  
  /// whether the [keycode] has just been pressed
  /// if no keycode is specified, this will check if any key was just pressed
  bool isKeyJustPressed([int keycode]);
  
  InputHandler handler;
  
  /// set to true to not allow the mouse to leave your application's canvas
  bool catchCursor;
}

///mouse buttons
class Buttons{
  static const int LEFT = 0;
  static const int RIGHT = 2;
  static const int MIDDLE = 1;
}

/// the default implementation for [input]. It will get mouse input from a canvas, and keyboard input from the window
class CanvasInput implements Input{
  
  final CanvasElement canvas;
  bool justTouched;
  List<bool> _touched = new List(20);
  List<int> _touchX = new List(20);
  List<int> _touchY = new List(20);
  List<int> _deltaX = new List(20);
  List<int> _deltaY = new List(20);
  Set<int> pressedButtons = new Set();
  int pressedKeyCount = 0;
  List<bool> pressedKeys = new List(256);
  bool keyJustPressed = false;
  List<bool> justPressedKeys = new List(256);
  InputHandler handler;
  String lastKeyCharPressed;
  double keyRepeatTimer;
  int currentEventTimeStamp;
  bool hasFocus = true;
  bool catchCursor;
  DateTime _dt;
  
  CanvasInput(this.canvas, {this.catchCursor : true}){
    _dt = new DateTime.now();
    attachEvents();
  }
  
  void reset () {
    justTouched = false;
    if (keyJustPressed) {
      keyJustPressed = false;
      for (int i = 0; i < justPressedKeys.length; i++) {
        justPressedKeys[i] = false;
      }
    }
  }
  
  attachEvents(){
    canvas.onMouseDown.listen( canvasMouseListener );
    canvas.onMouseUp.listen( canvasMouseListener );
    canvas.onMouseMove.listen( canvasMouseListener );
    canvas.onMouseWheel.listen( canvasMouseListener );
    
    canvas.onKeyDown.listen(canvasKeyListener);
    canvas.onKeyUp.listen(canvasKeyListener);
    canvas.onKeyPress.listen(canvasKeyListener);
    
    canvas.onTouchStart.listen( canvasTouchListener );
    canvas.onTouchMove.listen( canvasTouchListener );
    canvas.onTouchCancel.listen( canvasTouchListener );
    canvas.onTouchEnd.listen( canvasTouchListener );
  }
  
  canvasTouchListener(TouchEvent e){
    if (e.type == "touchstart") {
      this.justTouched = true;
      var touches = e.changedTouches;
      for (int i = 0, j = touches.length; i < j; i++) {
        Touch touch = touches[i];
        int touchId = touch.identifier;
        _touched[touchId] = true;
        _touchX[touchId] = _getTouchRelativeX(touch, canvas);
        _touchY[touchId] = _getTouchRelativeY(touch, canvas);
        _deltaX[touchId] = 0;
        _deltaY[touchId] = 0;
        if (handler != null) {
          handler.mouseDown(_touchX[touchId], _touchY[touchId], Buttons.LEFT);
        }       
      }
      
      currentEventTimeStamp = _dt.millisecondsSinceEpoch;
      e.preventDefault();
    }
    if (e.type == "touchmove") {
      var touches = e.changedTouches;
      for (int i = 0, j = touches.length; i < j; i++) {
        Touch touch = touches[i];
        int touchId = touch.identifier;
        _deltaX[touchId] = _getTouchRelativeX(touch, canvas) - _touchX[touchId];
        _deltaY[touchId] = _getTouchRelativeY(touch, canvas) - _touchY[touchId];
        _touchX[touchId] = _getTouchRelativeX(touch, canvas);
        _touchY[touchId] = _getTouchRelativeY(touch, canvas);
        if (handler != null) {
          handler.mouseDragged(_touchX[touchId], _touchY[touchId], Buttons.LEFT);
        }
      }
      currentEventTimeStamp = _dt.millisecondsSinceEpoch;
      e.preventDefault();
    }
    if (e.type == "touchcancel"){
      var touches = e.changedTouches;
      for (int i = 0, j = touches.length; i < j; i++) {
        Touch touch = touches[i];
        int touchId = touch.identifier;
        _touched[touchId] = false;
        _deltaX[touchId] = _getTouchRelativeX(touch, canvas) - _touchX[touchId];
        _deltaY[touchId] = _getTouchRelativeY(touch, canvas) - _touchY[touchId];       
        _touchX[touchId] = _getTouchRelativeX(touch, canvas);
        _touchY[touchId] = _getTouchRelativeY(touch, canvas);
        if (handler != null) {
          handler.mouseUp(_touchX[touchId], _touchY[touchId], Buttons.LEFT);
        }         
      }
      this.currentEventTimeStamp = _dt.millisecondsSinceEpoch;
      e.preventDefault();
    }
    if (e.type == "touchend") {     
      var touches = e.changedTouches;
      for (int i = 0, j = touches.length; i < j; i++) {
        Touch touch = touches[i];
        int touchId = touch.identifier;
        _touched[touchId] = false;
        _deltaX[touchId] = _getTouchRelativeX(touch, canvas) - _touchX[touchId];
        _deltaY[touchId] = _getTouchRelativeY(touch, canvas) - _touchY[touchId];       
        _touchX[touchId] = _getTouchRelativeX(touch, canvas);
        _touchY[touchId] = _getTouchRelativeY(touch, canvas);
        if (handler != null) {
          handler.mouseUp(_touchX[touchId], _touchY[touchId], Buttons.LEFT);
        }         
      }
      this.currentEventTimeStamp = _dt.millisecondsSinceEpoch;
      e.preventDefault();
    }
  }
  
  canvasKeyListener(KeyEvent e){
    if (e.type == "keydown" && hasFocus) {
          var code = e.keyCode;
          if (code == KeyCode.DELETE) {
            e.preventDefault();
            if (handler != null) {
              handler.keyDown(code);
              handler.keyTyped(code);
            }
          } else {
            if (!pressedKeys[code]) {
              pressedKeyCount++;
              pressedKeys[code] = true;
              keyJustPressed = true;
              justPressedKeys[code] = true;
              if (handler != null) {
                handler.keyDown(code);
              }
            }
          }
        }

        if (e.type == "keypress" && hasFocus) {
          if (handler != null) 
            handler.keyTyped(e.keyCode);
        }

        if (e.type == "keyup" && hasFocus) {
          int code = e.keyCode;
          if (pressedKeys[code]) {
            pressedKeyCount--;
            pressedKeys[code] = false;
          }
          if (handler != null) {
            handler.keyUp(code);
          }
        }
  }
  
  canvasMouseListener(MouseEvent event){
    if (event is WheelEvent){
      event.stopPropagation();
      int val = event.wheelDeltaY;
      if (val == null || val == 0) {
        val = -event.detail;
      }
      
      // reverse detail for firefox
//      val = Math.max(-1, Math.min(1, val));
      val = val.clamp(-1, 1);

      if (handler != null)
        handler.mouseScrolled(val);
      currentEventTimeStamp = _dt.millisecondsSinceEpoch;
    }
    
    if(event.type == 'mousedown'){
      justTouched = true;
      _touched[0] = true;
      pressedButtons.add(event.button);
      _deltaX[0] = 0;
      _deltaY[0] = 0;
      
      if(catchCursor){
        _touchX[0] = event.movement.x;
        _touchY[0] = event.movement.y;
      }else{
        _touchX[0] = _getMouseRelativeX(event, canvas).toInt();
        _touchY[0] = _getMouseRelativeY(event, canvas).toInt();
      }
      
      currentEventTimeStamp = _dt.millisecondsSinceEpoch;
      if (handler != null) 
        handler.mouseDown(_touchX[0], _touchY[0], event.button);
    }
    
    if (event.type == "mousemove") {
      if (catchCursor) {
        _deltaX[0] = event.movement.x;
        _deltaY[0] = event.movement.y;
        _touchX[0] += event.movement.x;
        _touchY[0] += event.movement.y;
      }else {
        _deltaX[0] = _getMouseRelativeX(event, canvas) - _touchX[0];
        _deltaY[0] = _getMouseRelativeY(event, canvas) - _touchY[0];
        _touchX[0] = _getMouseRelativeX(event, canvas);
        _touchY[0] = _getMouseRelativeY(event, canvas);
      }
      this.currentEventTimeStamp = _dt.millisecondsSinceEpoch;
      if (handler != null) {
        if (_touched[0])
          handler.mouseDragged(_touchX[0], _touchY[0], event.button);
        else
          handler.mouseMoved(_touchX[0], _touchY[0]);
      }
    }
    
    if (event.type == "mouseup") {
      if (!_touched[0]) 
        return;
      
      this.pressedButtons.remove(event.button);
      this._touched[0] = pressedButtons.length > 0;
      if (catchCursor) {
        _deltaX[0] = event.movement.x;
        _deltaY[0] = event.movement.y;
        _touchX[0] += event.movement.x;
        _touchY[0] += event.movement.y;
      } else {
        _deltaX[0] = _getMouseRelativeX(event, canvas) - _touchX[0];
        _deltaY[0] = _getMouseRelativeY(event, canvas) - _touchY[0];
        _touchX[0] = _getMouseRelativeX(event, canvas);
        _touchY[0] = _getMouseRelativeY(event, canvas);
      }
      this.currentEventTimeStamp = _dt.millisecondsSinceEpoch;
      this._touched[0] = false;
      if (handler != null) 
        handler.mouseUp(_touchX[0], _touchY[0], event.button);
      
    }
  }
  
  @override
  int get x => _touchX[0];
  
  @override
  int get deltaX => _deltaX[0];
  
  @override
  int get y => _touchY[0];
  
  @override
  int get deltaY => _deltaY[0];
  
  @override
  bool get isClicked => _touched[0];
  
  @override
  bool get justClicked => justTouched;
  
  @override
  bool isButtonPressed(int button) => button == Buttons.LEFT && _touched[0];
  
  @override 
  bool isKeyPressed([int keycode]){
    if (keycode == null)
      return pressedKeyCount > 0;
    
    return pressedKeys[keycode];
  }  
  
  @override
  bool isKeyJustPressed([int keycode]){
    if (keycode == null)
      return keyJustPressed;
    
    return justPressedKeys[keycode];
  }
  
  int _getMouseRelativeX(MouseEvent e, Element target) => e.client.x - target.getBoundingClientRect().left;
  int _getMouseRelativeY(MouseEvent e, Element target) => e.client.y - target.getBoundingClientRect().top;
  
  int _getTouchRelativeX(Touch e, Element target) => e.client.x - target.getBoundingClientRect().left;
  int _getTouchRelativeY(Touch e, Element target) => e.client.y - target.getBoundingClientRect().top;
}
