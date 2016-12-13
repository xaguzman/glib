part of glib.graphics;

class BitmapFont implements Disposable{

  static const int _LOG2_PAGE_SIZE = 9;
  static const int _PAGE_SIZE = 1 << _LOG2_PAGE_SIZE;
  static const int _PAGES = 0x10000 ~/ _PAGE_SIZE;

  List<Texture> textures;
//  Map<int, Glyph> symbolMap = new Map();
  BitmapFontData data;
  FileHandle fontFile;
  bool _ownsTexture = false;

  static Future<BitmapFont> load(String path, {BitmapFontFormat format: BitmapFontFormat.FNT }) async{
    FileHandle handle = _files.internal(path);
    var loader = new _BitmapFontLoaderFile(handle);
    var data = await format.load(loader);

    return new BitmapFont()
      ..data = data
      ..fontFile = handle
      ..textures = data.imagePaths.map( (path) => loader.getTextureRegion(path).texture)
      .._ownsTexture = true;
  }


  @override
  void dispose() {

  }
}


class BitmapFontData{
  /// An array of the image paths, for multiple texture pages.
  List<String> imagePaths;
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

  final List<List<Glyph>> glyphs = new List(BitmapFont._PAGES);
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

  Glyph getGlyph(String char){
    int value = char.codeUnitAt(0);
    var page = glyphs[value ~/ BitmapFont._PAGE_SIZE];

    if (page == null) return null;

    return page[value & BitmapFont._PAGE_SIZE - 1];
  }
}



class Glyph {
  int id, page;
  int x, y, width, height, x0ffset, yOffset, xAdvance;
  TextureRegion region;
  String character;

  String toString() {
    return character;
  }

  void setKerning(int second, int amount) {
  }
}