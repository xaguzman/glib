part of glib.common;

class GlibException implements Exception{
  String msg;
  
  GlibException(String this.msg);
  
  toString() => msg;
}

class ResourceLoadingException extends GlibException{  
  ResourceLoadingException.forUrl(String url): super('Unable to load resource: $url');
  ResourceLoadingException(String msg, String url) :super('$msg: $url');
}

