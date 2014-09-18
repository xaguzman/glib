part of glib.graphics;

/// A canvas font which is rendered to a Texture to be displayed in webgl.
/// Before drawing, you should call [generate] for the texture to be created. If this is not done,
/// on the first time you try to use this font to draw text it will automatically call [generate], which could
/// slow down your first render call
class Font implements Disposable{
  
  /// the generated texture to render the font
  List<Texture> textures;
  Map<int, Character> symbolMap = new Map();
  
  ///enables creating a border around each [Texture] in [textures]. Must be set before calling [generate]
  bool debugTextures = false; 
  
  bool generated = false;
  
  /// the canvas to render the text to, before sending it to our texture
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  
  FontStyle style;
  
  String symbols ='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ +-*/()[]{}!@#%^_\\\$0123456789';
   
  int maxTextureWidth = 1024;
  int minTextureWidth = 128;
  int maxTexureHeight = 1024;
  int minTextureHeight = 32;
  
  /// Creates a font with the given style. If style is not specified, a default of monospace 16 is used.
  Font([FontStyle style]){
    if (style == null)
      style = new FontStyle(16, 'monospace');
    textures = new List();
    this.style = style;
    canvas = new CanvasElement();
    ctx = canvas.context2D;
  }
  
  ///creates a glTexture which will contain all the [symbols] to later be drawn
  void generate(){
    ctx.font = '${style.size}px ${style.fontFamily}';
    int width = minTextureWidth;
    int height = minTextureHeight;
    double currentRowWidth = 0.0;
    int rowHeight = style.size + 4; //2 pixels bottom margin
    List<String> rows = new List();
    List<Character> currentRowsSymbols = new List();
    int currentPage = 0;
    rows.add(symbols);
    
    for(int i = 0; i < symbols.length; i++){
      var symbol = symbols[i];
      var symbolId = symbols.codeUnitAt(i);
      var symbolWidth = ctx.measureText(symbol).width;
      
      if(currentRowWidth + symbolWidth > width){
        if (width < maxTextureWidth){
          //expand width
          width = width << 1;
        }else{
          var lastStr = rows.last;
          int currentSymbolIdx = lastStr.indexOf(symbol);
          rows[rows.length - 1] = lastStr.substring(0, currentSymbolIdx);
          var nextRow = lastStr.substring(currentSymbolIdx);
          
          //if unable to add more rows (becasue it will exceed maxTextureHeight), flush and create
          //new texture
          if ( (rows.length + 1) * rowHeight > maxTexureHeight ){
            var generatedTexture = _flush(width, NumberUtils.nextPowerOfTwo( rowHeight * rows.length), rowHeight, rows);
            
            currentRowsSymbols.forEach( (char) {
              char.region = new TextureRegion(generatedTexture, char.x, char.y, char.width, char.height);
            });
            
            currentPage++;
            rows.clear();
            currentRowsSymbols.clear();
          }
          
          rows.add(nextRow);
          currentRowWidth = 0.0;
        }
      }
      
      var char = new Character()
        ..id = symbolId
        ..width = symbolWidth.round()
        ..height = rowHeight 
        ..x = currentRowWidth.round()
        ..y = ( rowHeight  * (rows.length - 1)).round()
        ..page = currentPage;
      
      currentRowsSymbols.add(char);
      symbolMap[char.id] = char;
      //hacky +2 ...some fonts overlap themselves, so forcing padding between symbols
      // best example is arial font, lower r and s overlap very badly...
      currentRowWidth += symbolWidth + 2;
      
    }
    
    height = NumberUtils.nextPowerOfTwo( rowHeight * rows.length);
    var generatedTexture  = _flush(width, height, rowHeight, rows);
    currentRowsSymbols.forEach( (char) {
      char.region = new TextureRegion(generatedTexture, char.x.round(), char.y.round(), char.width.round(), char.height.round());
    });
    
    generated = true;
  }
 
  
  Texture _flush(canvasWidth, canvasHeight, int rowHeight, List<String> rows){
    canvas.width = canvasWidth ;
    canvas.height = canvasHeight;
    ctx
      ..fillStyle = '#FFF'
      ..font = "${style.size}px ${style.fontFamily}"  // This determines the size of the text and the font family used
      ..textBaseline = 'top'
      ..fillStyle = style.color.toHex();
    
    for(int i = 0; i < rows.length; i++){
//      ctx.fillText(rows[i], 0, rowHeight * (i + 1) + 1);
      var row = rows[i];
      var chars = row.codeUnits;
      for (int j = 0 ; j < chars.length; j++){
        var charId = chars[j];
        Character char = symbolMap[charId];
        ctx.fillText(row[j], char.x, char.y);
      }
    }
    
      
    
    if (debugTextures)
      ctx.strokeRect(0, 0, canvas.width, canvas.height);
    
    var texture = new Texture()
      ..bind()
      ..setFilter(TextureFilter.MipMapLinearNearest, TextureFilter.Linear)
      ..uploadCanvas(canvas, genMipMaps: true)
      ..loaded = true;
    
    textures.add(texture);
    return texture;
  }
  
  void draw(SpriteBatch batch, String text, double x, double y){
    
    if(!generated){
      generate();
    }
    
    double xoffset = 0.0;
    var charIds = text.codeUnits;
    charIds.forEach( (id){
      var symbol = symbolMap[id];
      batch.drawRegion( symbol.region , x + xoffset, y);
      xoffset += symbol.width;
    });
  }
    
  void dispose(){
    for(int i = 0; i < textures.length; i++)
      textures[i].dispose();
    ctx = null;
    canvas = null;
    textures.clear();
  }
}

class FontStyle{
  
  /// size of the font, in pixels
  final int size;
  
  /// the font family to use for this font 
  final String fontFamily;
  
  Color color;
  
  FontStyle(this.size, this.fontFamily, {this.color }){
    if (color == null)
      color = Color.WHITE;
  }
}

class Character{
  int id, page = 0;
  int x, y, width, height;
  TextureRegion region;
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


