part of glib.graphics;

class TiledMapTileSet extends Iterable<TiledMapTile>{

  String name;
  final Map<int, TiledMapTile> _tiles;
  final GameMapProperties properties;

  TiledMapTileSet() :
    _tiles = new Map<int, TiledMapTile>(),
    properties = new GameMapProperties();

  TiledMapTile getTile(int id) => _tiles[id];
  void putTile(int id, TiledMapTile tile) {
    _tiles[id] = tile;
  }

  void removeTile(int id) {
    _tiles.remove(id);
  }

  int get size => _tiles.length;

  @override
  Iterator<TiledMapTile> get iterator => _tiles.values.iterator;
}

class TiledMapTileSets extends Iterable<TiledMapTileSet>{

  final List<TiledMapTileSet> _tileSets = new List();

  TiledMapTileSet getSetByIdx(int idx) => _tileSets[idx];
  TiledMapTileSet getSetByName(String name) => _tileSets.firstWhere((TiledMapTileSet set) => set.name == name);
  TiledMapTileSet operator [](idx_Or_Name){
    if (idx_Or_Name is int)
      return getSetByIdx(idx_Or_Name);
    else if (idx_Or_Name is String)
      return getSetByName(idx_Or_Name);

    return null;
  }

  void add(TiledMapTileSet s) => _tileSets.add(s);
  void removeIndex(int idx) {
    _tileSets.removeAt(idx);
  }

  void remove(TiledMapTileSet set){
    _tileSets.remove(set);
  }

  TiledMapTile getTile(int id){
    // The purpose of backward iteration here is to maintain backwards compatibility
    // with maps created with earlier versions of a shared tileset.  The assumption
    // is that the tilesets are in order of ascending firstgid, and by backward
    // iterating precedence for conflicts is given to later tilesets in the list,
    // which are likely to be the earlier version of any given gid.
    // See TiledMapModifiedExternalTilesetTest for example of this issue.
    for (TiledMapTileSet tileset in _tileSets.reversed ){
      TiledMapTile tile = tileset.getTile(id);
      if (tile != null) {
        return tile;
      }
    }

    return null;
  }

  @override
  Iterator<TiledMapTileSet> get iterator => null;
}