part of glib.files;

class _Preloader{

}

class WebFiles implements Files {
//  static final Storage LocalStorage = Storage.getLocalStorageIfSupported();

  final _Preloader preloader;

  Files (_Preloader preloader) {
    this.preloader = preloader;
  }

  @override
  FileHandle getFileHandle (String path, FileType type) {
    if (type != FileType.Internal) throw new GdxRuntimeException("FileType '" + type + "' not supported in GWT backend");
    return new GwtFileHandle(preloader, path, type);
  }

  @override
  FileHandle classpath (String path) {
    return new GwtFileHandle(preloader, path, FileType.Classpath);
  }

  @override
  FileHandle internal (String path) {
    return new GwtFileHandle(preloader, path, FileType.Internal);
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
  boolean isExternalStorageAvailable () {
    return false;
  }

  @override
  String getLocalStoragePath () {
    return null;
  }

  @override
  boolean isLocalStorageAvailable () {
    return false;
  }
}

class WebFileHandle implements FileHandle{

}