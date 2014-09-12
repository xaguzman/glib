part of glib.common;

abstract class Disposable{
  void dispose();
}

abstract class AssetLoader<T>{
  Future<T> get done;
//  Future<T> get error;
  load();
}