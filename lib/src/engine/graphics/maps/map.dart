part of glib.graphics;

/** A generic level map implementation.
 *
 * A map has [GameMapProperties] which describe general attributes. Availability of properties depends on the type of map, e.g.
 * what format is was loaded from etc.
 *
 * A map has [GameMapLayers]. Map layers are ordered and indexed. A [GameMapLayer] contains [GameMapObjects] which represent
 * things within the layer. Different types of [GameMapObject] are available, e.g. [CircleMapObject],
 * [TextureMapObject], and so on.
 *
 * A map can be rendered by a [MapRenderer]. A MapRenderer implementation may chose to only render specific MapObject or
 * MapLayer types.
 *
 * There are more specialized implementations of Map for specific use cases. e.g. the [TiledMap] class and its associated
 * classes add functionality specifically for tile maps on top of the basic map functionality.
 *
 * Maps must be disposed through a call to [dispose] when no longer used. */
class GameMap implements Disposable{

  final GameMapLayers layers = new GameMapLayers();
  final GameMapProperties properties = new GameMapProperties();

  @override
  void dispose(){ }
}

class GameMapLayer{
  String name;

  double opacity = 1.0;
  bool isVisible = true;

  final GameMapObjects objects = new GameMapObjects();
  final GameMapProperties properties = new GameMapProperties();
}

/// A collection of [MapLayer]
class GameMapLayers extends Iterable<GameMapLayer> {
  List<GameMapLayer> _layers = new List();

  GameMapLayer getByIdx(int idx) => _layers[idx];
  GameMapLayer getByName(String name) => _layers.firstWhere( (GameMapLayer layer) => layer.name == name);

  GameMapLayer operator [](idx_OR_name){
    if(idx_OR_name is int)
      return _layers[idx_OR_name];
    else if( idx_OR_name is String){
      return getByName(idx_OR_name);
    }

    return null;
  }

  int get count => _layers.length;

  void add(GameMapLayer layer) => _layers.add(layer);

  void remove(GameMapLayer layer) { _layers.remove(layer); }

  GameMapLayer removeAt(int idx) => _layers.removeAt(idx);

  @override
  Iterator<GameMapLayer> get iterator => _layers.iterator;
}


class GameMapObject {
  String name;
  double opacity = 1.0;
  bool isVisible = true;
  Color color = Color.WHITE.copy();
}

/// A collection of [MapLayer]
class GameMapObjects extends Iterable<GameMapObject> {
  List<GameMapObject> _objects = new List();

  GameMapObject getByIdx(int idx) => _objects[idx];
  GameMapObject getByName(String name) => _objects.firstWhere( (GameMapObject obj) => obj.name == name);

  GameMapObject operator [](idx_OR_name){
    if(idx_OR_name is int)
      return _objects[idx_OR_name];
    else if( idx_OR_name is String){
      return getByName(idx_OR_name);
    }

    return null;
  }

  int get count => _objects.length;

  void add(GameMapObject layer) => _objects.add(layer);

  void remove(GameMapObject layer) { _objects.remove(layer); }

  GameMapObject removeAt(int idx) => _objects.removeAt(idx);

    @override
  Iterator<GameMapObject> get iterator => _objects.iterator;
}

class GameMapProperties {
  Map<String, Object> _properties;

  bool containsKey(String key) => _properties.containsKey(key);

  dynamic get(String key, dynamic defaultValue) => _properties.containsKey(key) ? _properties[key] : defaultValue;

  void put(String key, dynamic value) => _properties[key] = value;

  void putAll(GameMapProperties otherProperties){
    otherProperties.forEach( (String key, value){
      _properties[key] = value;
    });
  }

  Object remove(String key) => _properties.remove(key);

  void clear() => _properties.clear();

  void forEach(void function(String key, dynamic value)) => _properties.forEach( function );

  Iterable<String> get keys => _properties.keys;
  Iterable<Object> get values => _properties.values;
}