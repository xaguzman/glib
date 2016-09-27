part of glib.web;

class WebTexture extends Texture{
  @override WebGLTexture glTexture;


  void uploadCanvas(CanvasElement canvas, {int level:0, int format:GL.RGBA, int type:GL.UNSIGNED_BYTE, bool genMipMaps:false}){
    width = canvas.width;
    height = canvas.height;

    _graphics.gl.texImage2DCanvas(glTarget, level, format, format, type, canvas);

    if(genMipMaps)
      _graphics.gl.generateMipmap(glTarget);
  }

  void uploadImage(ImageElement img, {int level:0, int format:GL.RGBA, int type:GL.UNSIGNED_BYTE, bool genMipMaps:false}){

    width = img.width;
    height = img.height;

//    _graphics.gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 1);
    _graphics.gl.texImage2DImage(glTarget,  level,  format,  format,  type, img);



    if(genMipMaps)
      _graphics.gl.generateMipmap(glTarget);
  }
}

void _loadImageElement(ImageElement img, WebTexture target){
  target
    ..width = img.width
    ..height = img.height
    ..bind()
    ..uploadImage(img)
    ..setFilter(target.minFilter, target.magFilter, force: true)
    ..setWrap(target.uWrap, target.uWrap, force: true);

  Glib.gl.bindTexture(target.glTarget, target.glTexture);
  target.loadCompleter.complete(target);
}