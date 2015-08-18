part of glib.graphics;

enum TileBlendMode {
  None, Alpha
}

abstract class TiledMapTile {
  int id;
  TileBlendMode blendMode;
  double _offsetX, _offsetY;

  double get offsetX => _offsetX;
  double get offsetY => _offsetY;

  void set offsetX(double val) { _offsetX = val; }
  void set offsetY(double val) { _offsetY = val; }

  GameMapProperties _props;
  GameMapProperties get properties {
    if (_props == null)
      _props = new GameMapProperties();
    return _props;
  }

  TextureRegion _region;
  TextureRegion get textureRegion => _region;
  void set textureRegion(TextureRegion region) {
    _region = region;
  }


  TiledMapTile() :
    _offsetY = 0.0,
    _offsetX = 0.0,
    blendMode = TileBlendMode.Alpha;
}

///Represents a non changing [TiledMapTile] (can be cached)
class StaticTiledMapTile extends TiledMapTile {

  /// Create a new StaticTileMapTile which is an exact copy of [other]
  StaticTiledMapTile.from(StaticTiledMapTile other)
  {
    if (other.properties != null) {
      properties.putAll(other.properties);
    }
    this.textureRegion = other.textureRegion;
    this.id = other.id;
  }
}

class AnimatedTiledMapTile extends TiledMapTile{
  static Stopwatch watch = new Stopwatch();
  double _frameDuration;

  List<StaticTiledMapTile> _frameTiles;

  static double elapsedtime = 0.0;

  @override
  void set textureRegion(TextureRegion reg){
    throw new ArgumentError("Cannot set the texture region of AnimatedTiledMapTile");

  }

  @override
  TextureRegion get textureRegion => currentFrame.textureRegion;

  @override
  double get offsetX => currentFrame.offsetX;

  @override
  double get offsetY => currentFrame.offsetY;

  @override
  void set offsetX(double) {
    throw new ArgumentError("Cannot set offset of AnimatedTiledMapTile");
  }

  @override
  void set offsetY(double) {
    throw new ArgumentError("Cannot set offset of AnimatedTiledMapTile");
  }

  int get currentFrameIndex {
    if (_frameTiles.length == 1) return 0;

    int frameNumber = elapsedtime ~/ _frameDuration;
    frameNumber = frameNumber % _frameTiles.length;

    return frameNumber;
  }


  TiledMapTile get currentFrame => _frameTiles[currentFrameIndex];

  int get frameCount => _frameTiles.length;

  /** Function is called by BatchTiledMapRenderer render(), lastTiledMapRenderTime is used to keep all of the tiles in lock-step
   * animation and avoids having to call TimeUtils.millis() in getTextureRegion() */
  static void updateAnimationBaseTime () {
    elapsedtime += _graphics.deltaTime;
  }

  /** Creates an animated tile with the given animation interval and frame tiles.
   *
   * [frameDuration] The duration of each frame, in seconds
   * [frameTiles] An array of [StaticTiledMapTile]s that make up the animation. */
  AnimatedTiledMapTile (double frameDuration, List<StaticTiledMapTile> frameTiles) {
    _frameTiles = new List.from(frameTiles, growable: false);
    _frameDuration = frameDuration;
  }

}