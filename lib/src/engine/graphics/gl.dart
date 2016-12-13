part of glib.graphics;

abstract class GL{
  static const int ACTIVE_ATTRIBUTES = 0x8B89;
  static const int ACTIVE_TEXTURE = 0x84E0;
  static const int ACTIVE_UNIFORMS = 0x8B86;
  static const int ALIASED_LINE_WIDTH_RANGE = 0x846E;
  static const int ALIASED_POINT_SIZE_RANGE = 0x846D;
  static const int ALPHA = 0x1906;
  static const int ALPHA_BITS = 0x0D55;
  static const int ALWAYS = 0x0207;
  static const int ARRAY_BUFFER = 0x8892;
  static const int ARRAY_BUFFER_BINDING = 0x8894;
  static const int ATTACHED_SHADERS = 0x8B85;
  static const int BACK = 0x0405;
  static const int BLEND = 0x0BE2;
  static const int BLEND_COLOR = 0x8005;
  static const int BLEND_DST_ALPHA = 0x80CA;
  static const int BLEND_DST_RGB = 0x80C8;
  static const int BLEND_EQUATION = 0x8009;
  static const int BLEND_EQUATION_ALPHA = 0x883D;
  static const int BLEND_EQUATION_RGB = 0x8009;
  static const int BLEND_SRC_ALPHA = 0x80CB;
  static const int BLEND_SRC_RGB = 0x80C9;
  static const int BLUE_BITS = 0x0D54;
  static const int BOOL = 0x8B56;
  static const int BOOL_VEC2 = 0x8B57;
  static const int BOOL_VEC3 = 0x8B58;
  static const int BOOL_VEC4 = 0x8B59;
  static const int BROWSER_DEFAULT_WEBGL = 0x9244;
  static const int BUFFER_SIZE = 0x8764;
  static const int BUFFER_USAGE = 0x8765;
  static const int BYTE = 0x1400;
  static const int CCW = 0x0901;
  static const int CLAMP_TO_EDGE = 0x812F;
  static const int COLOR_ATTACHMENT0 = 0x8CE0;
  static const int COLOR_BUFFER_BIT = 0x00004000;
  static const int COLOR_CLEAR_VALUE = 0x0C22;
  static const int COLOR_WRITEMASK = 0x0C23;
  static const int COMPILE_STATUS = 0x8B81;
  static const int COMPRESSED_TEXTURE_FORMATS = 0x86A3;
  static const int CONSTANT_ALPHA = 0x8003;
  static const int CONSTANT_COLOR = 0x8001;
  static const int CONTEXT_LOST_WEBGL = 0x9242;
  static const int CULL_FACE = 0x0B44;
  static const int CULL_FACE_MODE = 0x0B45;
  static const int CURRENT_PROGRAM = 0x8B8D;
  static const int CURRENT_VERTEX_ATTRIB = 0x8626;
  static const int CW = 0x0900;
  static const int DECR = 0x1E03;
  static const int DECR_WRAP = 0x8508;
  static const int DELETE_STATUS = 0x8B80;
  static const int DEPTH_ATTACHMENT = 0x8D00;
  static const int DEPTH_BITS = 0x0D56;
  static const int DEPTH_BUFFER_BIT = 0x00000100;
  static const int DEPTH_CLEAR_VALUE = 0x0B73;
  static const int DEPTH_COMPONENT = 0x1902;
  static const int DEPTH_COMPONENT16 = 0x81A5;
  static const int DEPTH_FUNC = 0x0B74;
  static const int DEPTH_RANGE = 0x0B70;
  static const int DEPTH_STENCIL = 0x84F9;
  static const int DEPTH_STENCIL_ATTACHMENT = 0x821A;
  static const int DEPTH_TEST = 0x0B71;
  static const int DEPTH_WRITEMASK = 0x0B72;
  static const int DITHER = 0x0BD0;
  static const int DONT_CARE = 0x1100;
  static const int DST_ALPHA = 0x0304;
  static const int DST_COLOR = 0x0306;
  static const int DYNAMIC_DRAW = 0x88E8;
  static const int ELEMENT_ARRAY_BUFFER = 0x8893;
  static const int ELEMENT_ARRAY_BUFFER_BINDING = 0x8895;
  static const int EQUAL = 0x0202;
  static const int FASTEST = 0x1101;
  static const int FLOAT = 0x1406;
  static const int FLOAT_MAT2 = 0x8B5A;
  static const int FLOAT_MAT3 = 0x8B5B;
  static const int FLOAT_MAT4 = 0x8B5C;
  static const int FLOAT_VEC2 = 0x8B50;
  static const int FLOAT_VEC3 = 0x8B51;
  static const int FLOAT_VEC4 = 0x8B52;
  static const int FRAGMENT_SHADER = 0x8B30;
  static const int FRAMEBUFFER = 0x8D40;
  static const int FRAMEBUFFER_ATTACHMENT_OBJECT_NAME = 0x8CD1;
  static const int FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE = 0x8CD0;
  static const int FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = 0x8CD3;
  static const int FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL = 0x8CD2;
  static const int FRAMEBUFFER_BINDING = 0x8CA6;
  static const int FRAMEBUFFER_COMPLETE = 0x8CD5;
  static const int FRAMEBUFFER_INCOMPLETE_ATTACHMENT = 0x8CD6;
  static const int FRAMEBUFFER_INCOMPLETE_DIMENSIONS = 0x8CD9;
  static const int FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = 0x8CD7;
  static const int FRAMEBUFFER_UNSUPPORTED = 0x8CDD;
  static const int FRONT = 0x0404;
  static const int FRONT_AND_BACK = 0x0408;
  static const int FRONT_FACE = 0x0B46;
  static const int FUNC_ADD = 0x8006;
  static const int FUNC_REVERSE_SUBTRACT = 0x800B;
  static const int FUNC_SUBTRACT = 0x800A;
  static const int GENERATE_MIPMAP_HINT = 0x8192;
  static const int GEQUAL = 0x0206;
  static const int GREATER = 0x0204;
  static const int GREEN_BITS = 0x0D53;
  static const int HIGH_FLOAT = 0x8DF2;
  static const int HIGH_INT = 0x8DF5;
  static const int IMPLEMENTATION_COLOR_READ_FORMAT = 0x8B9B;
  static const int IMPLEMENTATION_COLOR_READ_TYPE = 0x8B9A;
  static const int INCR = 0x1E02;
  static const int INCR_WRAP = 0x8507;
  static const int INT = 0x1404;
  static const int INT_VEC2 = 0x8B53;
  static const int INT_VEC3 = 0x8B54;
  static const int INT_VEC4 = 0x8B55;
  static const int INVALID_ENUM = 0x0500;
  static const int INVALID_FRAMEBUFFER_OPERATION = 0x0506;
  static const int INVALID_OPERATION = 0x0502;
  static const int INVALID_VALUE = 0x0501;
  static const int INVERT = 0x150A;
  static const int KEEP = 0x1E00;
  static const int LEQUAL = 0x0203;
  static const int LESS = 0x0201;
  static const int LINEAR = 0x2601;
  static const int LINEAR_MIPMAP_LINEAR = 0x2703;
  static const int LINEAR_MIPMAP_NEAREST = 0x2701;
  static const int LINES = 0x0001;
  static const int LINE_LOOP = 0x0002;
  static const int LINE_STRIP = 0x0003;
  static const int LINE_WIDTH = 0x0B21;
  static const int LINK_STATUS = 0x8B82;
  static const int LOW_FLOAT = 0x8DF0;
  static const int LOW_INT = 0x8DF3;
  static const int LUMINANCE = 0x1909;
  static const int LUMINANCE_ALPHA = 0x190A;
  static const int MAX_COMBINED_TEXTURE_IMAGE_UNITS = 0x8B4D;
  static const int MAX_CUBE_MAP_TEXTURE_SIZE = 0x851C;
  static const int MAX_FRAGMENT_UNIFORM_VECTORS = 0x8DFD;
  static const int MAX_RENDERBUFFER_SIZE = 0x84E8;
  static const int MAX_TEXTURE_IMAGE_UNITS = 0x8872;
  static const int MAX_TEXTURE_SIZE = 0x0D33;
  static const int MAX_VARYING_VECTORS = 0x8DFC;
  static const int MAX_VERTEX_ATTRIBS = 0x8869;
  static const int MAX_VERTEX_TEXTURE_IMAGE_UNITS = 0x8B4C;
  static const int MAX_VERTEX_UNIFORM_VECTORS = 0x8DFB;
  static const int MAX_VIEWPORT_DIMS = 0x0D3A;
  static const int MEDIUM_FLOAT = 0x8DF1;
  static const int MEDIUM_INT = 0x8DF4;
  static const int MIRRORED_REPEAT = 0x8370;
  static const int NEAREST = 0x2600;
  static const int NEAREST_MIPMAP_LINEAR = 0x2702;
  static const int NEAREST_MIPMAP_NEAREST = 0x2700;
  static const int NEVER = 0x0200;
  static const int NICEST = 0x1102;
  static const int NONE = 0;
  static const int NOTEQUAL = 0x0205;
  static const int NO_ERROR = 0;
  static const int ONE = 1;
  static const int ONE_MINUS_CONSTANT_ALPHA = 0x8004;
  static const int ONE_MINUS_CONSTANT_COLOR = 0x8002;
  static const int ONE_MINUS_DST_ALPHA = 0x0305;
  static const int ONE_MINUS_DST_COLOR = 0x0307;
  static const int ONE_MINUS_SRC_ALPHA = 0x0303;
  static const int ONE_MINUS_SRC_COLOR = 0x0301;
  static const int OUT_OF_MEMORY = 0x0505;
  static const int PACK_ALIGNMENT = 0x0D05;
  static const int POINTS = 0x0000;
  static const int POLYGON_OFFSET_FACTOR = 0x8038;
  static const int POLYGON_OFFSET_FILL = 0x8037;
  static const int POLYGON_OFFSET_UNITS = 0x2A00;
  static const int RED_BITS = 0x0D52;
  static const int RENDERBUFFER = 0x8D41;
  static const int RENDERBUFFER_ALPHA_SIZE = 0x8D53;
  static const int RENDERBUFFER_BINDING = 0x8CA7;
  static const int RENDERBUFFER_BLUE_SIZE = 0x8D52;
  static const int RENDERBUFFER_DEPTH_SIZE = 0x8D54;
  static const int RENDERBUFFER_GREEN_SIZE = 0x8D51;
  static const int RENDERBUFFER_HEIGHT = 0x8D43;
  static const int RENDERBUFFER_INTERNAL_FORMAT = 0x8D44;
  static const int RENDERBUFFER_RED_SIZE = 0x8D50;
  static const int RENDERBUFFER_STENCIL_SIZE = 0x8D55;
  static const int RENDERBUFFER_WIDTH = 0x8D42;
  static const int RENDERER = 0x1F01;
  static const int REPEAT = 0x2901;
  static const int REPLACE = 0x1E01;
  static const int RGB = 0x1907;
  static const int RGB565 = 0x8D62;
  static const int RGB5_A1 = 0x8057;
  static const int RGBA = 0x1908;
  static const int RGBA4 = 0x8056;
  static const int SAMPLER_2D = 0x8B5E;
  static const int SAMPLER_CUBE = 0x8B60;
  static const int SAMPLES = 0x80A9;
  static const int SAMPLE_ALPHA_TO_COVERAGE = 0x809E;
  static const int SAMPLE_BUFFERS = 0x80A8;
  static const int SAMPLE_COVERAGE = 0x80A0;
  static const int SAMPLE_COVERAGE_INVERT = 0x80AB;
  static const int SAMPLE_COVERAGE_VALUE = 0x80AA;
  static const int SCISSOR_BOX = 0x0C10;
  static const int SCISSOR_TEST = 0x0C11;
  static const int SHADER_TYPE = 0x8B4F;
  static const int SHADING_LANGUAGE_VERSION = 0x8B8C;
  static const int SHORT = 0x1402;
  static const int SRC_ALPHA = 0x0302;
  static const int SRC_ALPHA_SATURATE = 0x0308;
  static const int SRC_COLOR = 0x0300;
  static const int STATIC_DRAW = 0x88E4;
  static const int STENCIL_ATTACHMENT = 0x8D20;
  static const int STENCIL_BACK_FAIL = 0x8801;
  static const int STENCIL_BACK_FUNC = 0x8800;
  static const int STENCIL_BACK_PASS_DEPTH_FAIL = 0x8802;
  static const int STENCIL_BACK_PASS_DEPTH_PASS = 0x8803;
  static const int STENCIL_BACK_REF = 0x8CA3;
  static const int STENCIL_BACK_VALUE_MASK = 0x8CA4;
  static const int STENCIL_BACK_WRITEMASK = 0x8CA5;
  static const int STENCIL_BITS = 0x0D57;
  static const int STENCIL_BUFFER_BIT = 0x00000400;
  static const int STENCIL_CLEAR_VALUE = 0x0B91;
  static const int STENCIL_FAIL = 0x0B94;
  static const int STENCIL_FUNC = 0x0B92;
  static const int STENCIL_INDEX = 0x1901;
  static const int STENCIL_INDEX8 = 0x8D48;
  static const int STENCIL_PASS_DEPTH_FAIL = 0x0B95;
  static const int STENCIL_PASS_DEPTH_PASS = 0x0B96;
  static const int STENCIL_REF = 0x0B97;
  static const int STENCIL_TEST = 0x0B90;
  static const int STENCIL_VALUE_MASK = 0x0B93;
  static const int STENCIL_WRITEMASK = 0x0B98;
  static const int STREAM_DRAW = 0x88E0;
  static const int SUBPIXEL_BITS = 0x0D50;
  static const int TEXTURE = 0x1702;
  static const int TEXTURE0 = 0x84C0;
  static const int TEXTURE1 = 0x84C1;
  static const int TEXTURE10 = 0x84CA;
  static const int TEXTURE11 = 0x84CB;
  static const int TEXTURE12 = 0x84CC;
  static const int TEXTURE13 = 0x84CD;
  static const int TEXTURE14 = 0x84CE;
  static const int TEXTURE15 = 0x84CF;
  static const int TEXTURE16 = 0x84D0;
  static const int TEXTURE17 = 0x84D1;
  static const int TEXTURE18 = 0x84D2;
  static const int TEXTURE19 = 0x84D3;
  static const int TEXTURE2 = 0x84C2;
  static const int TEXTURE20 = 0x84D4;
  static const int TEXTURE21 = 0x84D5;
  static const int TEXTURE22 = 0x84D6;
  static const int TEXTURE23 = 0x84D7;
  static const int TEXTURE24 = 0x84D8;
  static const int TEXTURE25 = 0x84D9;
  static const int TEXTURE26 = 0x84DA;
  static const int TEXTURE27 = 0x84DB;
  static const int TEXTURE28 = 0x84DC;
  static const int TEXTURE29 = 0x84DD;
  static const int TEXTURE3 = 0x84C3;
  static const int TEXTURE30 = 0x84DE;
  static const int TEXTURE31 = 0x84DF;
  static const int TEXTURE4 = 0x84C4;
  static const int TEXTURE5 = 0x84C5;
  static const int TEXTURE6 = 0x84C6;
  static const int TEXTURE7 = 0x84C7;
  static const int TEXTURE8 = 0x84C8;
  static const int TEXTURE9 = 0x84C9;
  static const int TEXTURE_2D = 0x0DE1;
  static const int TEXTURE_BINDING_2D = 0x8069;
  static const int TEXTURE_BINDING_CUBE_MAP = 0x8514;
  static const int TEXTURE_CUBE_MAP = 0x8513;
  static const int TEXTURE_CUBE_MAP_NEGATIVE_X = 0x8516;
  static const int TEXTURE_CUBE_MAP_NEGATIVE_Y = 0x8518;
  static const int TEXTURE_CUBE_MAP_NEGATIVE_Z = 0x851A;
  static const int TEXTURE_CUBE_MAP_POSITIVE_X = 0x8515;
  static const int TEXTURE_CUBE_MAP_POSITIVE_Y = 0x8517;
  static const int TEXTURE_CUBE_MAP_POSITIVE_Z = 0x8519;
  static const int TEXTURE_MAG_FILTER = 0x2800;
  static const int TEXTURE_MIN_FILTER = 0x2801;
  static const int TEXTURE_WRAP_S = 0x2802;
  static const int TEXTURE_WRAP_T = 0x2803;
  static const int TRIANGLES = 0x0004;
  static const int TRIANGLE_FAN = 0x0006;
  static const int TRIANGLE_STRIP = 0x0005;
  static const int UNPACK_ALIGNMENT = 0x0CF5;
  static const int UNPACK_COLORSPACE_CONVERSION_WEBGL = 0x9243;
  static const int UNPACK_FLIP_Y_WEBGL = 0x9240;
  static const int UNPACK_PREMULTIPLY_ALPHA_WEBGL = 0x9241;
  static const int UNSIGNED_BYTE = 0x1401;
  static const int UNSIGNED_INT = 0x1405;
  static const int UNSIGNED_SHORT = 0x1403;
  static const int UNSIGNED_SHORT_4_4_4_4 = 0x8033;
  static const int UNSIGNED_SHORT_5_5_5_1 = 0x8034;
  static const int UNSIGNED_SHORT_5_6_5 = 0x8363;
  static const int VALIDATE_STATUS = 0x8B83;
  static const int VENDOR = 0x1F00;
  static const int VERSION = 0x1F02;
  static const int VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F;
  static const int VERTEX_ATTRIB_ARRAY_ENABLED = 0x8622;
  static const int VERTEX_ATTRIB_ARRAY_NORMALIZED = 0x886A;
  static const int VERTEX_ATTRIB_ARRAY_POINTER = 0x8645;
  static const int VERTEX_ATTRIB_ARRAY_SIZE = 0x8623;
  static const int VERTEX_ATTRIB_ARRAY_STRIDE = 0x8624;
  static const int VERTEX_ATTRIB_ARRAY_TYPE = 0x8625;
  static const int VERTEX_SHADER = 0x8B31;
  static const int VIEWPORT = 0x0BA2;
  static const int ZERO = 0;

  int get drawingBufferHeight;
  int get drawingBufferWidth;

  void activeTexture(int texture);
  void attachShader(Program program, Shader shader);
  void bindAttribLocation(Program program, int index, String name);
  void bindBuffer(int target, Buffer buffer);
  void bindFramebuffer(int target, Framebuffer framebuffer);
  void bindRenderbuffer(int target, Renderbuffer renderbuffer);
  void bindTexture(int target, GLTexture texture);
  void blendColor(num red, num green, num blue, num alpha);
  void blendEquation(int mode);
  void blendEquationSeparate(int modeRGB, int modeAlpha);
  void blendFunc(int sfactor, int dfactor);
  void blendFuncSeparate(int srcRGB, int dstRGB, int srcAlpha, int dstAlpha);
  void bufferByteData(int target, ByteBuffer data, int usage);
  void bufferDataTyped(int target, TypedData data, int usage);
  void bufferSubByteData(int target, int offset, ByteBuffer data);
  void bufferSubData(int target, int offset, data);
  void bufferSubDataTyped(int target, int offset, TypedData data);
  int checkFramebufferStatus(int target);
  void clear(int mask);
  void clearColor(num red, num green, num blue, num alpha);
  void clearDepth(num depth);
  void clearStencil(int s);
  void colorMask(bool red, bool green, bool blue, bool alpha);
  void compileShader(Shader shader);
  void compressedTexImage2D(int target, int level, int internalformat, int width, int height, int border, TypedData data);
  void compressedTexSubImage2D(int target, int level, int xoffset, int yoffset, int width, int height, int format, TypedData data);
  void copyTexImage2D(int target, int level, int internalformat, int x, int y, int width, int height, int border);
  void copyTexSubImage2D(int target, int level, int xoffset, int yoffset, int x, int y, int width, int height);
  Buffer createBuffer();
  Framebuffer createFramebuffer();
  Program createProgram();
  Renderbuffer createRenderbuffer();
  Shader createShader(int type);
  GLTexture createTexture();
  void cullFace(int mode);
  void deleteBuffer(Buffer buffer);
  void deleteFramebuffer(Framebuffer framebuffer);
  void deleteProgram(Program program);
  void deleteRenderbuffer(Renderbuffer renderbuffer);
  void deleteShader(Shader shader);
  void deleteTexture(GLTexture texture);
  void depthFunc(int func);
  void depthMask(bool flag);
  void depthRange(num zNear, num zFar);
  void detachShader(Program program, Shader shader);
  void disable(int cap);
  void disableVertexAttribArray(int index);
  void drawArrays(int mode, int first, int count);
  void drawElements(int mode, int count, int type, int offset);
  void enable(int cap);
  void enableVertexAttribArray(int index);
  void finish();
  void flush();
  void framebufferRenderbuffer(int target, int attachment, int renderbuffertarget, Renderbuffer renderbuffer);
  void framebufferTexture2D(int target, int attachment, int textarget, GLTexture texture, int level);
  void frontFace(int mode);
  void generateMipmap(int target);
  ActiveInfo getActiveAttrib(Program program, int index);
  ActiveInfo getActiveUniform(Program program, int index);
  List<Shader> getAttachedShaders(Program program);
  int getAttribLocation(Program program, String name);
  Object getBufferParameter(int target, int pname);
  ContextAttributes getContextAttributes();
  int getError();
  Object getExtension(String name);
  Object getFramebufferAttachmentParameter(int target, int attachment, int pname);
  Object getParameter(int pname);
  String getProgramInfoLog(Program program);
  Object getProgramParameter(Program program, int pname);
  Object getRenderbufferParameter(int target, int pname);
  String getShaderInfoLog(Shader shader);
  Object getShaderParameter(Shader shader, int pname);
  ShaderPrecisionFormat getShaderPrecisionFormat(int shadertype, int precisiontype);
  String getShaderSource(Shader shader);
  List<String> getSupportedExtensions();
  Object getTexParameter(int target, int pname);
  Object getUniform(Program program, UniformLocation location);
  UniformLocation getUniformLocation(Program program, String name);
  Object getVertexAttrib(int index, int pname);
  int getVertexAttribOffset(int index, int pname);
  void hint(int target, int mode);
  bool isBuffer(Buffer buffer);
  bool isContextLost();
  bool isEnabled(int cap);
  bool isFramebuffer(Framebuffer framebuffer);
  bool isProgram(Program program);
  bool isRenderbuffer(Renderbuffer renderbuffer);
  bool isShader(Shader shader);
  bool isTexture(GLTexture texture);
  void lineWidth(num width);
  void linkProgram(Program program);
  void pixelStorei(int pname, int param);
  void polygonOffset(num factor, num units);
  void readPixels(int x, int y, int width, int height, int format, int type, TypedData pixels);
  void renderbufferStorage(int target, int internalformat, int width, int height);
  void sampleCoverage(num value, bool invert);
  void scissor(int x, int y, int width, int height);
  void shaderSource(Shader shader, String string);
  void stencilFunc(int func, int ref, int mask);
  void stencilFuncSeparate(int face, int func, int ref, int mask);
  void stencilMask(int mask);
  void stencilMaskSeparate(int face, int mask);
  void stencilOp(int fail, int zfail, int zpass);
  void stencilOpSeparate(int face, int fail, int zfail, int zpass);
  void texImage2D(int target, int level, int internalformat, int format_OR_width, int height_OR_type, border_OR_canvas_OR_image_OR_pixels_OR_video, [int format, int type, TypedData pixels]);
  void texParameterf(int target, int pname, num param);
  void texParameteri(int target, int pname, int param);
  void texSubImage2D(int target, int level, int xoffset, int yoffset, int format_OR_width, int height_OR_type, canvas_OR_format_OR_image_OR_pixels_OR_video, [int type, TypedData pixels]);
  void uniform1f(UniformLocation location, num x);
  void uniform1fv(UniformLocation location, Float32List v);
  void uniform1i(UniformLocation location, int x);
  void uniform1iv(UniformLocation location, Int32List v);
  void uniform2f(UniformLocation location, num x, num y);
  void uniform2fv(UniformLocation location, Float32List v);
  void uniform2i(UniformLocation location, int x, int y);
  void uniform2iv(UniformLocation location, Int32List v);
  void uniform3f(UniformLocation location, num x, num y, num z);
  void uniform3fv(UniformLocation location, Float32List v);
  void uniform3i(UniformLocation location, int x, int y, int z);
  void uniform3iv(UniformLocation location, Int32List v);
  void uniform4f(UniformLocation location, num x, num y, num z, num w);
  void uniform4fv(UniformLocation location, Float32List v);
  void uniform4i(UniformLocation location, int x, int y, int z, int w);
  void uniform4iv(UniformLocation location, Int32List v);
  void uniformMatrix2fv(UniformLocation location, bool transpose, Float32List array);
  void uniformMatrix3fv(UniformLocation location, bool transpose, Float32List array);
  void uniformMatrix4fv(UniformLocation location, bool transpose, Float32List array);
  void useProgram(Program program);
  void validateProgram(Program program);
  void vertexAttrib1f(int indx, num x);
  void vertexAttrib1fv(int indx, Float32List values);
  void vertexAttrib2f(int indx, num x, num y);
  void vertexAttrib2fv(int indx, Float32List values);
  void vertexAttrib3f(int indx, num x, num y, num z);
  void vertexAttrib3fv(int indx, Float32List values);
  void vertexAttrib4f(int indx, num x, num y, num z, num w);
  void vertexAttrib4fv(int indx, Float32List values);
  void vertexAttribPointer(int indx, int size, int type, bool normalized, int stride, int offset);
  void viewport(int x, int y, int width, int height);


  /**
   * Sets the currently bound texture to [data].
   *
   * [data] can be either an [ImageElement], a
   * [CanvasElement], a [VideoElement], or an [ImageData] object.
   *
   * To use [texImage2d] with a TypedData object, use [texImage2dTyped].
   *
   */
  void texImage2DUntyped(int targetTexture, int levelOfDetail, int internalFormat, int format, int type, data);

  /**
   * Sets the currently bound texture to [data].
   */
  void texImage2DTyped(int targetTexture, int levelOfDetail, int internalFormat,
                       int width, int height, int border, int format, int type, TypedData data) {
    texImage2D(targetTexture, levelOfDetail, internalFormat,
    width, height, border, format, type, data);
  }

  /**
   * Updates a sub-rectangle of the currently bound texture to [data].
   *
   * [data] can be either an [ImageElement], a
   * [CanvasElement], a [VideoElement], or an [ImageData] object.
   *
   * To use [texSubImage2d] with a TypedData object, use [texSubImage2dTyped].
   *
   */
  void texSubImage2DUntyped(int targetTexture, int levelOfDetail,
                            int xOffset, int yOffset, int format, int type, data) {
    texSubImage2D(targetTexture, levelOfDetail, xOffset, yOffset,
    format, type, data);
  }

  /**
   * Updates a sub-rectangle of the currently bound texture to [data].
   */
  void texSubImage2DTyped(int targetTexture, int levelOfDetail,
                          int xOffset, int yOffset, int width, int height, int format,
                          int type, TypedData data) {
    texSubImage2D(targetTexture, levelOfDetail, xOffset, yOffset,
    width, height, format, type, data);
  }
}

abstract class Shader{ }

abstract class ShaderPrecisionFormat {}

abstract class Buffer{ }

abstract class Program{ }

abstract class Framebuffer{ }

abstract class Renderbuffer{ }

abstract class UniformLocation{ }

abstract class ContextAttributes{

  bool alpha, antialias, depth, premultipliedAlpha, preserveDrawingBuffer, stencil;

}

abstract class ActiveInfo{
  String get name;
  int get size;
  int get type;
}

abstract class GLTexture {}