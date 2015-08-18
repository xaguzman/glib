part of glib.graphics;

class TiledMap extends GameMap {
  /// Used by loaders to set resources when loading the map directly, without [AssetManager]. To be disposed in [dispose].
  List<Disposable> ownedResources;
  final TiledMapTileSets tileSets = new TiledMapTileSets();

  @override
  dispose(){
    if (ownedResources != null) {
      ownedResources.forEach((Disposable res) => res.dispose());
      ownedResources.clear();
    }
  }
}