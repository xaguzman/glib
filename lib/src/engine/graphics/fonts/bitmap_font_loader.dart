part of glib.graphics;

abstract class BitmapFontLoader {

  /// Get the source of the bitmap font.
  String getSource();

  /// Get the BitmapData for a bitmap font page.
  TextureRegion getTextureRegion(String filename);
}

class _BitmapFontLoaderFile extends BitmapFontLoader {

  /// the .fnt|.xml|.json file
  final FileHandle fileFont;

  @override
  String getSource() => fileFont.readString();

  @override
  TextureRegion getTextureRegion(String filename) {
    //region should be relative to the path of the fontfile
    TextureRegion region = new TextureRegion( new Texture.from(fileFont.parent().child(filename)));
    return region;
  }

  _BitmapFontLoaderFile(this.fileFont);

}

