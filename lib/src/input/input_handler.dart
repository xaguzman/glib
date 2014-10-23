part of glib.input;


/** An InputHandler is used to receive input events from the keyboard and the mouse. 
 * Before using it, you need to register it via game.input.processor.
 * It will be called each frame before the all to [ApplicationListener.render]. 
 * Each method returns a boolean in case you want to use this with the [InputMultiplexer] 
 * to chain input processors.
 */
abstract class InputHandler{
  /// called when a key with the given [keycode] was pressed
  /// return true if the input was processed by this processor, false otherwise
  bool keyDown(int keycode);
  
  /// called when a key with the given [keycode] was released
  /// return true if the input was processed by this processor, false otherwise
  bool keyUp(int keycode);
  
  /// called when a key with the given [keycode] was typed
  /// return true if the input was processed by this processor, false otherwise
  bool keyTyped(int keycode);
  
  /// called when a mouse button was pressed
  /// return true if the input was processed by this processor, false otherwise
  bool mouseDown(int screenX, int screenY, int button);
  
  /// called when a mouse button was released
  /// return true if the input was processed by this processor, false otherwise
  bool mouseUp(int screenX, int screenY, int button);
  
  /// called when the mouse is dragged with a button pressed around the screen
  /// return true if the input was processed by this processor, false otherwise
  bool mouseDragged(int screenX, int screenY, int button);
  
  /// called when the mouse moves around the screen without any button pressed
  /// return true if the input was processed by this processor, false otherwise
  bool mouseMoved(int screenX, int screenY);
  
  /// called when the mouse wheel was scrolled
  /// 
  /// [amount] the scroll amount, -1 or 1 depending on the direction the wheel was scrolled.
  /// 
  /// returns true if the input was processed by this processor, false otherwise
  bool mouseScrolled(int ammount);
  
  /// Generates an [EmptyProcessor]
  factory InputHandler(){
    return new EmptyProcessor();
  }
}

/// Convenience class, which implements all of the [InputHandler], so you only need
/// to override whatever you need
class EmptyProcessor implements InputHandler{
  bool keyDown(int keycode) => false;

  bool keyUp(int keycode) => false;

  bool keyTyped(int keycode) => false;

  bool mouseDown(int screenX, int screenY, int button) => false;

  bool mouseUp(int screenX, int screenY, int button) => false;

  bool mouseDragged(int screenX, int screenY, int button) => false;

  bool mouseMoved(int screenX, int screenY) => false;

  bool mouseScrolled(int ammount) => false;
}