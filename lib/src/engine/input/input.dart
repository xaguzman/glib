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

  /// Whether the screen is currently touched by the pointer with the given index.
  bool isPointerTouched(int pointer);
  
  /// whether a new touch down event just occurred
  bool get isJustTouched;
  
  /// wether the passed in mouse [Button] is pressed
  bool isButtonPressed(int button);

  /// wether the [keycode] is pressed. For a list of keys, you can see [Keys].
  /// if no keycode is specified, this will check if any key is pressed
  bool isKeyPressed([int keycode]);
  
  /// whether the [keycode] has just been pressed. For a list of keys, you can see [Keys].
  /// if no keycode is specified, this will check if any key was just pressed
  bool isKeyJustPressed([int keycode]);
  
  InputProcessor processor;
  
  /// set to true to not allow the mouse to leave your application's canvas
  bool catchCursor;
  
  /// gets the string representation of the given [Keys] keycode
  String keyCodeToString(int keycode);
}

///mouse buttons
abstract class Buttons{
  static const int LEFT = 0;
  static const int RIGHT = 2;
  static const int MIDDLE = 1;
}

abstract class Keys {
  // Taken from the html_dartium dart package, merged with libgdx's
  static const int ANY_KEY = -1;
  static const int UNKNOWN = -2;

  static const int NUM_0 = 48;
  static const int NUM_1 = 49;
  static const int NUM_2 = 50;
  static const int NUM_3 = 51;
  static const int NUM_4 = 52;
  static const int NUM_5 = 53;
  static const int NUM_6 = 54;
  static const int NUM_7 = 55;
  static const int NUM_8 = 56;
  static const int NUM_9 = 57;

  static const int NUMPAD_0 = 96;
  static const int NUMPAD_1 = 97;
  static const int NUMPAD_2 = 98;
  static const int NUMPAD_3 = 99;
  static const int NUMPAD_4 = 100;
  static const int NUMPAD_5 = 101;
  static const int NUMPAD_6 = 102;
  static const int NUMPAD_7 = 103;
  static const int NUMPAD_8 = 104;
  static const int NUMPAD_9 = 105;
  static const int NUMPAD_MULTIPLY = 106;
  static const int NUMPAD_PLUS = 107;
  static const int NUMPAD_MINUS = 109;
  static const int NUMPAD_PERIOD = 110;
  static const int NUMPAD_DIVISION = 111;
  static const int NUMPAD_INSERT = 45;
  static const int NUMPAD_DELETE = 46;

  static const int A = 65;
  static const int ALT_LEFT = 18;
  static const int ALT_RIGHT = -2;
  static const int APOSTROPHE = 192;
  static const int B = 66;
  static const int BACKSPACE = 8;
  static const int BACKSLASH = 220;
  static const int C = 67;
  static const int CAPS_LOCK = 20;
  static const int COMMA = 188;
  static const int CTRL = 17;
  static const int D = 68;
  static const int DASH = 189;
  static const int DELETE = 46;
  static const int DOWN = 40;
  static const int E = 69;
  static const int END = 35;
  static const int ENTER = 13;
  static const int EQUALS = 187;
  static const int ESC = 27;
  static const int F = 70;
  static const int F1 = 112;
  static const int F2 = 113;
  static const int F3 = 114;
  static const int F4 = 115;
  static const int F5 = 116;
  static const int F6 = 117;
  static const int F7 = 118;
  static const int F8 = 119;
  static const int F9 = 120;
  static const int F10 = 121;
  static const int F11 = 122;
  static const int F12 = 123;
  static const int G = 71;
  static const int H = 72;
  static const int HOME = 36;
  static const int I = 73;
  static const int INSERT = 45;
  static const int J = 74;
  static const int K = 75;
  static const int L = 76;
  static const int LEFT = 37;
  static const int M = 77;
  static const int N = 78;
  static const int O = 79;
  static const int P = 80;
  static const int PAGE_UP = 33;
  static const int PAGE_DOWN = 34;
  static const int PAUSE = 19;
  static const int Q = 81;
  static const int R = 82;
  static const int RIGHT = 39;
  static const int S = 83;
  static const int SEMICOLON = 186;
  static const int SPACE = 32;
  static const int SHIFT = 16;
  static const int T = 84;
  static const int TAB = 9;
  static const int U = 85;
  static const int UP = 38;
  static const int V = 86;
  static const int W = 87;
  static const int X = 88;
  static const int Y = 89;
  static const int Z = 90;

  static const int WIN_KEY_FF_LINUX = 0;
  static const int MAC_ENTER = 3;

//  /** NUM_CENTER is also NUMLOCK for FF and Safari on Mac. */
//  static const int NUM_CENTER = 12;

  static const int FF_SEMICOLON = 59;
  static const int FF_EQUALS = 61;
  /**
   * CAUTION: The question mark is for US-keyboard layouts. It varies
   * for other locales and keyboard layouts.
   */
  static const int QUESTION_MARK = 63;

  static const int META = 91;
  static const int WIN_KEY_LEFT = 91;
  static const int WIN_KEY_RIGHT = 92;
  static const int CONTEXT_MENU = 93;

  static const int NUMLOCK = 144;
  static const int SCROLL_LOCK = 145;

  // OS-specific media keys like volume controls and browser controls.
  static const int FIRST_MEDIA_KEY = 166;
  static const int LAST_MEDIA_KEY = 183;

  static const int PERIOD = 190;
  static const int SLASH = 191;
  static const int TILDE = 192;
  static const int SINGLE_QUOTE = 222;
  static const int LEFT_BRACKET = 219;
  static const int RIGHT_BRACKET = 221;
  static const int WIN_KEY = 224;
  static const int MAC_FF_META = 224;
  static const int WIN_IME = 229;

  /**
   * Returns true if the keyCode produces a (US keyboard) character.
   * Note: This does not (yet) cover characters on non-US keyboards (Russian,
   * Hebrew, etc.).
   */
  static bool isCharacterKey(int keyCode) {
    if ((keyCode >= NUM_0 && keyCode <= NUM_9) || (keyCode >= NUMPAD_0 && keyCode <= NUMPAD_MULTIPLY) || (keyCode >= A && keyCode <= Z)) {
      return true;
    }

//    // Safari sends zero key code for non-latin characters.
//    if (Device.isWebKit && keyCode == 0) {
//      return true;
//    }

    return (keyCode == SPACE || keyCode == QUESTION_MARK || keyCode == NUMPAD_PLUS
    || keyCode == NUMPAD_MINUS || keyCode == NUMPAD_PERIOD || keyCode == NUMPAD_DIVISION || keyCode == SEMICOLON ||
    keyCode == FF_SEMICOLON || keyCode == DASH || keyCode == EQUALS || keyCode == FF_EQUALS || keyCode == COMMA
    || keyCode == PERIOD || keyCode == SLASH || keyCode == APOSTROPHE || keyCode == SINGLE_QUOTE ||
    keyCode == LEFT_BRACKET || keyCode == BACKSLASH || keyCode == RIGHT_BRACKET);
  }

  static String keyToString (int keycode) {
    switch (keycode) {
    // META* variables should not be used with this method.
      case UNKNOWN:
        return "Unknown";
      case HOME:
        return "Home";
      case NUM_0:
        return "0";
      case NUM_1:
        return "1";
      case NUM_2:
        return "2";
      case NUM_3:
        return "3";
      case NUM_4:
        return "4";
      case NUM_5:
        return "5";
      case NUM_6:
        return "6";
      case NUM_7:
        return "7";
      case NUM_8:
        return "8";
      case NUM_9:
        return "9";
      case UP:
        return "Up";
      case DOWN:
        return "Down";
      case LEFT:
        return "Left";
      case RIGHT:
        return "Right";
      case A:
        return "A";
      case B:
        return "B";
      case C:
        return "C";
      case D:
        return "D";
      case E:
        return "E";
      case F:
        return "F";
      case G:
        return "G";
      case H:
        return "H";
      case I:
        return "I";
      case J:
        return "J";
      case K:
        return "K";
      case L:
        return "L";
      case M:
        return "M";
      case N:
        return "N";
      case O:
        return "O";
      case P:
        return "P";
      case Q:
        return "Q";
      case R:
        return "R";
      case S:
        return "S";
      case T:
        return "T";
      case U:
        return "U";
      case V:
        return "V";
      case W:
        return "W";
      case X:
        return "X";
      case Y:
        return "Y";
      case Z:
        return "Z";
      case COMMA:
        return ",";
      case PERIOD:
        return ".";
      case ALT_LEFT:
        return "L-Alt";
      case ALT_RIGHT:
        return "R-Alt";
//      case SHIFT_LEFT:
//        return "L-Shift";
//      case SHIFT_RIGHT:
//        return "R-Shift";
      case SHIFT:
        return "Shift";
      case TAB:
        return "Tab";
      case SPACE:
        return "Space";
//      case SYM:
//        return "SYM";
//      case EXPLORER:
//        return "Explorer";
//      case ENVELOPE:
//        return "Envelope";
      case ENTER:
        return "Enter";
      case DELETE:
        return "Delete"; // also BACKSPACE
//      case GRAVE:
//        return "`";
      case DASH:
        return "-";
      case EQUALS:
        return "=";
      case LEFT_BRACKET:
        return "[";
      case RIGHT_BRACKET:
        return "]";
      case BACKSLASH:
        return "\\";
      case SEMICOLON:
        return ";";
      case APOSTROPHE:
        return "'";
      case SLASH:
        return "/";
//      case AT:
//        return "@";
//      case NUM:
//        return "Num";
//      case HEADSETHOOK:
//        return "Headset Hook";
//      case FOCUS:
//        return "Focus";
//      case PLUS:
//        return "Plus";
//      case MENU:
//        return "Menu";
//      case NOTIFICATION:
//        return "Notification";
//      case SEARCH:
//        return "Search";
//      case MEDIA_PLAY_PAUSE:
//        return "Play/Pause";
//      case MEDIA_STOP:
//        return "Stop Media";
//      case MEDIA_NEXT:
//        return "Next Media";
//      case MEDIA_PREVIOUS:
//        return "Prev Media";
//      case MEDIA_REWIND:
//        return "Rewind";
//      case MEDIA_FAST_FORWARD:
//        return "Fast Forward";
//      case MUTE:
//        return "Mute";
      case PAGE_UP:
        return "Page Up";
      case PAGE_DOWN:
        return "Page Down";
//      case PICTSYMBOLS:
//        return "PICTSYMBOLS";
//      case SWITCH_CHARSET:
//        return "SWITCH_CHARSET";
//      case BUTTON_A:
//        return "A Button";
//      case BUTTON_B:
//        return "B Button";
//      case BUTTON_C:
//        return "C Button";
//      case BUTTON_X:
//        return "X Button";
//      case BUTTON_Y:
//        return "Y Button";
//      case BUTTON_Z:
//        return "Z Button";
//      case BUTTON_L1:
//        return "L1 Button";
//      case BUTTON_R1:
//        return "R1 Button";
//      case BUTTON_L2:
//        return "L2 Button";
//      case BUTTON_R2:
//        return "R2 Button";
//      case BUTTON_THUMBL:
//        return "Left Thumb";
//      case BUTTON_THUMBR:
//        return "Right Thumb";
//      case BUTTON_START:
//        return "Start";
//      case BUTTON_SELECT:
//        return "Select";
//      case BUTTON_MODE:
//        return "Button Mode";
//      case FORWARD_DEL:
//        return "Forward Delete";
//      case CONTROL_LEFT:
//        return "L-Ctrl";
//      case CONTROL_RIGHT:
//        return "R-Ctrl";
      case DELETE:
        return "Del";
      case ESC:
        return "Esc";
      case END:
        return "End";
      case INSERT:
        return "Insert";
      case NUMPAD_0:
        return "Numpad 0";
      case NUMPAD_1:
        return "Numpad 1";
      case NUMPAD_2:
        return "Numpad 2";
      case NUMPAD_3:
        return "Numpad 3";
      case NUMPAD_4:
        return "Numpad 4";
      case NUMPAD_5:
        return "Numpad 5";
      case NUMPAD_6:
        return "Numpad 6";
      case NUMPAD_7:
        return "Numpad 7";
      case NUMPAD_8:
        return "Numpad 8";
      case NUMPAD_9:
        return "Numpad 9";
//      case COLON:
//        return ":";
      case F1:
        return "F1";
      case F2:
        return "F2";
      case F3:
        return "F3";
      case F4:
        return "F4";
      case F5:
        return "F5";
      case F6:
        return "F6";
      case F7:
        return "F7";
      case F8:
        return "F8";
      case F9:
        return "F9";
      case F10:
        return "F10";
      case F11:
        return "F11";
      case F12:
        return "F12";
    // BUTTON_CIRCLE unhandled, as it conflicts with the more likely to be pressed F12
      default:
      // key name not found
        return null;
    }
  }


}