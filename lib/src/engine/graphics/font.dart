////part of glib.graphics;
//
///// A canvas font which is rendered to a Texture to be displayed in webgl.
///// Before drawing, you should call [generate] for the texture to be created. If this is not done,
///// on the first time you try to use this font to draw text it will automatically call [generate], which could
///// slow down your first render call
//class Font implements Disposable{
//
//  /// the generated texture to render the font
//  List<Texture> textures;
//  Map<int, Character> symbolMap = new Map();
//
//  ///enables creating a border around each [Texture] in [textures]. Must be set before calling [generate]
//  bool debugTextures = false;
//
//  bool isGenerated = false;
//
//  /// the canvas to render the text to, before sending it to our texture
//  CanvasElement _canvas;
//
//  /// the [CanvasRenderingContext2D] used to render the text to a canvas, to later put it into our texture
//  CanvasRenderingContext2D ctx;
//
//  FontStyle style;
//
//  /// The glyphs that will be drawn into the underlying [textures], with set [style], when [generate] is called
//  String symbols ='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ \'\$\\,.;:+-*/()[]{}!@#%^&_0123456789"`~=|';
//
//  /// max width each [Texture] in [textures] should have. Better to keep as a pot.
//  int maxTextureWidth = 1024;
//
//  /// min width each [Texture] in [textures] should have. Better to keep as a pot.
//  int minTextureWidth = 128;
//
//  /// max height each [Texture] in [textures] should have. Better to keep as a pot.
//  int maxTexureHeight = 1024;
//
//  /// min height each [Texture] in [textures] should have. Better to keep as a pot.
//  int minTextureHeight = 32;
//
//  /// Creates a font with the given style. If style is not specified, a default of arial 16 is used.
//  Font([FontStyle style]){
//    textures = new List();
//    this.style = style == null ? FontStyles.ARIAL_16 : style;
//    _canvas = new CanvasElement();
//    ctx = _canvas.context2D;
//  }
//
//  ///creates a glTexture which will contain all the [symbols] with the given [style] to later be drawn
//  void generate(){
//    ctx.font = '${style.size}px ${style.fontFamily}';
//    int width = minTextureWidth;
//    int height = minTextureHeight;
//    double currentRowWidth = 0.0;
//    int rowHeight = style.size + 4; //2 pixels bottom margin
//    List<String> rows = new List();
//    List<Character> currentRowsSymbols = new List();
//    int currentPage = 0;
//    rows.add(symbols);
//
//    for(int i = 0; i < symbols.length; i++){
//      var symbol = symbols[i];
//      var symbolId = symbols.codeUnitAt(i);
//      var symbolWidth = ctx.measureText(symbol).width;
//
//      if(currentRowWidth + symbolWidth > width){
//        if (width < maxTextureWidth){
//          //expand width
//          width = width << 1;
//        }else{
//          var lastStr = rows.last;
//          int currentSymbolIdx = lastStr.indexOf(symbol);
//          rows[rows.length - 1] = lastStr.substring(0, currentSymbolIdx);
//          var nextRow = lastStr.substring(currentSymbolIdx);
//
//          //if unable to add more rows (because it will exceed maxTextureHeight), flush and create new texture
//          if ( (rows.length + 1) * rowHeight > maxTexureHeight ){
//            var generatedTexture = _flush(width, NumberUtils.nextPowerOfTwo( rowHeight * rows.length), rowHeight, rows);
//
//            currentRowsSymbols.forEach( (char) {
//              char.region = new TextureRegion(generatedTexture, char.x, char.y, char.width, char.height);
//            });
//
//            currentPage++;
//            rows.clear();
//            currentRowsSymbols.clear();
//          }
//
//          rows.add(nextRow);
//          currentRowWidth = 0.0;
//        }
//      }
//
//      var char = new Character()
//        ..id = symbolId
//        ..width = symbolWidth.round()
//        ..height = rowHeight
//        ..x = currentRowWidth.round()
//        ..y = ( rowHeight  * (rows.length - 1)).round()
//        ..page = currentPage;
//
//      currentRowsSymbols.add(char);
//      symbolMap[char.id] = char;
//      // hacky +2 ...some fonts overlap themselves, so forcing padding between symbols.
//      // A good example is arial font, lower r and s overlap very badly...
//      currentRowWidth += symbolWidth + 2;
//
//    }
//
//    height = NumberUtils.nextPowerOfTwo( rowHeight * rows.length);
//    var generatedTexture  = _flush(width, height, rowHeight, rows);
//    currentRowsSymbols.forEach( (char) {
//      char.region = new TextureRegion(generatedTexture, char.x.round(), char.y.round(), char.width.round(), char.height.round());
//    });
//
//    isGenerated = true;
//  }
//
//  /// sends all the text in [rows] to the [_canvas]
//  Texture _flush(canvasWidth, canvasHeight, int rowHeight, List<String> rows){
//    _canvas.width = canvasWidth ;
//    _canvas.height = canvasHeight;
//    ctx
//      ..fillStyle = '${style.color}'
//      ..font = "${style.size}px ${style.fontFamily}"  // This determines the size of the text and the font family used
//      ..textBaseline = 'top'
//      ..fillStyle = style.color.toHex();
//
//    for(int i = 0; i < rows.length; i++){
//      var row = rows[i];
//      var chars = row.codeUnits;
//      for (int j = 0 ; j < chars.length; j++){
//        var charId = chars[j];
//        Character char = symbolMap[charId];
//        ctx.fillText(row[j], char.x, char.y);
//      }
//    }
//
//    if (debugTextures)
//      ctx.strokeRect(0, 0, _canvas.width, _canvas.height);
//
//    var texture = new Texture()
//      ..bind()
//      ..setFilter(TextureFilter.MipMapLinearNearest, TextureFilter.Linear)
//      ..uploadCanvas(_canvas, genMipMaps: true);
//
//    textures.add(texture);
//    return texture;
//  }
//
//  void draw(SpriteBatch batch, String text, double x, double y){
//
//    if(!isGenerated){
//      generate();
//    }
//
//    double xoffset = 0.0;
//    var charIds = text.codeUnits;
//    charIds.forEach( (id){
//      Character symbol = symbolMap[id];
//      if (symbol != null){
//        batch.drawRegion( symbol.region , x + xoffset, y);
//        xoffset += symbol.width;
//      }
//    });
//  }
//
//  void dispose(){
//    for(int i = 0; i < textures.length; i++)
//      textures[i].dispose();
//    ctx = null;
//    _canvas = null;
//    textures.clear();
//  }
//}
//
//class FontStyle{
//
//  /// size of the font, in pixels
//  final int size;
//
//  /// the font family to use for this font
//  final String fontFamily;
//
//  /** the color which the text will be created with, usually, letting this one as [Color.WHITE] and
//   * changing the [Font] color while drawing is enough, this is provided for future usage when fonts with
//   * border are allowed. This color is only meaningful before [Font.generate] is invoked
//   */
//  final Color color = Color.WHITE.copy();
//
//  FontStyle(this.size, this.fontFamily, {Color color}){
//    if (color != null)
//      this.color.set(color);
//  }
//}
//
//class Character{
//  int id, page = 0;
//  int x, y, width, height;
//  TextureRegion region;
//}
//
//abstract class FontStyles{
//  static final FontStyle ARIAL_16 = new FontStyle(16, 'arial');
//  static final FontStyle MONOSPACE_16 = new FontStyle(16, 'monospace');
//}
