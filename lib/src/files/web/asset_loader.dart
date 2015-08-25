part of glib.webfiles;

abstract class AssetLoader{

  static Future<dynamic> httpLoad( String url, String responseType,
                                   dynamic extractResponse(HttpRequest), [OnProgress listener] ) {

    var completer = new Completer<dynamic>();

    var xhr = new HttpRequest();
    xhr.open('GET', url, async: true);
    xhr.responseType = responseType;

    xhr.onLoad.listen((e) {
      // Note: file:// URIs have status of 0.
      if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 0 || xhr.status == 304)
        completer.complete(extractResponse(xhr));
      else
        completer.complete(null);
    });

    xhr.onError.listen((e) {
      completer.complete(null);
    });

    xhr.onProgress.listen((ProgressEvent e){
      if (listener != null)
        listener(e.loaded);
    });

    xhr.send();
    return completer.future;
  }

  Future<String> loadText(String url) => httpLoad(url, 'text', (x) =>  x.responseText);
  Future<List<int>> loadBinary(String url) => httpLoad(url, 'arraybuffer', (x) =>  x.response);
  Future<Blob> loadAudio(String url) => httpLoad(url, 'blob', (x) =>  x.response);

  Future<ImageElement> loadImage(String url){
    var completer = new Completer<dynamic>();

    ImageElement image = new ImageElement();
    image.onLoad.listen((event) {
      completer.complete(image);
    });
    image.onError.listen((event) {
      completer.complete(null);
    });
    image.src = url;
    return completer.future;
  }

//  Future<List<int>> loadAudio(String url);

}

typedef void OnProgress(num amount);

class Asset {
  final String url, mimetype;
  final int size;
  final AssetType _type;

  bool succeed, failed;
  int loaded = 0;

  Asset(this.url, this._type, this.size, this.mimetype);
}

class AssetType {
  final String code;

  const AssetType._(this.code);

  static const AssetType Image = const AssetType._("i");
  static const AssetType Audio = const AssetType._("a");
  static const AssetType Text = const AssetType._("t");
  static const AssetType Binary = const AssetType._("b");
  static const AssetType Directory = const AssetType._("d");

}