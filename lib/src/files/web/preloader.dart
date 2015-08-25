part of glib.webfiles;

class _Preloader {

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

  bool isText(String file) => txts.containsKey(file);
  bool isImage (String url) => imgs.containsKey(url);
  bool isBinary (String url) => binaries.containsKey(url);
  bool isAudio (String url) => audio.contains(url);
  bool isDirectory (String url) => dirs.contains(url);
}