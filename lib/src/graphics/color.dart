part of glib.graphics;

/// Stores information for a color. All the channels are normalized
class Color{ 
  static final Color CLEAR = new Color(0.0, 0.0, 0.0, 0.0);
  static final Color WHITE = new Color(1.0, 1.0, 1.0, 1.0);
  static final Color BLACK = new Color(0.0, 0.0, 0.0, 1.0);
  static final Color RED = new Color(1.0, 0.0, 0.0, 1.0);
  static final Color GREEN = new Color(0.0, 1.0, 0.0, 1.0);
  static final Color BLUE = new Color(0.0, 0.0, 1.0, 1.0);
  static final Color LIGHT_GRAY = new Color(0.75, 0.75, 0.75, 1.0);
  static final Color GRAY = new Color(0.5, 0.5, 0.5, 1.0);
  static final Color DARK_GRAY = new Color(0.25, 0.25, 0.25, 1.0);
  static final Color PINK = new Color(1.0, 0.68, 0.68, 1.0);
  static final Color ORANGE = new Color(1.0, 0.78, 0.0, 1.0);
  static final Color YELLOW = new Color(1.0, 1.0, 0.0, 1.0);
  static final Color MAGENTA = new Color(1.0, 0.0, 1.0, 1.0);
  static final Color CYAN = new Color(0.0, 1.0, 1.0, 1.0);
  static final Color OLIVE = new Color(0.5, 0.5, 0.0, 1.0);
  static final Color PURPLE = new Color(0.5, 0.0, 0.5, 1.0);
  static final Color MAROON = new Color(0.5, 0.0, 0.0, 1.0);
  static final Color TEAL = new Color(0.0, 0.5, 0.5, 1.0);
  static final Color NAVY = new Color(0.0, 0.0, 0.5, 1.0);
  
  static double _toDouble(int channel) => channel / 255;
  static int _toInt(double channel) => (channel * 255).toInt();
  
  
  double r, g, b, a;
  
  Color([double r = 0.0, double g = 0.0, double b = 0.0, double a = 1.0]){
    this.r = MathUtils.clampDouble(r, 0.0, 1.0);
    this.g = MathUtils.clampDouble(g, 0.0, 1.0);
    this.b = MathUtils.clampDouble(b, 0.0, 1.0);
    this.a = MathUtils.clampDouble(a, 0.0, 1.0);
  }
  
  Color.hex(String color){
    setHex(color);
  }
  
  String toHex() {
    String red = _toInt(r).toRadixString(16).padLeft(2, '0');
    String green = _toInt(g).toRadixString(16).padLeft(2, '0');
    String blue = _toInt(b).toRadixString(16).padLeft(2, '0');
    
    return '#$red$green$blue';
  }
  
  void setHex(String hexColor){   
    hexColor = hexColor.trim();
    
    if (hexColor.startsWith('#'))
    {
      if (hexColor.length == 4)
      {
        r = _toDouble(int.parse('${hexColor[1]}${hexColor[1]}', radix: 16));
        g = _toDouble(int.parse('${hexColor[2]}${hexColor[2]}', radix: 16));
        b = _toDouble(int.parse('${hexColor[3]}${hexColor[3]}', radix: 16));
      }
      else if (hexColor.length == 7)
      {
        r = _toDouble(int.parse(hexColor.substring(1, 3)));
        g = _toDouble(int.parse(hexColor.substring(3, 5)));
        b = _toDouble(int.parse(hexColor.substring(5, 7)));
      }
    }
    else if (hexColor.startsWith('rgb'))
    {
      var m = new RegExp(r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)').firstMatch(hexColor);

      if (m != null)
      {
        r = _toDouble(int.parse(m.group(1)));
        g = _toDouble(int.parse(m.group(2)));
        b = _toDouble(int.parse(m.group(3)));
      }
    }
    a = 1.0;
  }
  
  Color copy(){
    return new Color(r, g, b, a);
  }
  
  /// returns the 32 bits representation of this color (IEEE 754) 
  double toDouble() => NumberUtils.colorToDouble(_toInt(r), _toInt(g), _toInt(b), _toInt(a));
  
  /// sets this color from the passed IEEE 754 double 
  void setDouble(double color){
    int intBits = NumberUtils.floatToIntBits(color);
    r = (intBits & 0xff) / 255;
    g = ((intBits >> 8) & 0xff) / 255;
    b = ((intBits >> 16) & 0xff) / 255;
    a = ((intBits >> 24) & 0xff) / 255;
  }
  
  void setDoubleChannels(double r, double g, double b, double a){
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }
  
  /// copies the rgba channels from [other] into this color
  void set(Color other) => setDoubleChannels(other.r, other.g, other.b, other.a);
  
  static double toDoubleBits(double r, double g, double b, double a){
    int color = Color._toInt(a) << 24 | Color._toInt(b) << 16 | Color._toInt(g) << 8 | Color._toInt(r) ;
    return NumberUtils.intToFloatColor(color);
  }
   
}


final Map<String, Color> Colors = {
    "CLEAR": Color.CLEAR,
    "WHITE": Color.WHITE,
    "BLACK": Color.BLACK,
    "RED": Color.RED,
    "GREEN": Color.GREEN,
    "BLUE": Color.BLUE,
    "LIGHT_GRAY": Color.LIGHT_GRAY,
    "GRAY": Color.GRAY,
    "DARK_GRAY": Color.DARK_GRAY,
    "PINK": Color.PINK,
    "ORANGE": Color.ORANGE,
    "YELLOW": Color.YELLOW,
    "MAGENTA": Color.MAGENTA,
    "CYAN": Color.CYAN,
    "OLIVE": Color.OLIVE,
    "PURPLE": Color.PURPLE,
    "MAROON": Color.MAROON,
    "TEAL": Color.TEAL,
    "NAVY": Color.NAVY,
};