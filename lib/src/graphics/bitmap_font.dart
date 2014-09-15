part of glib.graphics;

const int LOG2_PAGE_SIZE = 9;
const int PAGE_SIZE = 1 << LOG2_PAGE_SIZE;
const int PAGES = 0x10000 ~/ PAGE_SIZE;

const String _XCHARS = 'xeaonsrcumvwz';
const String _CAPCHARS = 'MNBDCEFKAGHIJLOPQRSTUVWXYZ';

class BitmapFont implements Disposable{
  
  BitmapFontData data;
  List<TextureRegion> regions;
  BitmapFontCache cache;
  bool _integer;
  bool _ownsTexture;
  bool _markupEnabled;
  bool get isFlipped => data.flipped;
  bool get usesIntegerPositions => _integer;
  
  /// It will create a bitmap font from the .fnt located at [url], it will also automatically attemp to load
  /// the font page images specified within the .fnt file. When the font is disposed, the textures containing the 
  /// font glyphs will be also disposed
  BitmapFont(String url, {bool flip: false})
  {
    this.data = new BitmapFontData.url(url, flipped: flip);
    _ownsTexture = true;
    data.load.then((data) {
      this.regions = new List(data.imagePaths.length);
      for (int i = 0; i < this.regions.length; i++) {
        regions[i] = new TextureRegion(new Texture.fromUrl(data.imagePaths[i]));
      }
      _load();
    });
    cache = new BitmapFontCache(this);
  }
  
  /// Creates a [BitmapFont] using the .fnt file located at [url] and using the passed regions 
  /// in [region_OR_regionList]
  /// 
  /// [url] the url to the .fnt file to load
  /// [region_OR_regionList] either a [TextureRegion] or a [List<TextureRegion>] to use
  /// as pages for the font
  BitmapFont.withRegions(String url, region_OR_regionList, {flip: false} ){
   this.data = new BitmapFontData.url(url, flipped: flip);
   if(region_OR_regionList is TextureRegion)
     this.regions = [region_OR_regionList];
   if(region_OR_regionList is List<TextureRegion>)
     this.regions = region_OR_regionList;
   _load();
   cache = new BitmapFontCache(this);
  }
  
  _load(){
    data.glyphs.where((page) => page != null).forEach( (page){
      page.where((glyph) => glyph != null).forEach( (glyph){
        TextureRegion region = regions[glyph.page];

        if (region == null) {
          // TODO: support null regions by parsing scaleW / scaleH ?
          throw new ArgumentError("BitmapFont texture region array cannot contain null elements");
        }

        num invTexWidth = 1.0 / region.texture.width;
        num invTexHeight = 1.0 / region.texture.width;

        num offsetX = 0, offsetY = 0;
        num u = region.u;
        num v = region.v;
        num regionWidth = region.regionWidth;
        num regionHeight = region.regionHeight;
//        if (region is AtlasRegion) {
//          // Compensate for whitespace stripped from left and top edges.
//          AtlasRegion atlasRegion = (AtlasRegion)region;
//          offsetX = atlasRegion.offsetX;
//          offsetY = atlasRegion.originalHeight - atlasRegion.packedHeight - atlasRegion.offsetY;
//        }

        num x = glyph.srcX;
        num x2 = glyph.srcX + glyph.width;
        num y = glyph.srcY;
        num y2 = glyph.srcY + glyph.height;

        // Shift glyph for left and top edge stripped whitespace. Clip glyph for right and bottom edge stripped whitespace.
        if (offsetX > 0) {
          x -= offsetX;
          if (x < 0) {
            glyph.width += x;
            glyph.xoffset -= x;
            x = 0;
          }
          x2 -= offsetX;
          if (x2 > regionWidth) {
            glyph.width -= x2 - regionWidth;
            x2 = regionWidth;
          }
        }
        if (offsetY > 0) {
          y -= offsetY;
          if (y < 0) {
            glyph.height += y;
            y = 0;
          }
          y2 -= offsetY;
          if (y2 > regionHeight) {
            num amount = y2 - regionHeight;
            glyph.height -= amount;
            glyph.yoffset += amount;
            y2 = regionHeight;
          }
        }

        glyph.u = u + x * invTexWidth;
        glyph.u2 = u + x2 * invTexWidth;
        if (data.flipped) {
          glyph.v = v + y * invTexHeight;
          glyph.v2 = v + y2 * invTexHeight;
        } else {
          glyph.v2 = v + y * invTexHeight;
          glyph.v = v + y2 * invTexHeight;
        }
      });//end glyph foreach
    });//end page foreach
  }
  
  /** Draws a string at the specified position.
     * @see BitmapFontCache#addText(CharSequence, float, float, int, int) */
  void draw(SpriteBatch batch, String str, double x, double y) {
    cache.clear();
    TextBounds bounds = cache.addText(str, x, y, 0, str.length);
    cache.draw(batch);
  }
  
  TextBounds getBounds (String str, [int start = 0, int end, TextBounds textBounds]) {
    if (end == null)
      end = str.length;
    if (textBounds == null)
      textBounds = cache.bounds;
    BitmapFontData data = this.data;
    int width = 0;
    Glyph lastGlyph = null;
    while (start < end) {
      var ch = str[start++];
      if (ch == '[' && _markupEnabled) {
        if (!(start < end && str[start] == '[')) { // non escaped '['
          while (start < end && str[start] != ']')
            start++;
          start++;
          continue;
        }
        start++;
      }
      lastGlyph = data.getGlyph(ch);
      if (lastGlyph != null) {
        width = lastGlyph.xadvance;
        break;
      }
    }
    while (start < end) {
      var ch = str[start++];
      if (ch == '[' && _markupEnabled) {
        if (!(start < end && str[start] == '[')) { // non escaped '['
          while (start < end && str[start] != ']')
            start++;
          start++;
          continue;
        }
        start++;
      }
      Glyph g = data.getGlyph(ch);
      if (g != null) {
        width += lastGlyph.getKerning(ch);
        lastGlyph = g;
        width += g.xadvance;
      }
    }
    textBounds.width = width * data.scaleX;
    textBounds.height = data.capHeight;
    return textBounds;
  }
  
  /** Returns the number of glyphs from the substring that can be rendered in the specified width.
   * @param start The first character of the string.
   * @param end The last character of the string (exclusive). */
  int computeVisibleGlyphs (String str, int start, int end, double availableWidth) {
    BitmapFontData data = this.data;
    int index = start;
    double width = 0.0;
    Glyph lastGlyph = null;
    availableWidth /= data.scaleX;

    for (; index < end; index++) {
      var ch = str[index];
      if (ch == '[' && _markupEnabled) {
        index++;
        if (!(index < end && str[index] == '[')) { // non escaped '['
          while (index < end && str[index] != ']')
            index++;
          continue;
        }
      }
      Glyph g = data.getGlyph(ch);
      if (g != null) {
        if (lastGlyph != null) width += lastGlyph.getKerning(ch);
        if ((width + g.xadvance) - availableWidth > 0.001) break;
        width += g.xadvance;
        lastGlyph = g;
      }
    }
    return index - start;
  }
  
  static int indexOf (String text, String ch, int start) {
    final int n = text.length;
    for (int i = start; i < n; i++)
      if (text[i] == ch) 
        return i;
    return n;
  }
  
  static bool isWhitespace (String c) {
    switch (c) {
    case '\n':
    case '\r':
    case '\t':
    case ' ':
      return true;
    default:
      return false;
    }
  }
  
  void dispose(){
    if (_ownsTexture) {
      for (int i = 0; i < regions.length; i++)
        regions[i].texture.dispose();
    }
  }
  
  
}

class TextBounds{
  double width, height;
}

class BitmapFontData{
  List<String> imagePaths;
  bool flipped;
  num lineHeight;
  num capHeight = 1;
  num ascent;
  num descent;
  num down;
  num scaleX = 1, scaleY = 1;
  String _url;
  List<List<Glyph>> glyphs;
  
  bool loaded = false;
  
  num spaceWidth;
  num xHeight;
  
  Completer<BitmapFontData> _completer = new Completer();
  Future<BitmapFontData> get load => _completer.future;
  
  BitmapFontData();
  
  BitmapFontData.url(this._url, {this.flipped: false}){
    new TextFileLoader(_url).done.then(parse);
  }
  
  void parse(String text){
    var lines = text.split('\n');
    int cLine = 0;
    
    String line = lines[cLine++];
                
    // we want the 6th element to be in tact; i.e. "page=N"
    List<String> common = line.split(" ").sublist(0, 7); 

    // we only really NEED lineHeight and base
    if (common.length < 3) 
      throw new ArgumentError("Invalid font file: $_url");

    if (!common[1].startsWith("lineHeight=")) 
      throw new ArgumentError("Invalid font file: $_url");
              
    lineHeight = int.parse(common[1].substring(11));

    if (!common[2].startsWith("base=")) 
      throw new ArgumentError("Invalid font file: $_url");
    
    double baseLine = double.parse(common[2].substring(5));

    // parse the pages count
    int imgPageCount = 1;
    if (common.length >= 6 && common[5] != null && common[5].startsWith("pages=")) {
      try {
        imgPageCount = Math.max(1, int.parse(common[5].substring(6)));
      } on ArgumentError catch(e){
        // just ignore and only use one page...
        // somebody must have tampered with the page count >:(          
      }
    }

    imagePaths = new List(imgPageCount);

    // read each page definition
    for (int p = 0; p < imgPageCount; p++) {
      // read each "page" info line
      line = lines[cLine++];
      if (line == null) 
        throw new ResourceLoadingException("Expected more 'page' definitions in font file", _url);
      
      List<String> pageLine = line.split(" ").sublist(0,4);
      if (!pageLine[2].startsWith("file=")) 
        throw new ArgumentError("Invalid font file: $_url");

      // we will expect ID to mean "index" -- if for some reason this is not the case, it will fuck everything up
      // so we need to warn the user that their BMFont output is bogus
      if (pageLine[1].startsWith("id=")) {
        try {
          int pageID = int.parse(pageLine[1].substring(3));
          if (pageID != p)
            throw new ArgumentError("Invalid font file: $_url -- page ids must be indices starting at 0");
        } on FormatException catch (e) {
          throw new GlibException("NumberFormatException on 'page id' element of $_url");
        }
      }

      String imgFilename = null;
      if (pageLine[2].endsWith("\"")) {
        imgFilename = pageLine[2].substring(6, pageLine[2].length - 1);
      } else {
        imgFilename = pageLine[2].substring(5, pageLine[2].length);
      }
      
      imagePaths[p] = imgFilename;
    }
    descent = 0;

    while (true) {
      line = lines[cLine++];
      if (line == null) 
        break; // EOF
      if (line.startsWith("kernings ")) 
        break; // Starting kernings block
      if (!line.startsWith("char ")) 
        continue;

      Glyph glyph = new Glyph();

      var tokens = line.split(" =");
      int tokenidx = 2;
      int ch = int.parse(tokens[tokenidx++]);
      if (ch > 0xFFFF)
        continue;
      
      setGlyph(ch, glyph);
      glyph.id = ch;
      tokenidx++;
      glyph.srcX = int.parse(tokens[tokenidx++]);
      tokenidx++;
      glyph.srcY = int.parse(tokens[tokenidx++]);
      tokenidx++;
      glyph.width = int.parse(tokens[tokenidx++]);
      tokenidx++;
      glyph.height = int.parse(tokens[tokenidx++]);
      tokenidx++;
      glyph.xoffset = int.parse(tokens[tokenidx++]);
      tokenidx++;
      if (flipped)
        glyph.yoffset = int.parse(tokens[tokenidx++]);
      else
        glyph.yoffset = -(glyph.height + int.parse(tokens[tokenidx++]));
      tokenidx++;
      glyph.xadvance = int.parse(tokens[tokenidx++]);

      // also check for page.. a little safer here since we don't want to break any old functionality
      // and since maybe some shitty BMFont tools won't bother writing page id??
      if (tokenidx < tokens.length - 1) 
        tokenidx++;
      if (tokenidx < tokens.length - 1) {
        try {
          glyph.page = int.parse(tokens[tokenidx]);
        } on FormatException catch (e) {
        }
      }

      if (glyph.width > 0 && glyph.height > 0) 
        descent = Math.min(baseLine + glyph.yoffset, descent);
    }

    while (true) {
      line = lines[cLine++];
      if (line == null || !line.startsWith("kerning ")) 
        break;

      int tokenidx = 2;
      List<String> tokens = line.split(" =");
      int first = int.parse(tokens[tokenidx++]);
      tokenidx++;
      int second = int.parse(tokens[tokenidx++]);
      if (first < 0 || first > 0xFFFF || second < 0 || second > 0xFFFF) 
        continue;
      Glyph glyph = getGlyph(UTF8.decode([first]));
      tokenidx++;
      int amount = int.parse(tokens[tokenidx++]);
      // it appears BMFont outputs kerning for glyph pairs not contained in the font, hence the null check
      if (glyph != null) { 
        glyph.setKerning(second, amount);
      }
    }

    Glyph spaceGlyph = getGlyph(' ');
    if (spaceGlyph == null) {
      spaceGlyph = new Glyph();
      spaceGlyph.id = UTF8.encode(' ')[0];
      Glyph xadvanceGlyph = getGlyph('l');
      if (xadvanceGlyph == null) 
        xadvanceGlyph = getFirstGlyph();
      spaceGlyph.xadvance = xadvanceGlyph.xadvance;
      setGlyph(spaceGlyph.id, spaceGlyph);
    }
    spaceWidth = spaceGlyph != null ? spaceGlyph.xadvance + spaceGlyph.width : 1;

    Glyph xGlyph = null;
    for (int i = 0; i < _XCHARS.length; i++) {
      xGlyph = getGlyph(_XCHARS[i]);
      if (xGlyph != null) 
        break;
    }
    if (xGlyph == null) 
      xGlyph = getFirstGlyph();
    xHeight = xGlyph.height;

    Glyph capGlyph = null;
    for (int i = 0; i < _CAPCHARS.length; i++) {
      capGlyph = getGlyph(_CAPCHARS[i]);
      if (capGlyph != null) break;
    }
    if (capGlyph == null) {
      glyphs.where((page) => page != null).forEach( (page){
        page.forEach((glyph) {
          if (glyph != null || glyph.height != 0 || glyph.width != 0)
            capHeight = Math.max(capHeight, glyph.height);
        });
      });
    } else
    capHeight = capGlyph.height;

    ascent = baseLine - capHeight;
    down = -lineHeight;
    if (flipped) {
      ascent = -ascent;
      down = -down;
    }
    loaded = true;
    _completer.complete(this);
  }
  
  void setGlyph (int ch, Glyph glyph) {
    List<Glyph> page = glyphs[ch ~/ PAGE_SIZE];
    if (page == null) 
      glyphs[ch ~/ PAGE_SIZE] = page = new List<Glyph>(PAGE_SIZE);
    page[ch & PAGE_SIZE - 1] = glyph;
  }

  Glyph getFirstGlyph () {
    glyphs.where((page) => page != null).forEach((page){
      return page.firstWhere((glyph) => glyph != null && glyph != 0 && glyph.width != 0);
    });
    throw new GlibException("No glyphs found!");
  }

  /** Returns the glyph for the specified character, or null if no such glyph exists. */
  Glyph getGlyph (String ch) {
    if (ch.length > 1)
      throw new ArgumentError("Can only get glyphs for single characters, not strings");
    int char = UTF8.encode(ch)[0];
    List<Glyph> page = glyphs[char ~/ PAGE_SIZE];
    if (page != null) 
      return page[char & PAGE_SIZE - 1];
    return null;
  }

  /** Returns the image path for the texture page at the given index.
   * @param index the index of the page, AKA the "id" in the BMFont file
   * @return the texture page */
  String getImagePath (int index) {
    return imagePaths[index];
  }
}

class Glyph {
  int id;
  int srcX, srcY;
  int width, height;
  double u, v, u2, v2;
  int xoffset, yoffset;
  int xadvance;
  List<List<int>> kerning;

  /** The index to the texture page that holds this glyph. */
  int page = 0;

  int getKerning (String char) {
    
    if (kerning != null) {
      int ch = UTF8.encode(char)[0];
      List<int> page = kerning[ch >> LOG2_PAGE_SIZE - 1];
      if (page != null) return page[ch & PAGE_SIZE - 1];
    }
    return 0;
  }

  void setKerning (int ch, int value) {
    if (kerning == null) kerning = new List(PAGES);
    List<int> page = kerning[ch >> LOG2_PAGE_SIZE - 1];
    if (page == null) 
      kerning[ch >> LOG2_PAGE_SIZE - 1] = page = new List(PAGE_SIZE);
    page[ch & PAGE_SIZE - 1] = value;
  }
}