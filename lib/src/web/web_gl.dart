part of glib.web;

class WebGL implements GL{

  GLNative.RenderingContext _webGL;

  WebGLContextAttributes _attributes;
  List<WebGLShader> _shaders = new List.generate(2, (idx) => new WebGLShader(), growable: false);
  WebGLShaderPrecisionFormat _shaderPrecisionFormat = new WebGLShaderPrecisionFormat();
  WebGLActiveInfo _activeAttr = new WebGLActiveInfo();
  WebGLActiveInfo _activeUniform = new WebGLActiveInfo();
  WebGLUniformLocation _uniformLocation = new WebGLUniformLocation();

  WebGL(this._webGL) :
    _attributes = new WebGLContextAttributes(){
    _attributes.nativeContextAttributes = _webGL.getContextAttributes();
  }

  @override int get drawingBufferHeight => _webGL.drawingBufferHeight;
  @override int get drawingBufferWidth => _webGL.drawingBufferWidth;

  @override void activeTexture(int texture) => _webGL.activeTexture(texture);

  @override void attachShader(WebGLProgram program, WebGLShader shader) => _webGL.attachShader(program?.nativeProgram, shader?.nativeShader);

  @override void bindAttribLocation(WebGLProgram program, int index, String name) =>_webGL.bindAttribLocation(program?.nativeProgram, index, name);

  @override void bindBuffer(int target, WebGLBuffer buffer) => _webGL.bindBuffer(target, buffer?.nativeBuffer);

  @override void bindFramebuffer(int target, WebGLFramebuffer framebuffer) => _webGL.bindFramebuffer(target, framebuffer?.nativeFramebuffer);

  @override void bindRenderbuffer(int target, WebGLRenderbuffer renderbuffer) => _webGL.bindRenderbuffer(target, renderbuffer?.nativeRenderbuffer);

  @override void bindTexture(int target, WebGLTexture texture) => _webGL.bindTexture(target, texture.nativeTexture);

  @override void blendColor(num red, num green, num blue, num alpha) => _webGL.blendColor(red, green, blue, alpha);

  @override void blendEquation(int mode)=> _webGL.blendEquation(mode);

  @override void blendEquationSeparate(int modeRGB, int modeAlpha) => _webGL.blendEquationSeparate(modeRGB, modeAlpha);

  @override void blendFunc(int sfactor, int dfactor) => _webGL.blendFunc(sfactor, dfactor);

  @override void blendFuncSeparate(int srcRGB, int dstRGB, int srcAlpha, int dstAlpha) => _webGL.blendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);

  @override void bufferByteData(int target, ByteBuffer data, int usage) => _webGL.bufferByteData(target, data, usage);

  @override void bufferDataTyped(int target, TypedData data, int usage) => _webGL.bufferDataTyped(target, data, usage);

  @override void bufferSubByteData(int target, int offset, ByteBuffer data) => _webGL.bufferSubByteData(target, offset, data);

  @override void bufferSubData(int target, int offset, data) => _webGL.bufferSubData(target, offset, data);

  @override void bufferSubDataTyped(int target, int offset, TypedData data) => _webGL.bufferSubDataTyped(target, offset, data);

  @override int checkFramebufferStatus(int target) => checkFramebufferStatus(target);

  @override void clear(int mask) => _webGL.clear(mask);

  @override void clearColor(num red, num green, num blue, num alpha) => _webGL.clearColor(red, green, blue, alpha);

  @override void clearDepth(num depth) => _webGL.clearDepth(depth);

  @override void clearStencil(int s) => _webGL.clearStencil(s);

  @override void colorMask(bool red, bool green, bool blue, bool alpha) => _webGL.colorMask(red, green, blue, alpha);

  @override void compileShader(WebGLShader shader) => _webGL.compileShader(shader?.nativeShader);

  @override void compressedTexImage2D(int target, int level, int internalformat, int width, int height, int border, TypedData data)
  => _webGL.compressedTexImage2D(target, level, internalformat, width, height, border, data);

  @override void compressedTexSubImage2D(int target, int level, int xoffset, int yoffset, int width, int height, int format, TypedData data)
  => _webGL.compressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, data);

  @override void copyTexImage2D(int target, int level, int internalformat, int x, int y, int width, int height, int border)
  => _webGL.copyTexImage2D(target, level, internalformat, x, y, width, height, border);

  @override void copyTexSubImage2D(int target, int level, int xoffset, int yoffset, int x, int y, int width, int height)
  => _webGL.copyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height);

  @override WebGLBuffer createBuffer() => new WebGLBuffer()..nativeBuffer = _webGL.createBuffer();

  @override WebGLFramebuffer createFramebuffer() => new WebGLFramebuffer()..nativeFramebuffer = _webGL.createFramebuffer();

  @override WebGLProgram createProgram() => new WebGLProgram()..nativeProgram = _webGL.createProgram();

  @override WebGLRenderbuffer createRenderbuffer() => new WebGLRenderbuffer()..nativeRenderbuffer = _webGL.createRenderbuffer();

  @override WebGLShader createShader(int type) => new WebGLShader()..nativeShader = _webGL.createShader(type);

  @override GLTexture createTexture() => new WebGLTexture()..nativeTexture = _webGL.createTexture();

  @override void cullFace(int mode)=> _webGL.cullFace(mode);

  @override void deleteBuffer(WebGLBuffer buffer) => _webGL.deleteBuffer(buffer?.nativeBuffer);

  @override void deleteFramebuffer(WebGLFramebuffer framebuffer) => _webGL.deleteFramebuffer(framebuffer?.nativeFramebuffer);

  @override void deleteProgram(WebGLProgram program) => _webGL.deleteProgram(program?.nativeProgram);

  @override void deleteRenderbuffer(WebGLRenderbuffer renderbuffer) => _webGL.deleteRenderbuffer(renderbuffer?.nativeRenderbuffer);

  @override void deleteShader(WebGLShader shader) => _webGL.deleteShader(shader?.nativeShader);

  @override void deleteTexture(WebGLTexture texture) => _webGL.deleteTexture(texture.nativeTexture);

  @override void depthFunc(int func) => _webGL.depthFunc(func);

  @override void depthMask(bool flag) => _webGL.depthMask(flag);

  @override void depthRange(num zNear, num zFar) => _webGL.depthRange(zNear, zFar);

  @override void detachShader(WebGLProgram program, WebGLShader shader) => _webGL.detachShader(program?.nativeProgram, shader?.nativeShader);

  @override void disable(int cap) => _webGL.disable(cap);

  @override void disableVertexAttribArray(int index) => _webGL.disableVertexAttribArray(index);

  @override void drawArrays(int mode, int first, int count) => _webGL.drawArrays(mode, first, count);

  @override void drawElements(int mode, int count, int type, int offset) => _webGL.drawElements(mode, count, type, offset);

  @override void enable(int cap) => _webGL.enable(cap);

  @override void enableVertexAttribArray(int index) => _webGL.enableVertexAttribArray(index);

  @override void finish() => _webGL.finish();

  @override void flush() => _webGL.flush();

  @override void framebufferRenderbuffer(int target, int attachment, int renderbuffertarget, WebGLRenderbuffer renderbuffer)
    => _webGL.framebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer?.nativeRenderbuffer);

  @override void framebufferTexture2D(int target, int attachment, int textarget, WebGLTexture texture, int level)
  => _webGL.framebufferTexture2D(target, attachment, textarget, texture.nativeTexture, level);

  @override void frontFace(int mode) => _webGL.frontFace(mode);

  @override void generateMipmap(int target) => _webGL.generateMipmap(target);

  @override WebGLActiveInfo getActiveAttrib(WebGLProgram program, int index) => _activeAttr..nativeActiveInfo = _webGL.getActiveAttrib(program?.nativeProgram, index);

  @override WebGLActiveInfo getActiveUniform(WebGLProgram program, int index) => _activeUniform..nativeActiveInfo = _webGL.getActiveUniform(program?.nativeProgram, index);

  @override List<WebGLShader> getAttachedShaders(WebGLProgram program){
    int idx = 0;
  _webGL.getAttachedShaders(program?.nativeProgram).forEach( (shader){
    _shaders[idx++].nativeShader = shader;
  });
  return _shaders;
  }

  @override int getAttribLocation(WebGLProgram program, String name) => _webGL.getAttribLocation(program?.nativeProgram, name);

  @override Object getBufferParameter(int target, int pname) => _webGL.getBufferParameter(target, pname);

  @override WebGLContextAttributes getContextAttributes() => _attributes..nativeContextAttributes = _webGL.getContextAttributes();

  @override int getError() => _webGL.getError();

  @override Object getExtension(String name) => _webGL.getExtension(name);

  @override Object getFramebufferAttachmentParameter(int target, int attachment, int pname) => _webGL.getFramebufferAttachmentParameter(target, attachment, pname);

  @override Object getParameter(int pname) => _webGL.getParameter(pname);

  @override String getProgramInfoLog(WebGLProgram program) => _webGL.getProgramInfoLog(program?.nativeProgram);

  @override Object getProgramParameter(WebGLProgram program, int pname) => _webGL.getProgramParameter(program?.nativeProgram, pname);

  @override Object getRenderbufferParameter(int target, int pname) => _webGL.getRenderbufferParameter(target, pname);

  @override String getShaderInfoLog(WebGLShader shader) => _webGL.getShaderInfoLog(shader?.nativeShader);

  @override Object getShaderParameter(WebGLShader shader, int pname) => _webGL.getShaderParameter(shader?.nativeShader, pname);

  @override WebGLShaderPrecisionFormat getShaderPrecisionFormat(int shadertype, int precisiontype)
   => _shaderPrecisionFormat..nativeShaderPrecisionFormat = _webGL.getShaderPrecisionFormat(shadertype, precisiontype);

  @override String getShaderSource(WebGLShader shader) => _webGL.getShaderSource(shader?.nativeShader);

  @override List<String> getSupportedExtensions() => _webGL.getSupportedExtensions();

  @override Object getTexParameter(int target, int pname) => _webGL.getTexParameter(target, pname);

  @override Object getUniform(WebGLProgram program, WebGLUniformLocation location) => _webGL.getUniform(program?.nativeProgram, location?.nativeUniformLocation);

  @override WebGLUniformLocation getUniformLocation(WebGLProgram program, String name) => _uniformLocation..nativeUniformLocation = _webGL.getUniformLocation(program?.nativeProgram, name);

  @override Object getVertexAttrib(int index, int pname) => _webGL.getVertexAttrib(index, pname);

  @override int getVertexAttribOffset(int index, int pname) => _webGL.getVertexAttribOffset(index, pname);

  @override void hint(int target, int mode) => _webGL.hint(target, mode);

  @override bool isBuffer(WebGLBuffer buffer) => _webGL.isBuffer(buffer?.nativeBuffer);

  @override bool isContextLost() => _webGL.isContextLost();

  @override bool isEnabled(int cap) => _webGL.isEnabled(cap);

  @override bool isFramebuffer(WebGLFramebuffer framebuffer) => _webGL.isFramebuffer(framebuffer?.nativeFramebuffer);

  @override bool isProgram(WebGLProgram program) => _webGL.isProgram(program?.nativeProgram);

  @override bool isRenderbuffer(WebGLRenderbuffer renderbuffer) => _webGL.isRenderbuffer(renderbuffer?.nativeRenderbuffer);

  @override bool isShader(WebGLShader shader) => _webGL.isShader(shader?.nativeShader);

  @override bool isTexture(WebGLTexture texture) => _webGL.isTexture(texture.nativeTexture);

  @override void lineWidth(num width) => _webGL.lineWidth(width);

  @override void linkProgram(WebGLProgram program) => _webGL.linkProgram(program?.nativeProgram);

  @override void pixelStorei(int pname, int param) => _webGL.pixelStorei(pname, param);

  @override void polygonOffset(num factor, num units) => _webGL.polygonOffset(factor, units);

  @override void readPixels(int x, int y, int width, int height, int format, int type, TypedData pixels)
    => _webGL.readPixels(x, y, width, height, format, type, pixels);

  @override void renderbufferStorage(int target, int internalformat, int width, int height)
  => _webGL.renderbufferStorage(target, internalformat, width, height);

  @override void sampleCoverage(num value, bool invert) => _webGL.sampleCoverage(value, invert);

  @override void scissor(int x, int y, int width, int height) => _webGL.scissor(x, y, width, height);

  @override void shaderSource(WebGLShader shader, String string) => _webGL.shaderSource(shader?.nativeShader, string);

  @override void stencilFunc(int func, int ref, int mask) => _webGL.stencilFunc(func, ref, mask);

  @override void stencilFuncSeparate(int face, int func, int ref, int mask) => _webGL.stencilFuncSeparate(face, func, ref, mask);

  @override void stencilMask(int mask) => _webGL.stencilMask(mask);

  @override void stencilMaskSeparate(int face, int mask) => _webGL.stencilMaskSeparate(face, mask);

  @override void stencilOp(int fail, int zfail, int zpass) => _webGL.stencilOp(fail, zfail, zpass);

  @override void stencilOpSeparate(int face, int fail, int zfail, int zpass) => _webGL.stencilOpSeparate(face, fail, zfail, zpass);

  @override void texImage2D(int target, int level, int internalformat, int format_OR_width, int height_OR_type, border_OR_canvas_OR_image_OR_pixels_OR_video, [int format, int type, TypedData pixels])
    => _webGL.texImage2D(target, level, internalformat, format_OR_width, height_OR_type, border_OR_canvas_OR_image_OR_pixels_OR_video, format, type, pixels);

  @override void texImage2DCanvas(int target, int level, int internalformat, int format, int type, CanvasElement canvas)
    => _webGL.texImage2DCanvas(target, level, internalformat, format, type, canvas);

  @override void texImage2DImage(int target, int level, int internalformat, int format, int type, ImageElement image)
    => _webGL.texImage2DImage(target, level, internalformat, format, type, image);

  @override void texImage2DImageData(int target, int level, int internalformat, int format, int type, ImageData pixels)
    => _webGL.texImage2DImageData(target, level, internalformat, format, type, pixels);

  @override void texImage2DVideo(int target, int level, int internalformat, int format, int type, VideoElement video)
    => _webGL.texImage2DVideo(target, level, internalformat, format, type, video);

  @override void texParameterf(int target, int pname, num param) => _webGL.texParameterf(target, pname, param);

  @override void texParameteri(int target, int pname, int param) => _webGL.texParameteri(target, pname, param);

  @override void texSubImage2D(int target, int level, int xoffset, int yoffset, int format_OR_width, int height_OR_type, canvas_OR_format_OR_image_OR_pixels_OR_video, [int type, TypedData pixels])
    => _webGL.texSubImage2D(target, level, xoffset, yoffset, format_OR_width, height_OR_type, canvas_OR_format_OR_image_OR_pixels_OR_video, type, pixels);

  @override void texSubImage2DCanvas(int target, int level, int xoffset, int yoffset, int format, int type, CanvasElement canvas)
    => _webGL.texSubImage2DCanvas(target, level, xoffset, yoffset, format, type, canvas);

  @override void texSubImage2DImage(int target, int level, int xoffset, int yoffset, int format, int type, ImageElement image)
    => _webGL.texSubImage2DImage(target, level, xoffset, yoffset, format, type, image);

  @override void texSubImage2DImageData(int target, int level, int xoffset, int yoffset, int format, int type, ImageData pixels)
    => _webGL.texSubImage2DImageData(target, level, xoffset, yoffset, format, type, pixels);

  @override void texSubImage2DVideo(int target, int level, int xoffset, int yoffset, int format, int type, VideoElement video)
    => _webGL.texSubImage2DVideo(target, level, xoffset, yoffset, format, type, video);

  @override void uniform1f(WebGLUniformLocation location, num x) => _webGL.uniform1f(location?.nativeUniformLocation, x);

  @override void uniform1fv(WebGLUniformLocation location, Float32List v) => _webGL.uniform1fv(location?.nativeUniformLocation, v);

  @override void uniform1i(WebGLUniformLocation location, int x) => _webGL.uniform1i(location?.nativeUniformLocation, x);

  @override void uniform1iv(WebGLUniformLocation location, Int32List v) => _webGL.uniform1iv(location?.nativeUniformLocation, v);

  @override void uniform2f(WebGLUniformLocation location, num x, num y) => _webGL.uniform2f(location?.nativeUniformLocation, x, y);

  @override void uniform2fv(WebGLUniformLocation location, Float32List v) => _webGL.uniform2fv(location?.nativeUniformLocation, v);

  @override void uniform2i(WebGLUniformLocation location, int x, int y) => _webGL.uniform2i(location?.nativeUniformLocation, x, y);

  @override void uniform2iv(WebGLUniformLocation location, Int32List v) => _webGL.uniform2iv(location?.nativeUniformLocation, v);

  @override void uniform3f(WebGLUniformLocation location, num x, num y, num z) => _webGL.uniform3f(location?.nativeUniformLocation, x, y, z);

  @override void uniform3fv(WebGLUniformLocation location, Float32List v) => _webGL.uniform3fv(location?.nativeUniformLocation, v);

  @override void uniform3i(WebGLUniformLocation location, int x, int y, int z) => _webGL.uniform3i(location?.nativeUniformLocation, x, y, z);

  @override void uniform3iv(WebGLUniformLocation location, Int32List v) => _webGL.uniform3iv(location?.nativeUniformLocation, v);

  @override void uniform4f(WebGLUniformLocation location, num x, num y, num z, num w) => _webGL.uniform4f(location?.nativeUniformLocation, x, y, z, w);

  @override void uniform4fv(WebGLUniformLocation location, Float32List v) => _webGL.uniform4fv(location?.nativeUniformLocation, v);

  @override void uniform4i(WebGLUniformLocation location, int x, int y, int z, int w) => _webGL.uniform4i(location?.nativeUniformLocation, x, y, z, w);

  @override void uniform4iv(WebGLUniformLocation location, Int32List v) => _webGL.uniform4iv(location?.nativeUniformLocation, v);

  @override void uniformMatrix2fv(WebGLUniformLocation location, bool transpose, Float32List array) => _webGL.uniformMatrix2fv(location?.nativeUniformLocation, transpose, array);

  @override void uniformMatrix3fv(WebGLUniformLocation location, bool transpose, Float32List array) => _webGL.uniformMatrix3fv(location?.nativeUniformLocation, transpose, array);

  @override void uniformMatrix4fv(WebGLUniformLocation location, bool transpose, Float32List array)  => _webGL.uniformMatrix4fv(location?.nativeUniformLocation, transpose, array);

  @override void useProgram(WebGLProgram program) => _webGL.useProgram(program?.nativeProgram);

  @override void validateProgram(WebGLProgram program) => _webGL.validateProgram(program?.nativeProgram);

  @override void vertexAttrib1f(int indx, num x) => _webGL.vertexAttrib1f(indx, x);

  @override void vertexAttrib1fv(int indx, Float32List values) => _webGL.vertexAttrib1fv(indx, values);

  @override void vertexAttrib2f(int indx, num x, num y) => _webGL.vertexAttrib2f(indx, x, y);

  @override void vertexAttrib2fv(int indx, Float32List values) => _webGL.vertexAttrib2fv(indx, values);

  @override void vertexAttrib3f(int indx, num x, num y, num z) => _webGL.vertexAttrib3f(indx, x, y, z);

  @override void vertexAttrib3fv(int indx, Float32List values) => _webGL.vertexAttrib3fv(indx, values);

  @override void vertexAttrib4f(int indx, num x, num y, num z, num w) => _webGL.vertexAttrib4f(indx, x, y, z, w);

  @override void vertexAttrib4fv(int indx, Float32List values) => _webGL.vertexAttrib4fv(indx, values);

  @override void vertexAttribPointer(int indx, int size, int type, bool normalized, int stride, int offset) => _webGL.vertexAttribPointer(indx, size, type, normalized, stride, offset);

  @override void viewport(int x, int y, int width, int height) => _webGL.viewport(x, y, width, height);

  @override void texImage2DUntyped(int targetTexture, int levelOfDetail, int internalFormat, int format, int type, data)
    => _webGL.texImage2DUntyped(targetTexture, levelOfDetail, internalFormat, format, type, data);

  /**
   * Sets the currently bound texture to [data].
   */
  @override void texImage2DTyped(int targetTexture, int levelOfDetail, int internalFormat, int width, int height, int border, int format, int type, TypedData data)
    => _webGL.texImage2D(targetTexture, levelOfDetail, internalFormat, width, height, border, format, type, data);

  /**
   * Updates a sub-rectangle of the currently bound texture to [data].
   *
   * [data] can be either an [ImageElement], a
   * [CanvasElement], a [VideoElement], or an [ImageData] object.
   *
   * To use [texSubImage2d] with a TypedData object, use [texSubImage2dTyped].
   *
   */
  @override void texSubImage2DUntyped(int targetTexture, int levelOfDetail, int xOffset, int yOffset, int format, int type, data)
    => _webGL.texSubImage2D(targetTexture, levelOfDetail, xOffset, yOffset, format, type, data);

  /**
   * Updates a sub-rectangle of the currently bound texture to [data].
   */
  @override void texSubImage2DTyped(int targetTexture, int levelOfDetail, int xOffset, int yOffset, int width, int height, int format, int type, TypedData data)
    => _webGL.texSubImage2D(targetTexture, levelOfDetail, xOffset, yOffset, width, height, format, type, data);

}


class WebGLShader extends Shader{
  GLNative.Shader nativeShader;
}

class WebGLShaderPrecisionFormat extends ShaderPrecisionFormat{
  GLNative.ShaderPrecisionFormat nativeShaderPrecisionFormat;
}

class WebGLBuffer extends Buffer{
  GLNative.Buffer nativeBuffer;
}

class WebGLProgram extends Program {
  GLNative.Program nativeProgram;
}

class WebGLFramebuffer extends Framebuffer{
  GLNative.Framebuffer nativeFramebuffer;
}

class WebGLRenderbuffer extends Renderbuffer{
  GLNative.Renderbuffer nativeRenderbuffer;
}

class WebGLUniformLocation extends UniformLocation {
  GLNative.UniformLocation nativeUniformLocation;
}

class WebGLContextAttributes extends ContextAttributes {
  GLNative.ContextAttributes nativeContextAttributes;

  @override bool get alpha => nativeContextAttributes.alpha;
  @override void set alpha(bool value) { nativeContextAttributes.alpha = value; }

  @override bool get antialias => nativeContextAttributes.antialias;
  @override void set antialias(bool value) { nativeContextAttributes.antialias = value; }

  @override bool get depth => nativeContextAttributes.depth;
  @override void set depth(bool value) { nativeContextAttributes.depth = value; }

  @override bool get premultipliedAlpha => nativeContextAttributes.premultipliedAlpha;
  @override void set premultipliedAlpha(bool value) { nativeContextAttributes.premultipliedAlpha = value;}

  @override bool get preserveDrawingBuffer => nativeContextAttributes.preserveDrawingBuffer;
  @override void set preserveDrawingBuffer(bool value){ nativeContextAttributes.preserveDrawingBuffer = value; }

  @override bool get stencil => nativeContextAttributes.stencil;
  @override void set stencil(bool value) { nativeContextAttributes.stencil = value; }
}

class WebGLActiveInfo extends ActiveInfo {
  GLNative.ActiveInfo nativeActiveInfo;

  @override String get name => nativeActiveInfo.name;
  @override int get size => nativeActiveInfo.size;
  @override int get type => nativeActiveInfo.type;
}

class WebGLTexture extends GLTexture{
  GLNative.Texture nativeTexture;
}