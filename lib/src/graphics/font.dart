part of glib.graphics;


class Text implements Disposable{
  
  /// the generated texture to render the font
  Texture texture;
  
  /// the canvas to render the text to, before sending it to our texture
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  
  FontStyle style;
  
  String _lastText;
  String symbols ='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ +-*/()[]{}!@#%^_\\\$';
  
  Text([FontStyle style]){
    if (style == null)
      style = new FontStyle();
    texture = new Texture();
    this.style = style;
    canvas = new CanvasElement();
    ctx = canvas.context2D;
  }
  
  ///creates a glTexture which will contain all the [symbols] to later be drawn
  void generate(){
    
  }
  
  String get text => _lastText;
  void set text(String text) {
    if (_lastText == text)
      _updateTexture(text);
    _lastText = text;
  }
  
  void draw(SpriteBatch batch, String text, double x, double y){
    
    if(text != _lastText){
      _lastText = text;
      _updateTexture(text);
      if (batch._drawing)
        batch.flush();
    }
    batch.drawTexture(texture, x, y);
  }
  
  _updateTexture(String text){
    ctx.font = '${style.size}px ${style.family}';
    canvas.width = _getPowerOfTwo( ctx.measureText(text).width.toInt() );
    canvas.height = NumberUtils.nextPowerOfTwo( 2 * style.size);
    
    ctx.fillStyle = "${style.color.hexValue}";  // This determines the text colour, it can take a hex value or rgba value (e.g. rgba(255,0,0,0.5))
    ctx.textAlign = "${style.align}"; // This determines the alignment of text, e.g. left, center, right
    ctx.textBaseline = "${style.valign}";  // This determines the baseline of the text, e.g. top, middle, bottom
    ctx.font = "${style.size}px ${style.family}";  // This determines the size of the text and the font family used
    
    ctx.fillText(text , canvas.width/2, canvas.height/2);
    texture
      ..bind()
      ..setFilter(TextureFilter.MipMapLinearNearest, TextureFilter.Linear)
      ..uploadCanvas(canvas, genMipMaps: true);
  }
  
  int _getPowerOfTwo(value, [pow= 1]) {
    while(pow<value) {
      pow *= 2;
    }
    return pow;
  }
  
  void dispose(){
    texture.dispose();
  }
}

class FontStyle{
  
  /// size of the font, in pixels
  int size = 16;
  
  String family = 'arial';
  Color color = Color.WHITE;
  
  
  Align align = Align.CENTER;
  VAlign valign = VAlign.MIDDLE;
}

class VAlign{
  final int val;
  final String strVal;
  const VAlign(this.val, this.strVal);
  
  toString()=> strVal;
  
  static const VAlign TOP = const VAlign(-1, 'top');
  static const VAlign MIDDLE = const VAlign(0, 'middle');
  static const VAlign BOTTOM = const VAlign(1, 'bottom');
}

class Align{
  final int val;
  final String strVal;
  const Align(this.val, this.strVal);
  
  toString()=> strVal;
  
  static const Align LEFT = const Align(-1, 'left');
  static const Align CENTER = const Align(0, 'center');
  static const Align RIGHT = const Align(1, 'right');
}


