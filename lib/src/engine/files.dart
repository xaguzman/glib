library glib.files;

abstract class Files{

  FileHandle getFileHandle (String path, FileType type);
  FileHandle classpath (String path);
  FileHandle internal (String path);
  String getExternalStoragePath ();
  bool isExternalStorageAvailable ();
  String getLocalStoragePath ();
  bool isLocalStorageAvailable ();
  dynamic load(String filePath);
}

abstract class FileHandle{
  String get name;
  String get nameWithoutExtension;
  String get extension;
  String get path;
  String get pathWithoutExtension;
  int get length;
  FileType get fileType;
  List<int> readBytes();
  String readString([String charset = 'utf-8']);
  List<FileHandle> list({String prefix: null, String suffix: null, String contains: null});
  bool isDirectory();
  FileHandle child(String name);
  FileHandle parent();
  FileHandle sibling(String name) => parent().child(name);
  @override toString() => path;
}

enum FileType{
  Internal,
  Classpath
}