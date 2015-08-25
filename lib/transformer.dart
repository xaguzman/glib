import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:barback/barback.dart';
import 'package:mime/mime.dart' as mime;

class WebAssetsBundleGenerator extends AggregateTransformer{

  String assetsRoot = 'web/assets/';
  String assetsRootName;

  var imgExtensions = ['.jpg', '.png', '.bmp'];
  var audioExtensions = ['.mp3', '.ogg', '.wav'];
  var txtExtensions = ['.txt', '.json', '.xml', '.glsl', '.fnt', '.pack', '.atlas', '.obj', '.g3dj'];

  WebAssetsBundleGenerator.asPlugin(BarbackSettings settings){
    String paramRoot = settings.configuration['assetsRoot'];
    assetsRoot = paramRoot.replaceAll("\\", '/');
    assetsRootName = assetsRoot;
    if (assetsRootName.endsWith("/")){
      assetsRootName = assetsRootName.substring(0, assetsRootName.length - 1);
    }
  }

  @override
  classifyPrimary(AssetId id) {
    if ( path.url.dirname(id.path) != assetsRootName)
      return null;

    return path.url.dirname(id.path);
  }

  @override
  apply(AggregateTransform transform) {
    Directory dir = new Directory(transform.key);
    StringBuffer buffer = new StringBuffer();

    for(FileSystemEntity f in dir.listSync(recursive: true, followLinks: true)){
      buffer
        ..write(getFileCode(f))
        ..write(":${ f.path.replaceAll(assetsRoot, '') }")
        ..write(":${getFileLength(f)}")
        ..writeln(":${getMimeType(f)}");

    }
    AssetId id = new AssetId(transform.package, path.url.join(transform.key, "assets.txt"));
    Asset asset = new Asset.fromString(id, buffer.toString());
  }

  bool isOf(String extension, List allowedExtensions) => allowedExtensions.contains(extension);

  String getFileCode(FileSystemEntity f){
    if (f is Directory)
      return "d";
    String extension = path.extension(f.path);

    if(isOf(extension, imgExtensions))
      return "i";

    if (isOf(extension, audioExtensions))
      return "a";

    if (isOf(extension, txtExtensions))
      return "t";

    return "b";
  }

  String getMimeType(FileSystemEntity f){
    var mimeType = mime.lookupMimeType(f.path);
    if (mimeType == null)
      mimeType = "application/unknown";
    return mimeType;
  }

  int getFileLength(FileSystemEntity f){
    if (f is File)
      return f.lengthSync();
    return 0; //dir or link?
  }


}