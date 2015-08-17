part of glib.input;

/** 
 * Interface to the input facilities. This allows polling the state of the keyboard and mouse.
 * Instead of polling for events, one can process all input in an event-driven by setting the [processor] (see [InputProcessor]) 
 * 
 * Keyboard keys are translated to the constants in [KeyCode], while mouse buttons make reference to [Buttons] to provided the mouse clicked button
 */
abstract class Input extends Disposable{
  
  /// The current mouse position over the x-axis in screen coordinates. The screen origin is the top left corner.
  /// If no mouse is present, it represents the last touch 'x' coordinate on the screen
  int get x;
  
  /** Returns the x coordinate in screen coordinates of the given pointer. Pointers are indexed from 0 to n. The pointer id
     * identifies the order in which the fingers went down on the screen, e.g. 0 is the first finger, 1 is the second and so on.
     * When two fingers are touched down and the first one is lifted the second one keeps its index. If another finger is placed on
     * the touch screen the first free index will be used.
     * 
     * [pointer] the pointer id.
     * returns the x coordinate */
  int getX(int pointer);
  
  /// The difference between the current and the last pointer location on the x-axis.
  int get deltaX;
  
  ///The difference between the current and the last pointer location on the x-axis for the given pointer.
  int getDeltaX(int pointer);
  
  /// The current mouse position in screen coordinates. The screen origin is the top left corner
  /// If no mouse is present, it represents the last touch 'y' coordinate on the screen
  int get y;
  
  /** Returns the y coordinate in screen coordinates of the given pointer. Pointers are indexed from 0 to n. The pointer id
       * identifies the order in which the fingers went down on the screen, e.g. 0 is the first finger, 1 is the second and so on.
       * When two fingers are touched down and the first one is lifted the second one keeps its index. If another finger is placed on
       * the touch screen the first free index will be used.
       * 
       * [pointer] the pointer id.
       * return the y coordinate */
  int getY(int pointer);

  /// The difference between the current and the last mouse position on the y-axis.
  int get deltaY;
  
/// The difference between the current and the last mouse position on the y-axis.
  int getDeltaY(int pointer);
  
  /// whether the screen is currently being touched(clicked)
  bool get isTouched;
  
  /// whether a new touch down event just occurred
  bool get isJustTouched;
  
  /// wether the passed in mouse [Button] is pressed
  bool isButtonPressed(int button);

  /// wether the [keycode] is pressed. For a list of keys, you can see [KeyCode].
  /// if no keycode is specified, this will check if any key is pressed
  bool isKeyPressed([int keycode]);
  
  /// whether the [keycode] has just been pressed
  /// if no keycode is specified, this will check if any key was just pressed
  bool isKeyJustPressed([int keycode]);
  
  InputProcessor processor;
  
  /// set to true to not allow the mouse to leave your application's canvas
  bool catchCursor;
  
  /// gets the string representation of the given [KeyCode]
  String keyCodeToString(int keycode);
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
  List<bool> _touched = new List.filled(20, false);
  List<int> _touchX = new List.filled(20, 0);
  List<int> _touchY = new List.filled(20, 0);
  List<int> _deltaX = new List.filled(20, 0);
  List<int> _deltaY = new List.filled(20, 0);
  Set<int> pressedButtons = new Set();
  int pressedKeyCount = 0;
  List<bool> pressedKeys = new List.filled(256, false);
  bool keyJustPressed = false;
  List<bool> justPressedKeys = new List.filled(256, false);
  InputProcessor processor;
  String lastKeyCharPressed;
  double keyRepeatTimer;
  int currentEventTimeStamp;
  bool _hasFocus = true;
  bool catchCursor;
  Stopwatch _watch;
  List _eventSubscriptions = new List();
  
  
  CanvasInput(this.canvas, {this.catchCursor : false}){
    _watch = new Stopwatch();
    attachEvents();
    _watch.start();
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
    _eventSubscriptions.add( canvas.onMouseDown.listen( canvasMouseListener ) );
    _eventSubscriptions.add( document.onMouseDown.listen(canvasMouseListener) );
    _eventSubscriptions.add( canvas.onMouseUp.listen( canvasMouseListener )) ;
    _eventSubscriptions.add( canvas.onMouseMove.listen( canvasMouseListener ));
    _eventSubscriptions.add( canvas.onMouseWheel.listen( canvasMouseListener ));
    
//    canvas.onKeyDown.listen(canvasKeyListener);
//    canvas.onKeyUp.listen(canvasKeyListener);
//    canvas.onKeyPress.listen(canvasKeyListener);
    _eventSubscriptions.add( document.onKeyDown.listen(canvasKeyListener) );
    _eventSubscriptions.add( document.onKeyUp.listen(canvasKeyListener));
    _eventSubscriptions.add( document.onKeyPress.listen(canvasKeyListener));
    
    _eventSubscriptions.add( canvas.onTouchStart.listen( canvasTouchListener ));
    _eventSubscriptions.add( canvas.onTouchMove.listen( canvasTouchListener ));
    _eventSubscriptions.add( canvas.onTouchCancel.listen( canvasTouchListener ));
    _eventSubscriptions.add( canvas.onTouchEnd.listen( canvasTouchListener ));
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
        if (processor != null) {
          processor.touchDown(_touchX[touchId], _touchY[touchId], Buttons.LEFT);
        }       
      }
      
      currentEventTimeStamp = _watch.elapsedMilliseconds;
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
        if (processor != null) {
          processor.touchDragged(_touchX[touchId], _touchY[touchId], Buttons.LEFT);
        }
      }
      currentEventTimeStamp = _watch.elapsedMilliseconds;
      e.preventDefault();
    }
    if (e.type == "touchend" || e.type == "touchcancel"){
      var touches = e.changedTouches;
      for (int i = 0, j = touches.length; i < j; i++) {
        Touch touch = touches[i];
        int touchId = touch.identifier;
        _touched[touchId] = false;
        _deltaX[touchId] = _getTouchRelativeX(touch, canvas) - _touchX[touchId];
        _deltaY[touchId] = _getTouchRelativeY(touch, canvas) - _touchY[touchId];       
        _touchX[touchId] = _getTouchRelativeX(touch, canvas);
        _touchY[touchId] = _getTouchRelativeY(touch, canvas);
        if (processor != null) {
          processor.touchUp(_touchX[touchId], _touchY[touchId], Buttons.LEFT);
        }         
      }
      this.currentEventTimeStamp = _watch.elapsedMilliseconds;
      e.preventDefault();
    }
    _watch.reset();
  }
  
  canvasKeyListener(KeyboardEvent e){
    if (e.type == "keydown" && _hasFocus) {
          int code = e.keyCode;
          String key = keyCodeToString(code);
          if (code == KeyCode.BACKSPACE || code == KeyCode.F5 ) {
            e.preventDefault();
          }
          
          if (!pressedKeys[code]) {
            pressedKeyCount++;
            pressedKeys[code] = true;
            keyJustPressed = true;
            justPressedKeys[code] = true;
            if (processor != null) {
              processor.keyDown(code);
              processor.keyTyped(key);
            }
          }
        }

        if (e.type == "keyup" && _hasFocus) {
          int code = e.keyCode;
          if (pressedKeys[code]) {
            pressedKeyCount--;
            pressedKeys[code] = false;
          }
          if (processor != null) {
            processor.keyUp(code);
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

      if (processor != null)
        processor.mouseScrolled(val);
      currentEventTimeStamp = _watch.elapsedMilliseconds;
    }
    
    if(event.type == 'mousedown'){
      
      if (event.target != canvas || _touched[0]) {
        int mouseX = _getMouseRelativeX(event, canvas);
        int mouseY = _getMouseRelativeX(event, canvas);
        if (mouseX < canvas.clientLeft || 
            mouseX > canvas.clientLeft + canvas.clientWidth || 
            mouseY < canvas.clientTop || 
            mouseY > canvas.clientTop + canvas.clientHeight ) {
          _hasFocus = false;
        }
        return;
      }
      
      _hasFocus = true;
      justTouched = true;
      _touched[0] = true;
      pressedButtons.add(event.button);
      _deltaX[0] = 0;
      _deltaY[0] = 0;
      
      if(catchCursor){
        _touchX[0] = event.offset.x;
        _touchY[0] = canvas.height - event.offset.y;
      }else{
        _touchX[0] = _getMouseRelativeX(event, canvas).toInt();
        _touchY[0] = _getMouseRelativeY(event, canvas).toInt();
      }
      
      currentEventTimeStamp = _watch.elapsedMilliseconds;
      if (processor != null) 
        processor.touchDown(_touchX[0], _touchY[0], event.button);
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
      this.currentEventTimeStamp = _watch.elapsedMilliseconds;
      if (processor != null) {
        if (_touched[0])
          processor.touchDragged(_touchX[0], _touchY[0], event.button);
        else
          processor.mouseMoved(_touchX[0], _touchY[0]);
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
      this.currentEventTimeStamp = _watch.elapsedMilliseconds;
      this._touched[0] = false;
      if (processor != null) 
        processor.touchUp(_touchX[0], _touchY[0], event.button);
      
    }
    _watch.reset();
  }
  
  @override
  int get x => getX(0);
  
  @override 
  getX(int pointer) => _touchX[pointer];
  
  @override
  int get deltaX => getDeltaX(0);
  
  @override
  int getDeltaX(int pointer) => _deltaX[pointer];
  
  @override
  int get y => getY(0);
  
  @override 
  getY(int pointer) => _touchY[pointer];
  
  @override
  int get deltaY => getDeltaY(0);
  
  @override
  int getDeltaY(int pointer) => _deltaY[pointer];
  
  @override
  bool get isTouched => _touched[0];
  
  @override
  bool get isJustTouched => justTouched;
  
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
  
  @override
  void dispose(){
    _eventSubscriptions.forEach( (x) => x.cancel());
  }
  
  @override
  String keyCodeToString(int keyCode) => 
      _keyNames.containsKey(keyCode) ? _keyNames[keyCode] : '';
  
  int _getMouseRelativeX(MouseEvent e, Element target) => e.client.x - target.offset.left;
  int _getMouseRelativeY(MouseEvent e, Element target) => canvas.height - ( e.client.y - target.offset.top);
  
  int _getTouchRelativeX(Touch e, Element target) => e.client.x - target.offset.left;
  int _getTouchRelativeY(Touch e, Element target) => canvas.height - (e.client.y - target.offset.top);
}





Map<int, String> _keyNames = new Map.fromIterables(
      [KeyCode.WIN_KEY_FF_LINUX,
       KeyCode.MAC_ENTER,
       KeyCode.BACKSPACE,
       KeyCode.TAB,
       KeyCode.NUM_CENTER,
       KeyCode.ENTER,
       KeyCode.SHIFT,
       KeyCode.CTRL,
       KeyCode.ALT,
       KeyCode.PAUSE,
       KeyCode.CAPS_LOCK,
       KeyCode.ESC,
       KeyCode.SPACE,
       KeyCode.PAGE_UP,
       KeyCode.PAGE_DOWN,
       KeyCode.END,
       KeyCode.HOME,
       KeyCode.LEFT,
       KeyCode.UP,
       KeyCode.RIGHT,
       KeyCode.DOWN,
       KeyCode.NUM_NORTH_EAST,
       KeyCode.NUM_SOUTH_EAST,
       KeyCode.NUM_SOUTH_WEST,
       KeyCode.NUM_NORTH_WEST,
       KeyCode.NUM_WEST,
       KeyCode.NUM_NORTH,
       KeyCode.NUM_EAST,
       KeyCode.NUM_SOUTH,
       KeyCode.PRINT_SCREEN,
       KeyCode.INSERT,
       KeyCode.NUM_INSERT,
       KeyCode.DELETE,
       KeyCode.NUM_DELETE,
       KeyCode.ZERO,
       KeyCode.ONE,
       KeyCode.TWO,
       KeyCode.THREE,
       KeyCode.FOUR,
       KeyCode.FIVE,
       KeyCode.SIX,
       KeyCode.SEVEN,
       KeyCode.EIGHT,
       KeyCode.NINE,
       KeyCode.FF_SEMICOLON,
       KeyCode.FF_EQUALS,
       KeyCode.QUESTION_MARK,
       KeyCode.A,
       KeyCode.B,
       KeyCode.C,
       KeyCode.D,
       KeyCode.E,
       KeyCode.F,
       KeyCode.G,
       KeyCode.H,
       KeyCode.I,
       KeyCode.J,
       KeyCode.K,
       KeyCode.L,
       KeyCode.M,
       KeyCode.N,
       KeyCode.O,
       KeyCode.P,
       KeyCode.Q,
       KeyCode.R,
       KeyCode.S,
       KeyCode.T,
       KeyCode.U,
       KeyCode.V,
       KeyCode.W,
       KeyCode.X,
       KeyCode.Y,
       KeyCode.Z,
       KeyCode.META,
       KeyCode.WIN_KEY_LEFT,
       KeyCode.WIN_KEY_RIGHT,
       KeyCode.CONTEXT_MENU,
       KeyCode.NUM_ZERO,
       KeyCode.NUM_ONE,
       KeyCode.NUM_TWO,
       KeyCode.NUM_THREE,
       KeyCode.NUM_FOUR,
       KeyCode.NUM_FIVE,
       KeyCode.NUM_SIX,
       KeyCode.NUM_SEVEN,
       KeyCode.NUM_EIGHT,
       KeyCode.NUM_NINE,
       KeyCode.NUM_MULTIPLY,
       KeyCode.NUM_PLUS,
       KeyCode.NUM_MINUS,
       KeyCode.NUM_PERIOD,
       KeyCode.NUM_DIVISION,
       KeyCode.F1,
       KeyCode.F2,
       KeyCode.F3,
       KeyCode.F4,
       KeyCode.F5,
       KeyCode.F6,
       KeyCode.F7,
       KeyCode.F8,
       KeyCode.F9,
       KeyCode.F10,
       KeyCode.F11,
       KeyCode.F12,
       KeyCode.NUMLOCK,
       KeyCode.SCROLL_LOCK,
       KeyCode.FIRST_MEDIA_KEY,
       KeyCode.LAST_MEDIA_KEY,
       KeyCode.SEMICOLON,
       KeyCode.DASH,
       KeyCode.EQUALS,
       KeyCode.COMMA,
       KeyCode.PERIOD,
       KeyCode.SLASH,
       KeyCode.APOSTROPHE,
       KeyCode.TILDE,
       KeyCode.SINGLE_QUOTE,
       KeyCode.OPEN_SQUARE_BRACKET,
       KeyCode.BACKSLASH,
       KeyCode.CLOSE_SQUARE_BRACKET,
       KeyCode.WIN_KEY,
       KeyCode.MAC_FF_META,
       KeyCode.WIN_IME,
       KeyCode.UNKNOWN ],
       
       ['Win', //KeyCode.WIN_KEY_FF_LINUX,
        'Enter', //KeyCode.MAC_ENTER,
        'Backspace', //KeyCode.BACKSPACE,
        'Tab', //KeyCode.TAB,
        'Num center', //KeyCode.NUM_CENTER,
        'Enter', //KeyCode.ENTER,
        'Shift', //KeyCode.SHIFT,
        'Ctrl', //KeyCode.CTRL,
        'Alt', //KeyCode.ALT,
        'Pause', //KeyCode.PAUSE,
        'Caps lock', //KeyCode.CAPS_LOCK,
        'Escape', //KeyCode.ESC,
        'Space', //KeyCode.SPACE,
        'Page up', //KeyCode.PAGE_UP,
        'Page down', //KeyCode.PAGE_DOWN,
        'End', //KeyCode.END,
        'Home', //KeyCode.HOME,
        'Left', //KeyCode.LEFT,
        'Up', //KeyCode.UP,
        'Right', //KeyCode.RIGHT,
        'Down', //KeyCode.DOWN,
        'Numpad 9', //KeyCode.NUM_NORTH_EAST,
        'Numpad 3', //KeyCode.NUM_SOUTH_EAST,
        'Numpad 1', //KeyCode.NUM_SOUTH_WEST,
        'Numpad 7', //KeyCode.NUM_NORTH_WEST,
        'Numpad 4', //KeyCode.NUM_WEST,
        'Numpad 8', //KeyCode.NUM_NORTH,
        'Numpad 6', //KeyCode.NUM_EAST,
        'Numpad 2', //KeyCode.NUM_SOUTH,
        'PrtSc', //KeyCode.PRINT_SCREEN,
        'Insert', //KeyCode.INSERT,
        'Insert', //KeyCode.NUM_INSERT,
        'Delete', //KeyCode.DELETE,
        'Numpad .', //KeyCode.NUM_DELETE,
        '0', //KeyCode.ZERO,
        '1', //KeyCode.ONE,
        '2', //KeyCode.TWO,
        '3', //KeyCode.THREE,
        '4', //KeyCode.FOUR,
        '5', //KeyCode.FIVE,
        '6', //KeyCode.SIX,
        '7', //KeyCode.SEVEN,
        '8', //KeyCode.EIGHT,
        '9', //KeyCode.NINE,
        ';', //KeyCode.FF_SEMICOLON,
        '=', //KeyCode.FF_EQUALS,
        '?', //KeyCode.QUESTION_MARK,
        'A', //KeyCode.A,
        'B', //KeyCode.B,
        'C', //KeyCode.C,
        'D', //KeyCode.D,
        'E', //KeyCode.E,
        'F', //KeyCode.F,
        'G', //KeyCode.G,
        'H', //KeyCode.H,
        'I', //KeyCode.I,
        'J', //KeyCode.J,
        'K', //KeyCode.K,
        'L', //KeyCode.L,
        'M', //KeyCode.M,
        'N', //KeyCode.N,
        'O', //KeyCode.O,
        'P', //KeyCode.P,
        'Q', //KeyCode.Q,
        'R', //KeyCode.R,
        'S', //KeyCode.S,
        'T', //KeyCode.T,
        'U', //KeyCode.U,
        'V', //KeyCode.V,
        'W', //KeyCode.W,
        'X', //KeyCode.X,
        'Y', //KeyCode.Y,
        'Z', //KeyCode.Z,
        'Meta', //KeyCode.META,
        'Left win', //KeyCode.WIN_KEY_LEFT,
        'Right win', //KeyCode.WIN_KEY_RIGHT,
        'Context menu', //KeyCode.CONTEXT_MENU,
        'Numpad 0', //KeyCode.NUM_ZERO,
        'Numpad 1', //KeyCode.NUM_ONE,
        'Numpad 2', //KeyCode.NUM_TWO,
        'Numpad 3', //KeyCode.NUM_THREE,
        'Numpad 4', //KeyCode.NUM_FOUR,
        'Numpad 5', //KeyCode.NUM_FIVE,
        'Numpad 6', //KeyCode.NUM_SIX,
        'Numpad 7', //KeyCode.NUM_SEVEN,
        'Numpad 8', //KeyCode.NUM_EIGHT,
        'Numpad 9', //KeyCode.NUM_NINE,
        'Numpad *', //KeyCode.NUM_MULTIPLY,
        'Numpad +', //KeyCode.NUM_PLUS,
        'Numpad -', //KeyCode.NUM_MINUS,
        'Numpad .', //KeyCode.NUM_PERIOD,
        'Numpad /', //KeyCode.NUM_DIVISION,
        'F1', //KeyCode.F1,
        'F2', //KeyCode.F2,
        'F3', //KeyCode.F3,
        'F4', //KeyCode.F4,
        'F5', //KeyCode.F5,
        'F6', //KeyCode.F6,
        'F7', //KeyCode.F7,
        'F8', //KeyCode.F8,
        'F9', //KeyCode.F9,
        'F10', //KeyCode.F10,
        'F11', //KeyCode.F11,
        'F12', //KeyCode.F12,
        'Numlock', //KeyCode.NUMLOCK,
        'Scroll lock', //KeyCode.SCROLL_LOCK,
        '', //KeyCode.FIRST_MEDIA_KEY,
        '', //KeyCode.LAST_MEDIA_KEY,
        ';', //KeyCode.SEMICOLON,
        '-', //KeyCode.DASH,
        '=', //KeyCode.EQUALS,
        ',', //KeyCode.COMMA,
        '.', //KeyCode.PERIOD,
        '/', //KeyCode.SLASH,
        'Apostrophe', //KeyCode.APOSTROPHE,
        'Tilde', //KeyCode.TILDE,
        "'", //KeyCode.SINGLE_QUOTE,
        '[', //KeyCode.OPEN_SQUARE_BRACKET,
        '\\', //KeyCode.BACKSLASH,
        ']', //KeyCode.CLOSE_SQUARE_BRACKET,
        'Win', //KeyCode.WIN_KEY,
        'FF Meta', //KeyCode.MAC_FF_META,
        'Win ime', //KeyCode.WIN_IME,
        'Unknown', //KeyCode.UNKNOWN
        ]);