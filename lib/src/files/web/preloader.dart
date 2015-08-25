part of glib.webfiles;

class _Preloader {

  final String baseUrl;

  _Preloader(this.baseUrl);

  void preload(String assetFileUrl) async {
    AssetLoader loader = new AssetLoader();

    var assetFileDescriptor = loader.loadText(_path.url.join(baseUrl, assetFileUrl));

    assetFileDescriptor.then( (String content){
      var lines = content.split("\n");
      List<Asset> assets = new List(lines.length);
      for (String line in lines){
        var tokens = line.split(":");
        if ( tokens.length != 4)
          throw "Invalid assets description file";
        AssetType type;
        switch(tokens[0]){
          case "i":
            type = AssetType.Image;
            break;
          case "b":
            type = AssetType.Binary;
            break;
          case "a":
            type = AssetType.Audio;
            break;
          case "d":
            type = AssetType.Directory;
            break;
          default:
            type = AssetType.Text;
        }
        int size = int.parse(tokens[2]);
//        if (type == AssetType.Audio && !loader.isUseBrowserCache)
//          size = 0;
        assets.add(new Asset(tokens[1].trim(), type, size, tokens[3]));
        PreloaderState state = new PreloaderState(assets);

        for (Asset asset in assets){
          if (contains(asset.url)){
            asset.loaded = asset.size;
            asset.succeed = true;
            continue;
          }

          var assetListener = loader.load(_path.url.join(baseUrl, asset.url), asset._type, asset.mimetype, (amount){
            asset.loaded = amount;
            callback.update(state);
          });

          assetListener.catchError((error){
            asset.failed = true;
            callback.error(asset.url);
            callback.update(state);
          });

          assetListener.then( (result) {
            switch (asset._type) {
              case AssetType.Text:
                txts[asset.url] = result;
                break;
              case AssetType.Image:
                imgs[asset.url] = result;
                break;
              case AssetType.Binary:
                binaries[asset.url] = result;
                break;
              case AssetType.Audio:
                audio.add(asset.url);
                break;
              case AssetType.Directory:
                dirs.add(asset.url);
                break;
            }
            asset.succeed = true;
            callback.update(state);
          });
        }
        callback.update(state);
      }

    });
  }

  Map<String, ImageElement> imgs = new Map();
  Map<String, String> txts = new Map();
  Map<String, Blob> binaries = new Map();
  List<String> dirs = new List();
  List<String> audio = new List();

  List<FileHandle> list(String url, String prefix, String suffix, String contains) {

    var filterApplies = (String path){
      bool accepted = true;
      if (prefix != null){
        accepted = url.startsWith(prefix);
      }
      if (contains != null){
        accepted = accepted && url.contains(contains);
      }
      if (suffix != null){
        accepted = accepted && url.endsWith(suffix);
      }
      return accepted;
    };

    List<FileHandle> files = new List();
    for (String path in txts.keys){
      if (isChild(path, url) && filterApplies(path)){
        files.add(new WebFileHandle._(this, path, FileType.Internal));
      }
    }

    return files;
  }

  bool isChild(String path, String url){
    return path.startsWith(url) && (path.indexOf('/', url.length + 1) < 0);
  }

  int length(String file){
    if (txts.containsKey(file)){
      try{
        return UTF8.encoder.convert(txts[file]).length;
      } on Error{
        return txts[file].codeUnits.length;
      }
    }
    if (imgs.containsKey(file) || binaries.containsKey(file) || audio.contains(file)){
      return 1;
    }
    return 0;
  }

  bool contains (String url) =>
    txts.containsKey(url) || imgs.containsKey(url) || binaries.containsKey(url) ||
    audio.contains(url) || dirs.contains(url);

  bool isText(String file) => txts.containsKey(file);
  bool isImage (String url) => imgs.containsKey(url);
  bool isBinary (String url) => binaries.containsKey(url);
  bool isAudio (String url) => audio.contains(url);
  bool isDirectory (String url) => dirs.contains(url);
}

class PreloaderState {

  final List<Asset> assets;

  PreloaderState(this.assets);

  int get downloadedSize {
    int size = 0;
    for (int i = 0; i < assets.length; i++) {
      Asset asset = assets[i];
      size += (asset.succeed || asset.failed) ? asset.size : Math.min(asset.size, asset.loaded);
    }
    return size;
  }

  int get totalSize{
    int size = 0;
    for (int i = 0; i < assets.length; i++) {
      Asset asset = assets[i];
      size += asset.size;
    }
    return size;
  }

  double getProgress() {
    double total = totalSize.toDouble();
    return total == 0 ? 1 : (downloadedSize / total);
  }

  bool hasEnded() => downloadedSize == totalSize;
}