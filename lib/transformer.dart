import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:glib/glib.dart' as glib;
import 'package:barback/barback.dart';
import 'package:mime/mime.dart' as mime;

class WebAssetsBundleGenerator extends AggregateTransformer{

  String assetsRoot = 'web/assets/';
  String assetsRootName;

  var imgExtensions = ['.jpg', '.png', '.bmp'];
  var audioExtensions = ['.mp3', '.ogg', '.wav'];
  var txtExtensions = ['.txt', '.json', '.xml', '.glsl', '.fnt', '.pack', '.atlas', '.obj', '.g3dj', '.tmx'];

  WebAssetsBundleGenerator.asPlugin(BarbackSettings settings){
    String paramRoot = settings.configuration['assetsRoot'];
    assetsRoot = paramRoot.replaceAll("\\", '/');
    if (!assetsRoot.endsWith('/')){
      assetsRoot += '/';
    }
    assetsRootName = assetsRoot;
    assetsRootName = assetsRootName.substring(0, assetsRootName.length - 1);
    
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

    // force auto-download of the embedded resources
    buffer
      ..write('t:')
      ..write(glib.DEFAULT_FONT_PATH)
      ..write(':21740') // oops, hardcoded size
      ..writeln(':${getCustomMimeType(glib.DEFAULT_FONT_PATH)}')
      
      ..write('i:')
      ..write(glib.DEFAULT_FONT_PATH.replaceFirst(".fnt", ".png"))
      ..write(':27253')
      ..writeln(':image/png');
    

    for(FileSystemEntity f in dir.listSync(recursive: true, followLinks: true)){
      var normalizedPath = f.path.replaceAll("\\", '/');
      if(normalizedPath.contains("/packages") )
        continue;

      buffer
        ..write(getFileCode(f))
        ..write(":${ normalizedPath.replaceAll(assetsRoot, '') }")
        ..write(":${getFileLength(f)}")
        ..writeln(":${getMimeType(f)}");
    }  
    

    AssetId id = new AssetId(transform.package, path.url.join(transform.key, "assets.txt"));
    Asset asset = new Asset.fromString(id, buffer.toString());
    transform.addOutput(asset);
    print("Auto generated: ${asset.id.path} \n${buffer.toString()}");
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
    String mimeType = "application/unknown";
    if (f != null){
      var type = mime.lookupMimeType(f.path);
      if (type != null)
        mimeType = type;
      else{
        var customMime = getCustomMimeType(f.path);
        if (customMime != null)
          mimeType = customMime; 
      }
    }
    return mimeType;
  }

  String getCustomMimeType(String filePath){
    // get mime from file extensions
    String extension = path.extension(filePath);
    if ( isOf(extension, txtExtensions)){
      return "text/plain";
    }

    return null;
  }

  int getFileLength(FileSystemEntity f){
    if (f is File)
      return f.lengthSync();
    return 0; //dir or link?
  }


}