part of glib.graphics;

class TextureLoader {//implements AssetLoader{
  Completer<ImageElement> _completer = new Completer();
  Future<ImageElement> get done => _completer.future;

  ImageElement img = new ImageElement();
  String _url;
  
  TextureLoader(this._url ){
    img.onLoad.listen((e) => _completer.complete(img));
    img.onError.listen(
        (e) => _completer.completeError('Could not load texture $_url. Error: $e'));
  }
  
  load(){
    img.src = _url; 
  }
  
}