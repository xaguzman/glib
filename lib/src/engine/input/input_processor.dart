part of glib.input;


/** An InputProcessor is used to receive input events from the keyboard and the mouse. 
 * Before using it, you need to register it via game.input.processor.
 * It will be called each frame before the call to [ApplicationListener.render]. 
 * Each method returns a boolean in case you want to use this with the [InputMultiplexer] 
 * to chain input processors.
 */
abstract class InputProcessor{
  /// called when a key with the given [keycode] was pressed
  /// return true if the input was processed by this processor, false otherwise
  bool keyDown(int keycode);
  
  /// called when a key with the given [keycode] was released
  /// return true if the input was processed by this processor, false otherwise
  bool keyUp(int keycode);
  
  /// called when a key with the given [keycode] was typed
  /// return true if the input was processed by this processor, false otherwise
  bool keyTyped(String keycode);
  
  /// called when a the screen touch happens (or mouse down, on the desktop).
  /// return true if the input was processed by this processor, false otherwise
  bool touchDown(int screenX, int screenY, int button);
  
  /// called when a touch is released
  /// return true if the input was processed by this processor, false otherwise
  bool touchUp(int screenX, int screenY, int button);
  
  /// called when the mouse is dragged with a button pressed around the screen
  /// return true if the input was processed by this processor, false otherwise
  bool touchDragged(int screenX, int screenY, int button);
  
  /// called when the mouse moves around the screen without any button pressed
  /// return true if the input was processed by this processor, false otherwise
  bool mouseMoved(int screenX, int screenY);
  
  /// called when the mouse wheel was scrolled
  /// 
  /// [amount] -1 or 1 depending on the direction the wheel was scrolled.
  /// returns true if the input was processed by this processor, false otherwise
  bool mouseScrolled(int ammount);
  
  /// Generates an [EmptyProcessor]
  factory InputProcessor(){
    return new EmptyProcessor();
  }
}

/// Convenience class, which implements all of the [InputProcessor], so you only need
/// to override whatever you need
class EmptyProcessor implements InputProcessor{
  bool keyDown(int keycode) => false;

  bool keyUp(int keycode) => false;

  bool keyTyped(String key) => false;

  bool touchDown(int screenX, int screenY, int button) => false;

  bool touchUp(int screenX, int screenY, int button) => false;

  bool touchDragged(int screenX, int screenY, int button) => false;

  bool mouseMoved(int screenX, int screenY) => false;

  bool mouseScrolled(int ammount) => false;
}
