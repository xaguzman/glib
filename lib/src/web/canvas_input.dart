part of glib.web;

/// the default implementation for [Input]. It will get mouse input from a canvas, and keyboard input from the window
class CanvasInput implements Input{

  static const int MAX_TOUCHES = 20;
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

      int val = event.deltaY;
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
  bool get isTouched {
    for (int pointer = 0; pointer < MAX_TOUCHES; pointer++) {
			if (_touched[pointer]) {
				return true;
			}
		}
		return false;
  }

  @override 
  bool isPointerTouched(int pointer) => _touched[pointer];

  @override
  bool get isJustTouched => justTouched;

  @override
  bool isButtonPressed(int button) => button == Buttons.LEFT && _touched[0];

  @override
  bool isKeyPressed([int keycode]){
    if (keycode == null || keycode < 0)
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
  String keyCodeToString(int keyCode) => Keys.keyToString(keyCode);

  int _getMouseRelativeX(MouseEvent e, Element target) => e.client.x - target.offset.left;
  int _getMouseRelativeY(MouseEvent e, Element target) => canvas.height - ( e.client.y - target.offset.top);

  int _getTouchRelativeX(Touch e, Element target) => e.client.x - target.offset.left;
  int _getTouchRelativeY(Touch e, Element target) => canvas.height - (e.client.y - target.offset.top);
}

