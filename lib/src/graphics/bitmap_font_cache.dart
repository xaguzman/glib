part of glib.graphics;

class BitmapFontCache{
  final BitmapFont _font;

  List<Float32List> _vertexData;

  Int32List _idx;
  
  /** Used internally to ensure a correct capacity for multi-page font vertex data. */
  Int32List _tmpGlyphCount;

  double _x, _y;
  double _color = Color.WHITE.toDouble();
  double _previousColor = Color.WHITE.toDouble();
  final Color _tempColor = Color.WHITE.copy();
  final Color _hexColor = new Color();
  final StringBuffer _colorBuffer = new StringBuffer();
  final TextBounds _textBounds = new TextBounds();
  bool _integer = true;
  int _glyphCount = 0;
  
  List<List<int>> _glyphIndices;

  /** Creates a new BitmapFontCache
   * @param font the font to use
   * @param _integer whether to use _integer positions and sizes. */
  BitmapFontCache (this._font, [this._integer]) {
    if (_integer == null)
      _integer = _font.usesIntegerPositions;
    
    int regionsLength = _font.regions.length;
    if (regionsLength == 0) 
      throw new ArgumentError("The specified font must contain at least 1 texture page");

    _vertexData = new List(regionsLength);

    _idx = new Int32List(regionsLength);
    int vertexDataLength = _vertexData.length;
    if (vertexDataLength > 1) { // if we have multiple pages...
      // contains the indices of the glyph in the Cache as they are added
      _glyphIndices = new List(vertexDataLength);
      for (int i = 0, n = _glyphIndices.length; i < n; i++) {
        _glyphIndices[i] = new List();
      }

      _tmpGlyphCount = new Int32List(vertexDataLength);
    }
  }

  /** Sets the position of the text, relative to the position when the cached text was created.
   * @param x The x coordinate
   * @param y The y coordinate */
  void setPosition (double x, double y) {
    translate(x - this.x, y - this.y);
  }

  /** Sets the position of the text, relative to its current position.
   * @param xAmount The amount in x to move the text
   * @param yAmount The amount in y to move the text */
  void translate (double xAmount, double yAmount) {
    if (xAmount == 0 && yAmount == 0) return;
    if (_integer) {
      xAmount = xAmount.round().toDouble();
      yAmount = yAmount.round().toDouble();
    }
    _x += xAmount;
    _y += yAmount;

    for (int j = 0, length = _vertexData.length; j < length; j++) {
      Float32List vertices = _vertexData[j];
      for (int i = 0, n = _idx[j]; i < n; i += 5) {
        vertices[i] += xAmount;
        vertices[i + 1] += yAmount;
      }
    }
  }

  /** Sets the color of all text currently in the cache. Does not affect subsequently added text. */
  void set colorDouble (double color) {
    for (int j = 0, length = _vertexData.length; j < length; j++) {
      Float32List vertices = _vertexData[j];
      for (int i = 2, n = _idx[j]; i < n; i += 5)
        vertices[i] = color;
    }
  }

  /** Sets the color of all text currently in the cache. Does not affect subsequently added text. */
  void set color (Color tint) {
    colorDouble = tint.toDouble();
  }

  /** Sets the color of all text currently in the cache. Does not affect subsequently added text. */
  void setColorRGBA (double r, double g, double b, double a) {
    
    int intBits = (Color._toInt(a) << 24) | (Color._toInt(b) << 16) | (Color._toInt(g) << 8) | Color._toInt(a);
    double color = NumberUtils.intToFloatColor(intBits);
    colorDouble = color;
  }

  /** Sets the color of the specified characters. This may only be called after {@link #setText(String, float, float)} and
   * is reset every time setText is called. */
  void setColorRange(Color tint, int start, int end) {
    final double color = tint.toDouble();

    if (_vertexData.length == 1) { // only one page...
      Float32List vertices = _vertexData[0];
      for (int i = start * 20 + 2, n = end * 20; i < n; i += 5)
        vertices[i] = color;
    } else {
      int pageCount = _vertexData.length;

      // for each page...
      for (int i = 0; i < pageCount; i++) {
        Float32List vertices = _vertexData[i];

        // we need to loop through the indices and determine whether the glyph is inside begin/end
        for (int j = 0, n = _glyphIndices[i].length; j < n; j++) {
          int gInd = _glyphIndices[i][j];

          // break early if the glyph is outside our bounds
          if (gInd >= end) break;

          // if the glyph is inside start and end, then change it's colour
          if (gInd >= start) { // && gInd < end
            // modify color index
            for (int off = 0; off < 20; off += 5)
              vertices[off + (j * 20 + 2)] = color;
          }
        }
      }
    }
  }

  /** Sets the color of subsequently added text. Does not affect text currently in the cache. */
  void set colorNext (Color tint) {
    _color = tint.toDouble();
  }

  /** Sets the color of subsequently added text. Does not affect text currently in the cache. */
  void setColorRGBANext (double r, double g, double b, double a) {
    int intBits = Color._toInt(a) << 24 | Color._toInt(b) << 16 | Color._toInt(g) << 8 | Color._toInt(r);
    _color = NumberUtils.intToFloatColor(intBits);
  }

  /** Sets the color of subsequently added text. Does not affect text currently in the cache. */
  void set colorNextDouble (double color) {
    _color = color;
  }

  Color get color {
    int intBits = NumberUtils.floatToIntBits(_color);
    Color color = _tempColor;
    color.r = (intBits & 0xff) / 255;
    color.g = ((intBits >> 8) & 0xff) / 255;
    color.b = ((intBits >> 16) & 0xff) / 255;
    color.a = ((intBits >> 24) & 0xff) / 255;
    return color;
  }

  void draw(SpriteBatch spriteBatch) {
    var regions = _font.regions;
    for (int j = 0, n = _vertexData.length; j < n; j++) {
      if (_idx[j] > 0) { // ignore if this texture has no glyphs
        Float32List vertices = _vertexData[j];
        spriteBatch.drawVertices(regions[j].texture, vertices, 0, _idx[j]);
      }
    }
  }

  void draw2(SpriteBatch spriteBatch, int start, int end) {
    if (_vertexData.length == 1) { // i.e. 1 page
      spriteBatch.drawVertices(_font.regions[0].texture, _vertexData[0], start * 20, (end - start) * 20);
    } else { // i.e. multiple pages
      // TODO: bounds check?

      // We basically need offset and len for each page
      // Different pages might have different offsets and lengths
      // Some pages might not need to be rendered at all..

      var regions = font.regions;

      // for each page...
      for (int i = 0, pageCount = _vertexData.length; i < pageCount; i++) {

        int offset = -1;
        int count = 0;

        // we need to loop through the indices and determine where we begin within the start/end bounds
        var currentGlyphIndices = _glyphIndices[i];
        for (int j = 0, n = currentGlyphIndices.length; j < n; j++) {
          int glyphIndex = currentGlyphIndices[j];

          // break early if the glyph is outside our bounds
          if (glyphIndex >= end) break;

          // determine if this glyph is "inside" our start/end bounds
          // if so; use the first match of that for the offset
          if (offset == -1 && glyphIndex >= start) offset = j;

          // we also need to determine the length of our vertices array...
          // we do so by counting the glyphs within our bounds
          if (glyphIndex >= start) // && gInd < end
            count++;
        }

        // this page isn't necessary to be rendered
        if (offset == -1 || count == 0) continue;

        // render the page vertex data with our determined offset and length
        spriteBatch.drawVertices(regions[i].texture, _vertexData[i], offset * 20, count * 20);
      }
    }
  }

  void draw3(SpriteBatch spriteBatch, double alphaModulation) {
    if (alphaModulation == 1) {
      draw(spriteBatch);
      return;
    }
    
    double oldAlpha = color.a;
    color.a *= alphaModulation;
    draw(spriteBatch);
    color.a = oldAlpha;
  }

  /** Removes all glyphs in the cache. */
  void clear () {
    _x = 0.0;
    _y = 0.0;
    _glyphCount = 0;
    for (int i = 0, n = _idx.length; i < n; i++) {
      if (_glyphIndices != null) 
        _glyphIndices[i].clear();
      _idx[i] = 0;
    }
  }

  /** Counts the actual glyphs excluding characters used to markup the text. */
  int _countGlyphs (String seq, int start, int end) {
    int count = end - start;
    while (start < end) {
      String ch = seq[start++];
      if (ch == '[') {
        count--;
        if (!(start < end && seq[start] == '[')) { // non escaped '['
          while (start < end && seq[start] != ']') {
            start++;
            count--;
          }
          count--;
        }
        start++;
      }
    }
    return count;
  }

  void _requireSequence (String seq, int start, int end) {
    if (_vertexData.length == 1) {
      // don't scan sequence if we just have one page and markup is disabled
      int newGlyphCount = font._markupEnabled ? _countGlyphs(seq, start, end) : end - start;
      _require(0, newGlyphCount);
    } else {
      for (int i = 0, n = _tmpGlyphCount.length; i < n; i++)
        _tmpGlyphCount[i] = 0;

      // determine # of glyphs in each page
      while (start < end) {
        String ch = seq[start++];
        if (ch == '[' && font._markupEnabled) {
          if (!(start < end && seq[start] == '[')) { // non escaped '['
            while (start < end && seq[start] != ']')
              start++;
            start++;
            continue;
          }
          start++;
        }
        Glyph g = font.data.getGlyph(ch);
        if (g == null) continue;
        _tmpGlyphCount[g.page]++;
      }
      // require that many for each page
      for (int i = 0, n = _tmpGlyphCount.length; i < n; i++)
        _require(i, _tmpGlyphCount[i]);
    }
  }

  void _require (int page, int glyphCount) {
//    if (_glyphIndices != null) {
//      if (glyphCount > _glyphIndices[page].length)
//        _glyphIndices[page].ensureCapacity(glyphCount - glyphIndices[page].items.length);
//    }

    int vertexCount = _idx[page] + glyphCount * 20;
    Float32List vertices = _vertexData[page];
    if (vertices == null) {
      _vertexData[page] = new Float32List(vertexCount);
    } else if (vertices.length < vertexCount) {
      Float32List newVertices = new Float32List(vertexCount);
      newVertices.setAll(0, vertices);
      _vertexData[page] = newVertices;
    }
  }

  int _parseAndSetColor (String str, int start, int end) {
    if (start < end) {
      if (str[start] == '#') {
        //hexcolor
        var strColor = str.substring(start, end);
        _hexColor.hexValue = strColor;
      } else {
        // Parse named color
        _colorBuffer.clear();
        for (int i = start; i < end; i++) {
          var ch = str[i];
          if (ch == ']') {
            if (_colorBuffer.length == 0) {
              this.colorDouble = _previousColor;
            } else {
              String colorString = _colorBuffer.toString();
              Color newColor = Colors[colorString];
              if (newColor == null) 
                throw new GlibException("Unknown color '$colorString'");
              _previousColor = _color;
              _color = newColor.toDouble();
            }
            return i - start;
          } else {
            _colorBuffer.write(ch);
          }
        }
      }
    }
    throw new GlibException("Unclosed color tag");
  }

  double _addToCache (String str, double x, double y, int start, int end) {
    double startX = x;
    BitmapFont font = this.font;
    Glyph lastGlyph = null;
    BitmapFontData data = font.data;
    if (data.scaleX == 1 && data.scaleY == 1) {
      while (start < end) {
        String ch = str[start++];
        if (ch == '[' && font._markupEnabled) {
          if (!(start < end && str[start] == '[')) { // non escaped '['
            start += _parseAndSetColor(str, start, end) + 1;
            continue;
          }
          start++;
        }
        lastGlyph = data.getGlyph(ch);
        if (lastGlyph != null) {
          _addGlyph(lastGlyph, x + lastGlyph.xoffset, y + lastGlyph.yoffset, lastGlyph.width.toDouble(), lastGlyph.height.toDouble());
          x += lastGlyph.xadvance;
          break;
        }
      }
      while (start < end) {
        var ch = str[start++];
        if (ch == '[' && font._markupEnabled) {
          if (!(start < end && str[start] == '[')) { // non escaped '['
            start += _parseAndSetColor(str, start, end) + 1;
            continue;
          }
          start++;
        }
        Glyph g = data.getGlyph(ch);
        if (g != null) {
          x += lastGlyph.getKerning(ch);
          lastGlyph = g;
          _addGlyph(lastGlyph, x + g.xoffset, y + g.yoffset, g.width.toDouble(), g.height.toDouble());
          x += g.xadvance;
        }
      }
    } else {
      double scaleX = data.scaleX, scaleY = data.scaleY;
      while (start < end) {
        String ch = str[start++];
        if (ch == '[' && font._markupEnabled) {
          if (!(start < end && str[start] == '[')) { // non escaped '['
            start += _parseAndSetColor(str, start, end) + 1;
            continue;
          }
          start++;
        }
        lastGlyph = data.getGlyph(ch);
        if (lastGlyph != null) {
          _addGlyph(lastGlyph, //
            x + lastGlyph.xoffset * scaleX, //
            y + lastGlyph.yoffset * scaleY, //
            lastGlyph.width * scaleX, //
            lastGlyph.height * scaleY);
          x += lastGlyph.xadvance * scaleX;
          break;
        }
      }
      while (start < end) {
        var ch = str[start++];
        if (ch == '[' && font._markupEnabled) {
          if (!(start < end && str[start] == '[')) { // non escaped '['
            start += _parseAndSetColor(str, start, end) + 1;
            continue;
          }
          start++;
        }
        Glyph g = data.getGlyph(ch);
        if (g != null) {
          x += lastGlyph.getKerning(ch) * scaleX;
          lastGlyph = g;
          _addGlyph(lastGlyph, //
            x + g.xoffset * scaleX, //
            y + g.yoffset * scaleY, //
            g.width * scaleX, //
            g.height * scaleY);
          x += g.xadvance * scaleX;
        }
      }
    }
    return x - startX;
  }

  void _addGlyph (Glyph glyph, double x, double y, double width, double height) {
    double x2 = x + width;
    double y2 = y + height;
    final double u = glyph.u;
    final double u2 = glyph.u2;
    final double v = glyph.v;
    final double v2 = glyph.v2;

    final int page = glyph.page;

    if (_glyphIndices != null) {
      _glyphIndices[page].add(_glyphCount++);
    }

    final Float32List vertices = _vertexData[page];

    if (_integer) {
      x = x.round().toDouble();
      y = y.round().toDouble();
      x2 = x2.round().toDouble();
      y2 = y2.round().toDouble();
    }

    int idx = this._idx[page];
    _idx[page] += 20;

    vertices[idx++] = x;
    vertices[idx++] = y;
    vertices[idx++] = _color;
    vertices[idx++] = u;
    vertices[idx++] = v;

    vertices[idx++] = x;
    vertices[idx++] = y2;
    vertices[idx++] = _color;
    vertices[idx++] = u;
    vertices[idx++] = v2;

    vertices[idx++] = x2;
    vertices[idx++] = y2;
    vertices[idx++] = _color;
    vertices[idx++] = u2;
    vertices[idx++] = v2;

    vertices[idx++] = x2;
    vertices[idx++] = y;
    vertices[idx++] = _color;
    vertices[idx++] = u2;
    vertices[idx] = v;
  }

  /** Clears any cached glyphs and adds glyphs for the specified text.
   * @see #addText(String, float, float, int, int) */
  setText (String str, double x, double y, [int start = 0, int end]) {
    if (end == null)
      end = str.length;
    clear();
    return addText(str, x, y, start, end);
  }

  /** Adds glyphs for the the specified text.
   * @param x The x position for the left most character.
   * @param y The y position for the top of most capital letters in the font (the {@link BitmapFont#getCapHeight() cap height}).
   * @param start The first character of the string to draw.
   * @param end The last character of the string to draw (exclusive).
   * @return The bounds of the cached string (the height is the distance from y to the baseline). */
  TextBounds addText (String str, double x, double y, [int start = 0, int end]) {
    if ( end == null){
      end = str.length;
    }
    _requireSequence(str, start, end);
    y += _font.data.ascent;
    _textBounds.width = _addToCache(str, x, y, start, end);
    _textBounds.height = font.data.capHeight;
    return _textBounds;
  }

  /** Clears any cached glyphs and adds glyphs for the specified text, which may contain newlines (\n).
   * @see #addMultiLineText(String, float, float, float, HAlignment) */
  TextBounds setMultiLineText (String str, double x, double y, [double alignmentWidth = 0.0, int alignment = HAlignment.LEFT]) {
    clear();
    return addMultiLineText(str, x, y, alignmentWidth, alignment);
  }

  /** Adds glyphs for the specified text, which may contain newlines (\n). Each line is aligned horizontally within a rectangle of
   * the specified width.
   * @param x The x position for the left most character.
   * @param y The y position for the top of most capital letters in the font (the {@link BitmapFont#getCapHeight() cap height}).
   * @param alignment The horizontal alignment of wrapped line.
   * @return The bounds of the cached string (the height is the distance from y to the baseline of the last line). */
  TextBounds addMultiLineText (String str, double x, double y, [double alignmentWidth = 0.0, int alignment = HAlignment.LEFT]) {
    BitmapFont font = _font;

    int length = str.length;
    _requireSequence(str, 0, length);

    y += font.data.ascent;
    double down = font.data.down;

    double maxWidth = 0.0;
    double startY = y;
    int start = 0;
    int numLines = 0;
    while (start < length) {
      int lineEnd = BitmapFont.indexOf(str, '\n', start);
      double xOffset = 0.0;
      if (alignment != HAlignment.LEFT) {
        double lineWidth = font.getBounds(str, start, lineEnd).width;
        xOffset = alignmentWidth - lineWidth;
        if (alignment == HAlignment.CENTER) xOffset /= 2;
      }
      double lineWidth = _addToCache(str, x + xOffset, y, start, lineEnd);
      maxWidth = Math.max(maxWidth, lineWidth);
      start = lineEnd + 1;
      y += down;
      numLines++;
    }
    _textBounds.width = maxWidth;
    _textBounds.height = font.data.capHeight + (numLines - 1) * font.data.lineHeight;
    return _textBounds;
  }

  /** Clears any cached glyphs and adds glyphs for the specified text, which may contain newlines (\n) and is automatically
   * wrapped within the specified width.
   * @see #addWrappedText(String, float, float, float, HAlignment) */
  TextBounds setWrappedText (String str, double x, double y, double wrapWidth, [int alignment = HAlignment.LEFT]) {
    clear();
    return addWrappedText(str, x, y, wrapWidth, alignment);
  }

  /** Adds glyphs for the specified text, which may contain newlines (\n) and is automatically wrapped within the specified width.
   * @param x The x position for the left most character.
   * @param y The y position for the top of most capital letters in the font (the {@link BitmapFont#getCapHeight() cap height}).
   * @param alignment The horizontal alignment of wrapped line.
   * @return The bounds of the cached string (the height is the distance from y to the baseline of the last line). */
  TextBounds addWrappedText (String str, double x, double y, double wrapWidth, [int alignment = HAlignment.LEFT]) {
    BitmapFont font = this.font;

    int length = str.length;
    _requireSequence(str, 0, length);

    y += font.data.ascent;
    double down = font.data.down;

    wrapWidth = wrapWidth.abs();
    
    double maxWidth = 0.0;
    int start = 0;
    int numLines = 0;
    while (start < length) {
      int newLine = BitmapFont.indexOf(str, '\n', start);
      // Eat whitespace at start of line.
      while (start < newLine) {
        if (!BitmapFont.isWhitespace(str[start])) break;
        start++;
      }
      int lineEnd = start + font.computeVisibleGlyphs(str, start, newLine, wrapWidth);
      int nextStart = lineEnd + 1;
      if (lineEnd < newLine) {
        // Find char to break on.
        while (lineEnd > start) {
          if (BitmapFont.isWhitespace(str[lineEnd])) break;
          lineEnd--;
        }
        if (lineEnd == start) {
          if (nextStart > start + 1) nextStart--;
          lineEnd = nextStart; // If no characters to break, show all.
        } else {
          nextStart = lineEnd;
          // Eat whitespace at end of line.
          while (lineEnd > start) {
            if (!BitmapFont.isWhitespace(str[lineEnd - 1])) break;
            lineEnd--;
          }
        }
      }
      if (lineEnd > start) {
        double xOffset = 0.0;
        if (alignment != HAlignment.LEFT) {
          double lineWidth = font.getBounds(str, start, lineEnd).width;
          xOffset = wrapWidth - lineWidth;
          if (alignment == HAlignment.CENTER) xOffset /= 2;
        }
        double lineWidth = _addToCache(str, x + xOffset, y, start, lineEnd);
        maxWidth = Math.max(maxWidth, lineWidth);
      }
      start = nextStart;
      y += down;
      numLines++;
    }
    _textBounds.width = maxWidth;
    _textBounds.height = font.data.capHeight + (numLines - 1) * font.data.lineHeight;
    return _textBounds;
  }

  /** Returns the size of the cached string. The height is the distance from the top of most capital letters in the font (the
   * {@link BitmapFont#getCapHeight() cap height}) to the baseline of the last line of text. */
  TextBounds get bounds => _textBounds;

  /** Returns the x position of the cached string, relative to the position when the string was cached. */
  double get x => x;

  /** Returns the y position of the cached string, relative to the position when the string was cached. */
  double get y => _y;

  BitmapFont get font => _font;

  bool get usesIntegerPositions => _integer;
  void set usesIntegerPositions(bool integer){
    _integer = integer;
  }

  Float32List getVertices ([int page = 0]) {
    return _vertexData[page];
  }
}

class HAlignment{
  static const int LEFT = -1;
  static const int CENTER = 0;
  static const int RIGHT = 1;
}