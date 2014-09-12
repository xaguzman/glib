part of glib.common;

class ResourceLoadingException implements Exception{
  String _msg;
  
  ResourceLoadingException(String url){
    _msg = 'Unable to load resource: $url';
  }
  
  toString() => _msg;
}