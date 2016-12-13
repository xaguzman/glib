part of glib.web;

class WebFiles implements Files {
//  static final Storage LocalStorage = Storage.getLocalStorageIfSupported();

  final _Preloader preloader;

  WebFiles(this.preloader);

  @override
  FileHandle getFileHandle (String path, FileType type) {
    if (type != FileType.Internal) throw "FileType '$type' not supported";
    return new WebFileHandle._(preloader, path, type);
  }

  @override
  FileHandle classpath (String path) {
    return new WebFileHandle._(preloader, path, FileType.Classpath);
  }

  @override
  FileHandle internal (String path) {
    return new WebFileHandle._(preloader, path, FileType.Internal);
  }

//  @override
//  FileHandle external (String path) {
//    throw new GdxRuntimeException("Not supported in GWT backend");
//  }
//
//  @override
//  FileHandle absolute (String path) {
//    throw new GdxRuntimeException("Not supported in GWT backend");
//  }
//
//  @override
//  FileHandle local (String path) {
//    throw new GdxRuntimeException("Not supported in GWT backend");
//  }

  @override
  String getExternalStoragePath () {
    return null;
  }

  @override
  bool isExternalStorageAvailable () {
    return false;
  }

  @override
  String getLocalStoragePath () {
    return null;
  }

  @override
  bool isLocalStorageAvailable () {
    return false;
  }

  dynamic load(filePath_OR_fileHandle){
    if (filePath_OR_fileHandle is FileHandle){
      return preloader.load(filePath_OR_fileHandle.path);
    }
    return preloader.load(filePath_OR_fileHandle );
  }
}

class WebFileHandle implements FileHandle{

  final _Preloader preloader;
  final String file;
  final FileType _type;

  WebFileHandle._(this.preloader, this.file, this._type);

  @override
  FileHandle child(String name) =>
    new WebFileHandle._(preloader, (file.isEmpty ? "" : (file + (file.endsWith("/") ? "" : "/"))) + name, FileType.Internal);

  @override
  String get extension => _path.url.extension(file);

  @override
  FileType get fileType => _type;

  @override
  bool get isDirectory => preloader.isDirectory(file);

  @override
  List<FileHandle> list({String prefix: null, String suffix: null, String contains: null}) =>
    preloader.list(file, prefix, suffix, contains);

  @override
  String get name => _path.url.basename(file);

  @override
  String get nameWithoutExtension => _path.url.basenameWithoutExtension(file);

  @override
  FileHandle parent() {
    int index = file.lastIndexOf("/");
    String dir = "";
    if (index > 0) dir = file.substring(0, index);
    return new WebFileHandle._(preloader, dir, _type);
  }

  @override
  String get path => file;

  @override
  String get pathWithoutExtension => _path.url.withoutExtension(file);

  @override
  List<int> readBytes() => preloader.readBytes(file);

  @override
  int get length => preloader.length(file);

  @override
  String readString([String charset = 'utf-8']) {
    if (preloader.isText(file))
      return preloader.txts[file];
    try{
      return UTF8.decoder.convert(readBytes());
    }on Error{
      return '';
    }
  }

  @override
  FileHandle sibling(String name) => parent().child(name);
}