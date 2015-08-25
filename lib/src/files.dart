library glib.files;

abstract class Files{

  FileHandle getFileHandle (String path, FileType type);

  @override
  FileHandle classpath (String path);

  @override
  FileHandle internal (String path);

  @override
  String getExternalStoragePath ();

  @override
  bool isExternalStorageAvailable ();

  @override
  String getLocalStoragePath ();

  @override
  bool isLocalStorageAvailable ();
}

abstract class FileHandle{
  String get name;
  String get nameWithoutExtension;
  String get extension;
  String get path;
  String get pathWithoutExtension;
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