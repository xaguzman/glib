part of glib.graphics;

const String DEFAULT_FONT_PATH = 'packages/glib/src/engine/graphics/fonts/arial-15.fnt';

class BitmapFont implements Disposable{

  static const int _LOG2_PAGE_SIZE = 9;
  static const int _PAGE_SIZE = 1 << _LOG2_PAGE_SIZE;
  static const int _PAGES = 0x10000 ~/ _PAGE_SIZE;

  List<Texture> textures;
//  Map<int, Glyph> symbolMap = new Map();
  BitmapFontData data;
  FileHandle fontFile;
  bool _ownsTexture = false;

  BitmapFont({String path: DEFAULT_FONT_PATH, BitmapFontFormat format: BitmapFontFormat.FNT}) {
      FileHandle handle = _files.internal(path);
      var loader = new _BitmapFontLoaderFile(handle);
      var data = format.load(loader);
      var textures = data.imagePaths.map( (String path) {
        return loader.getTextureRegion(path).texture;
      }).toList();

      data.glyphs.values.forEach( (Glyph g){
        g.region = new TextureRegion(textures[g.page], g.x, g.y, g.width, g.height);
      });
      this.data = data;
      this.fontFile = handle;
      this.textures = textures;
      this._ownsTexture = true;   
  }

  

  void draw(SpriteBatch batch, String text, {double x: 0.0, double y: 0.0}){
    double xoffset = 0.0;

    for (num i = 0; i < text.length; i++){
      Glyph glyph = data.getGlyph(text[i]);
      if (glyph != null){
        batch.drawRegion(glyph.region, x + xoffset + glyph.xOffset , y + glyph.yOffset);
        xoffset += glyph.xAdvance;
      }
    }
  }

  @override
  void dispose() {

  }
}


class BitmapFontData{
  /// An array of the image paths, for multiple texture pages.
  List<String> imagePaths = new List();
  FileHandle fontFile;
  bool flipped;
  int padTop, padRight, padBottom, padLeft;
  /// The distance from one line of text to the next. To set this value, use {@link #setLineHeight(float)}.
  int lineHeight;
  /// The distance from the top of most uppercase characters to the baseline. Since the drawing position is the cap height of
  /// the first line, the cap height can be used to get the location of the baseline.
  double capHeight = 1.0;
  /// The distance from the cap height to the top of the tallest glyph.
  double ascent = 0.0;
  /// The distance from the bottom of the glyph that extends the lowest to the baseline. This number is negative.
  double descent = 0.0;
  /// The distance to move down when \n is encountered.
  double down;
  /// Multiplier for the line height of blank lines. down * blankLineHeight is used as the distance to move down for a blank line.
  double blankLineScale = 1.0;
  double scaleX = 1.0, scaleY = 1.0;
  bool markupEnabled;
  /// The amount to add to the glyph X position when drawing a cursor between glyphs. This field is not set by the BMFont
  /// file, it needs to be set manually depending on how the glyphs are rendered on the backing textures.
  double cursorX;

  final Map<int, Glyph> glyphs = new Map();
  /// The glyph to display for characters not in the font. May be null.
  Glyph missingGlyph;

  /// The width of the space character.
  double spaceWidth;
  /// The x-height, which is the distance from the top of most lowercase characters to the baseline.
  double xHeight = 1.0;

  /// Additional characters besides whitespace where text is wrapped. Eg, a hypen (-).
  List<String> breakChars;
  List<String> xChars = ['x', 'e', 'a', 'o', 'n', 's', 'r', 'c', 'u', 'm', 'v', 'w', 'z'];
  List<String> capChars = ['M', 'N', 'B', 'D', 'C', 'E', 'F', 'K', 'A', 'G', 'H', 'I', 'J', 'L', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

  // Glyph getGlyph(String char){
  //   int value = char.codeUnitAt(0);
  //   var page = glyphs[value ~/ BitmapFont._PAGE_SIZE];

  //   if (page == null) return null;

  //   return page[value & BitmapFont._PAGE_SIZE - 1];
  // }

  Glyph getGlyph(String char){
    int id = char.codeUnitAt(0);

    var glyph = glyphs[id];
    
    return glyphs.containsKey(id) ? glyphs[id] : null;
  }
}

class Glyph {
  int id, page;
  int x, y, width, height, xOffset, yOffset, xAdvance;
  TextureRegion region;
  String character;

  String toString() {
    return character;
  }

  void setKerning(int second, int amount) {
  }
}

