part of glib.graphics;


abstract class BitmapFontFormat {

  static const BitmapFontFormat FNT = const _BitmapFontFormatFnt();
//  static const BitmapFontFormat XML = const _BitmapFontFormatXml();
//  static const BitmapFontFormat JSON = const _BitmapFontFormatJson();

  const BitmapFontFormat();
  BitmapFontData load(BitmapFontLoader bitmapFontLoader);
  BitmapFontData loadFromString(String src);
}

class _BitmapFontFormatFnt extends BitmapFontFormat{

  const _BitmapFontFormatFnt();

  @override
  BitmapFontData loadFromString(String src){
    var tokenizer = new RegExp(r'(\w+=)(("\S+\ \S+")|\S+|)');
    var splittedSrc = src.split("\n");
    BitmapFontData newData;
    double baseLine = 0.0;

    var readLine = (String line){
      Map<String, String> lineValues = new Map();
      tokenizer.allMatches(line).forEach( (Match m){
        var kvp = m.group(0).split("=");
        lineValues[kvp[0]] = kvp[1].replaceAll('"', '');
      });

      if(line.startsWith("char ")){
        Glyph glyph = new Glyph();
        glyph
          ..id = int.parse(lineValues["id"])
          ..x = int.parse(lineValues["x"])
          ..y = int.parse(lineValues["y"])
          ..width = int.parse(lineValues["width"])
          ..height = int.parse(lineValues["height"])
          ..xOffset = int.parse(lineValues["xoffset"])
          ..yOffset = int.parse(lineValues["yoffset"])
          ..xAdvance = int.parse(lineValues["xadvance"])
          ..page = int.parse(lineValues["page"]);
        
        glyph.character = new String.fromCharCode(glyph.id);
        glyph.yOffset = newData.lineHeight -glyph.height - glyph.yOffset;

        if (glyph.width > 0 && glyph.height > 0)
          newData.descent = Math.min(baseLine + glyph.yOffset, newData.descent);

        newData.descent += newData.padBottom;
        newData.glyphs[glyph.id] = glyph;

      }else if (line.startsWith("kerning")){
        if (!line.startsWith("kernings")){         
          int first = int.parse(lineValues["first"]);
          int second = int.parse(lineValues["second"]);
          int amount = int.parse(lineValues["amount"]);

          Glyph glyph = newData.getGlyph(new String.fromCharCode(first));
          if (glyph != null){
            glyph.setKerning(second, amount);
          }
        }
      }else if(line.startsWith("page")){

        int pageId = int.parse(lineValues["id"]);
        String fileName = lineValues["file"];
        newData.imagePaths.add(fileName);

      }else if(line.startsWith("common")){

        newData.lineHeight = int.parse(lineValues["lineHeight"]);
        baseLine =double.parse(lineValues["base"]);

        int pageCount = 1;
        if (lineValues.containsKey("pages")){
          pageCount = int.parse(lineValues["pages"]);
        }

      }else if(line.startsWith("info")){

        newData = new BitmapFontData();
        var padding = lineValues["padding"].split(',');
        newData
          ..padTop = int.parse(padding[0])
          ..padRight = int.parse(padding[1])
          ..padBottom = int.parse(padding[2])
          ..padLeft = int.parse(padding[3]);

        var padY = newData.padTop + newData.padBottom;
      }
    };

    splittedSrc.forEach( (line) => readLine(line));
    return newData;
  }

  @override
  BitmapFontData load(BitmapFontLoader bitmapFontLoader) => loadFromString(bitmapFontLoader.getSource());
  
}