part of glib.graphics;

abstract class BitmapFontLoader {

  /// Get the source of the bitmap font.
  Future<String> getSource();

  /// Get the BitmapData for a bitmap font page.
  TextureRegion getTextureRegion(String filename);
}

class _BitmapFontLoaderFile extends BitmapFontLoader {

  /// the .fnt|.xml|.json file
  final FileHandle fileFont;

  @override
  Future<String> getSource() {
    return new Future.value( _files.load(fileFont.path) );
  }

  @override
  TextureRegion getTextureRegion(String filename) {
    //region should be relative to the path of the fontfile
    TextureRegion region = new TextureRegion( new Texture.from(fileFont.parent().child(filename)));
    return region;
  }

  _BitmapFontLoaderFile(this.fileFont);

}

