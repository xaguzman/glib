part of glib.graphics;

class TextFileLoader{
  Completer<String> _completer = new Completer();
  Future<String> get done => _completer.future;

  String _url;
  String _text;
  
  TextFileLoader(this._url );
  
  load(){
    Asset asset = new Asset(null, _url, _url, 'bitmapfont', null, {}, null, {});
    new TextLoader().load(asset, new NullAssetPackTrace()).then((String text) 
    {
      _completer.complete(text);
    });
  }
}