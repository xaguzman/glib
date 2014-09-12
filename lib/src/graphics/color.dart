part of glib.graphics;

/// Stores information for a color. All the channels are normalized
class Color{
  double r, g, b, a;
  
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
  
  Color([double r = 0.0, double g = 0.0, double b = 0.0, double a = 1.0]){
    this.r = MathUtils.clampDouble(r, 0.0, 1.0);
    this.g = MathUtils.clampDouble(g, 0.0, 1.0);
    this.b = MathUtils.clampDouble(b, 0.0, 1.0);
    this.a = MathUtils.clampDouble(a, 0.0, 1.0);
  }
  
  Color.html(String color){
    color = color.trim();
    if (color.startsWith('#'))
    {
      if (color.length == 4)
      {
        r = double.parse(color[1] + color[1]);
        g = double.parse(color[2] + color[2]);
        b = double.parse(color[3] + color[3]);
      }
      else if (color.length == 7)
      {
        r = double.parse(color.substring(1, 3));
        g = double.parse(color.substring(3, 5));
        b = double.parse(color.substring(5, 7));
      }
    }
    else if (color.startsWith('rgb'))
    {
      var m = new RegExp(r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)').firstMatch(color);

      if (m != null)
      {
        r = double.parse(m.group(1));
        g = double.parse(m.group(2));
        b = double.parse(m.group(3));
      }
    }
    a = 1.0;
  }
  
  /// returns the 32 bits representation of this color (IEEE 754) 
  double toDouble() => NumberUtils.colorToDouble(_toInt(r), _toInt(g), _toInt(b), _toInt(a));
  
  double _toDouble(int channel) => channel / 255;
  int _toInt(double channel) => (channel * 255).toInt();
}