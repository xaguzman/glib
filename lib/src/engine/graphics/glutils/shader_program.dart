part of glib.graphics;

class ShaderProgram implements Disposable {
  ///default name for position attributes
  static final String POSITION_ATTRIBUTE = "a_position";
  
  /// default name for normal attributes
  static final String NORMAL_ATTRIBUTE = "a_normal";
  
  /// default name for color attributes 
  static final String COLOR_ATTRIBUTE = "a_color";
  
  /// default name for texcoords attributes, append texture unit number 
  static final String TEXCOORD_ATTRIBUTE = "a_texCoord";
  
  /// default name for tangent attribute 
  static final String TANGENT_ATTRIBUTE = "a_tangent";
  
  /// default name for binormal attribute
  static final String BINORMAL_ATTRIBUTE = "a_binormal";

  /// flag indicating whether attributes & uniforms must be present at all times
  static bool pedantic = true;

//  /** the list of currently available shaders **/
//  static final Map<Application, Array<ShaderProgram>> _shaders = new Map<Application, Array<ShaderProgram>>();

  String _log = "";

  /// whether this program compiled successfully
  bool get isCompiled => _isCompiled;
  bool _isCompiled = false;

  // uniform lookup
  final Map<String, GL.ActiveInfo> _uniforms = new Map();
  final Map<String, GL.UniformLocation> _uniformLocations = new Map();
  List<String> _uniformNames;

  // attribute lookup
  final Map<String, GL.ActiveInfo> _attributes = new Map();
  final Map<String, int> _attributesLocation = new Map();
  List<String> _attributeNames;

  GL.Program _program;
  GL.Shader _vertexShader;
  GL.Shader _fragmentShader;

  /// vertex shader source
  final String vertexShaderSource;

  /// fragment shader source
  final String fragmentShaderSource;

  /// whether this shader was invalidated
  bool _invalidated = false;

  /// reference count
  int _refCount = 0;

  /// Constructs a new ShaderProgram and immediately compiles it.
  ShaderProgram(this.vertexShaderSource, this.fragmentShaderSource) {
    if (vertexShaderSource == null) throw new ArgumentError("vertex shader must not be null");
    if (fragmentShaderSource == null) throw new ArgumentError("fragment shader must not be null");

//    this.matrix = new Float32List(16);
    _compileShaders(vertexShaderSource, fragmentShaderSource);
    
    if (_isCompiled) {
      _fetchAttributes();
      _fetchUniforms();
//      addManagedShader(Gdx.app, this);
    }
  }

  /** Loads and compiles the shaders, creates a new program and links the shaders.
   * 
   * [vertexShader] the source code for the vertex shader
   * [fragmentShader] the source code for the fragment shader */
  void _compileShaders (String vertexShader, String fragmentShader) {
    _vertexShader = _loadShader(GL.VERTEX_SHADER, vertexShader);
    _fragmentShader = _loadShader(GL.FRAGMENT_SHADER, fragmentShader);

    if (_vertexShader == null || _fragmentShader == null) {
      _isCompiled = false;
      return;
    }

    _program = _linkProgram();
    if (_program == null) {
      _isCompiled = false;
      return;
    }

    _isCompiled = true;
  }

  GL.Shader _loadShader (int type, String source) {
    var shader = _graphics.gl.createShader(type);
    if (shader == null) return null;

    _graphics.gl.shaderSource(shader, source);
    _graphics.gl.compileShader(shader);
    
    bool compiled = _graphics.gl.getShaderParameter(shader, GL.COMPILE_STATUS);

    if (!compiled) {
      _log += _graphics.gl.getShaderInfoLog(shader);;
      return null;
    }

    return shader;
  }

  GL.Program _linkProgram () {
    var program = _graphics.gl.createProgram();
    if (program == null) return null;

    _graphics.gl.attachShader(program, _vertexShader);
    _graphics.gl.attachShader(program, _fragmentShader);
    _graphics.gl.linkProgram(program);

    bool linked = _graphics.gl.getProgramParameter(program, GL.LINK_STATUS);
    
    if (!linked) {
      _log = _graphics.gl.getProgramInfoLog(program);
      return null;
    }

    return program;
  }

  /// the log info for the shader compilation and program linking stage. The shader needs to be bound for this method to have an effect.
  String get log{
    if (_isCompiled)
      _log = _graphics.gl.getProgramInfoLog(_program);
    return _log;
  }

  int _fetchAttributeLocation (location_OR_name) {
    if (location_OR_name is int)
      return location_OR_name;
    
    if(location_OR_name is! String)
      throw new ArgumentError("Can't fetch the attribute location using ${location_OR_name.runtimeType}");
    
    int location;
    if (!_attributesLocation.containsKey(location_OR_name)) {
      location = _graphics.gl.getAttribLocation(_program, location_OR_name);
      if (location == -1 ) return -1;
      
      _attributesLocation[location_OR_name] = location;
    }else{
      location = _attributesLocation[location_OR_name];
    }
    return location;
  }

  GL.UniformLocation _fetchUniformLocation (location_OR_name, [bool pedantic = null]) {
    if (location_OR_name is GL.UniformLocation)
      return location_OR_name;
    
    if(location_OR_name is! String)
      throw new ArgumentError("Can't fetch the attribute location using ${location_OR_name.runtimeType}");
    
    if( pedantic == null)
      pedantic = ShaderProgram.pedantic;
    
    GL.UniformLocation location;
    
    if( _uniformLocations.containsKey(location_OR_name) )
      return _uniformLocations[location_OR_name];
    
    location = _graphics.gl.getUniformLocation(_program, location_OR_name);
    if (location == null && pedantic)
        throw new Exception("no uniform with name '" + location_OR_name + "' in shader");
         
    _uniformLocations[location_OR_name] = location;
    
    return location;
  }
    
  /**
   * A convenience method to set uniformi from the given arguments.
   * The GL call is determined based on the number of arguments passed. 
   * For example, `setUniformi("var", 0, 1)` maps to `gl.uniform2i`.
   * 
   * [location_OR_name] the name of the uniform, or the [GL.UniformLocation] itself
   * [x]  the x component 
   * [y]  the y component 
   * [z]  the z component 
   * [w]  the w component 
   */
  void setUniformi(location_OR_name, int x, [int y = null, int z = null, int w = null]) {
    _checkManaged();
    var location = _fetchUniformLocation(location_OR_name);
    if (location == null) 
      return;
    
    if (w != null)
      _graphics.gl.uniform4i(location, x, y, z, w);
    else if (z != null)
      _graphics.gl.uniform3i(location, x, y, z);
    else if ( y != null)
      _graphics.gl.uniform2i(location, x, y);
    else if( x != null)
      _graphics.gl.uniform1i(location, x);
    else
      throw new ArgumentError('Incorrect arguments for setUniformi');
  }
  
  /**
   * A convenience method to set uniformf from the given arguments.
   * The GL call is determined based on the number of arguments passed. 
   * For example, `setUniformf("var", 0, 1)` maps to `gl.uniform2f`.
   * 
   * [location_OR_name] the name of the uniform, or the [GL.UniformLocation] itself
   * [x]  the x component for ints
   * [y]  the y component for ivec2
   * [z]  the z component for ivec3
   * [w]  the w component for ivec4
   */
    void setUniformf(location_OR_name, num x, [num y = null, num z = null, num w = null]) {
      _checkManaged();
      var location = _fetchUniformLocation(location_OR_name);
      if (location == null) 
        return;
      
      if (w != null)
        _graphics.gl.uniform4f(location, x, y, z, w);
      else if (z != null)
        _graphics.gl.uniform3f(location, x, y, z);
      else if ( y != null)
        _graphics.gl.uniform2f(location, x, y);
      else if( x != null)
        _graphics.gl.uniform1f(location, x);
      else
        throw new ArgumentError('Incorrect arguments for setUniformf');
    }
    
  /**
   * A convenience method to set uniformfv from the given arguments.
   * The GL call is determined based on the length of [buffer] 
   * For example, `setUniformfv("var", buffer)` maps to `gl.uniform2fv`, if buffer.length == 2
   * 
   * [location_OR_name] the name of the uniform, or the [GL.UniformLocation] itself
   * [buffer]  the list containing all the values to set in the uniform
   */
  void setUniformfv(location_OR_name, Float32List buffer) {
    _checkManaged();
    var location = _fetchUniformLocation(location_OR_name);
    if (location == null) 
      return;
    
    switch(buffer.length){
      case 1: _graphics.gl.uniform1fv(location, buffer);
        break;
      case 2: _graphics.gl.uniform2fv(location, buffer);
        break;
      case 3: _graphics.gl.uniform3fv(location, buffer);
        break;
      case 4: _graphics.gl.uniform4fv(location, buffer);
        break;
      default:
        throw new ArgumentError('Incorrect arguments for setUniformfv');
    }
  }
  
  /**
   * A convenience method to set uniformfv from the given arguments.
   * The GL call is determined based length of [buffer] 
   * For example, `setUniformiv("var", buffer)` maps to `gl.uniform2iv`, if buffer.length == 2
   * 
   * [location_OR_name] the name of the uniform, or the [GL.UniformLocation] itself
   * [buffer] the list containing all the values to set in the uniform
   */
  void setUniformiv(location_OR_name, Int32List buffer) {
    _checkManaged();
    var location = _fetchUniformLocation(location_OR_name);
    if (location == null) 
      return;
    
    switch(buffer.length){
      case 1: _graphics.gl.uniform1iv(location, buffer);
        break;
      case 2: _graphics.gl.uniform2iv(location, buffer);
        break;
      case 3: _graphics.gl.uniform3iv(location, buffer);
        break;
      case 4: _graphics.gl.uniform4iv(location, buffer);
        break;
      default:
        throw new ArgumentError('Incorrect arguments for setUniformiv');
    }
  }

  /** Sets the uniform matrix with the given name. This needs to be called in between a [begin]/[end] block
   * 
   * [location_OR_name] the name of the uniform
   * [values_OR_Matrix4] the [Matrix4], or a [Float32List] with length of 16
   * [transpose] whether the matrix should be transposed */
  void setUniformMatrix4fv (location_OR_name, values_OR_Matrix4, [bool transpose = false]) {
    _checkManaged();
    var location = _fetchUniformLocation(location_OR_name);
    Float32List values = values_OR_Matrix4 is Matrix4 ? values_OR_Matrix4.val : values_OR_Matrix4;
    _graphics.gl.uniformMatrix4fv(location, transpose, values);
  }

  /** Sets the uniform matrix with the given [location_OR_name]. This needs to be called in between a [begin]/[end] block.
   * 
   * [location_OR_name] the name of the uniform, or the [GL.UniformLocation] itself
   * [values_OR_Matrix3] the [Matrix3], or a [Float32List] with length of 9
   * [transpose] whether the uniform matrix should be transposed, defaults to false */
  void setUniformMatrix3fv (location_OR_name, values_OR_Matrix3, [bool transpose = false]) {
    _checkManaged();
    var location = _fetchUniformLocation(location_OR_name);
    Float32List values = values_OR_Matrix3 is Matrix3 ? values_OR_Matrix3.val : values_OR_Matrix3;
    _graphics.gl.uniformMatrix3fv(location, transpose, values);
  }

  
  /** Sets the vertex attribute with the given name. This needs to be called in between a [begin]/[end] block
   * 
   * [location_OR_name] the attribute name, or the attribute location itself
   * [size] the number of components, must be >= 1 and <= 4
   * [type] the type, must be one of GL.BYTE, GL.UNSIGNED_BYTE, GL.SHORT, GL.UNSIGNED_SHORT, GL.FIXED, or GL.FLOAT
   * [normalize] whether fixed point data should be normalized. Will not work on the desktop
   * [stride] the stride in bytes between successive attributes
   * [offset] byte offset into the vertex buffer object bound to [GL.ARRAY_BUFFER]. */
  void setVertexAttribute (location_OR_name, int size, int type, bool normalize, int stride, int offset) {
    _checkManaged();
    int location = _fetchAttributeLocation(location_OR_name);
    if (location == -1) return;
    _graphics.gl.vertexAttribPointer(location, size, type, normalize, stride, offset);
  }

  /// Makes WebGL use this vertex and fragment shader pair. Make sure to call [end] when you are done with this shader 
  void begin () {
    _checkManaged();
    _graphics.gl.useProgram(_program);
  }

  /// Disables this shader. Must be called when one is done with the shader (during draw calls)
  void end () {
    _graphics.gl.useProgram(null);
  }

  /// Disposes all resources associated with this shader. Must be called when the shader is no longer used
  void dispose () {
    _graphics.gl.useProgram(null);
    _graphics.gl.deleteShader(_vertexShader);
    _graphics.gl.deleteShader(_fragmentShader);
    _graphics.gl.deleteProgram(_program);
    
//    _shaders.remove(Gdx.app);
  }

  /** 
   * Disables the vertex attribute with the given name
   * 
   * [location_OR_name] either the location (int) or name(String) of the vertex attribute you want to disable 
   */
  void disableVertexAttribute (location_OR_name) {
    _checkManaged();
    int location = _fetchAttributeLocation(location_OR_name);
    if (location == -1) return;
    _graphics.gl.disableVertexAttribArray(location);
  }

  /** 
   * Enables the vertex attribute with the given name
   * 
   * [location_OR_name] either the location (int) or name(String) of the vertex attribute you want to enable 
   */
  void enableVertexAttribute (location_OR_name) {
    _checkManaged();
    int location = _fetchAttributeLocation(location_OR_name);
    if (location == -1) return;
    _graphics.gl.enableVertexAttribArray(location);
  }

  void _checkManaged () {
    if (_invalidated) {
      _compileShaders(vertexShaderSource, fragmentShaderSource);
      _invalidated = false;
    }
  }

//  void _addManagedShader (Application app, ShaderProgram shaderProgram) {
//    Array<ShaderProgram> managedResources = shaders.get(app);
//    if (managedResources == null) managedResources = new Array<ShaderProgram>();
//    managedResources.add(shaderProgram);
//    shaders.put(app, managedResources);
//  }

//  /** Invalidates all shaders so the next time they are used new handles are generated
//   * @param app */
//  static void invalidateAllShaderPrograms () {
//    Array<ShaderProgram> shaderArray = shaders.get(app);
//    if (shaderArray == null) return;
//
//    for (int i = 0; i < shaderArray.size; i++) {
//      shaderArray[i].invalidated = true;
//      shaderArray[i]._checkManaged();
//    }
//  }

//  static void clearAllShaderPrograms (Application app) {
//    shaders.remove(app);
//  }

//  static String getManagedStatus () {
//    StringBuilder builder = new StringBuilder();
//    int i = 0;
//    builder.append("Managed shaders/app: { ");
//    for (Application app : shaders.keys()) {
//      builder.append(shaders.get(app).size);
//      builder.append(" ");
//    }
//    builder.append("}");
//    return builder.toString();
//  }

  /// Sets the given attribute
  /// [location_OR_name] either the location (int) or name(String) of the vertex attribute you want to set
  void setAttributef (location_OR_name, num value1, num value2, num value3, num value4) {
    _checkManaged();
    var location = _fetchAttributeLocation(location_OR_name);    
    _graphics.gl.vertexAttrib4f(location, value1, value2, value3, value4);
  }

  void _fetchUniforms () {
    int numUniforms = _graphics.gl.getProgramParameter(_program, GL.ACTIVE_UNIFORMS);
    _uniformNames = new List<String>(numUniforms);

    for (int i = 0; i < numUniforms; i++) {
      var info = _graphics.gl.getActiveUniform(_program, i);
      var location = _graphics.gl.getUniformLocation(_program, info.name);
      _uniforms[info.name] = info;
      _uniformNames[i] = info.name;
    }
  }

  void _fetchAttributes () {
    
    int numAttributes = _graphics.gl.getProgramParameter(_program,  GL.ACTIVE_ATTRIBUTES);   
    _attributeNames = new List<String>(numAttributes);

    for (int i = 0; i < numAttributes; i++) {
      GL.ActiveInfo info = _graphics.gl.getActiveAttrib(_program, i);
      int location = _graphics.gl.getAttribLocation(_program, info.name);
      _attributes[info.name] = info;
      _attributesLocation[info.name] = location; 
      _attributeNames[i] = info.name;
    }
  }

  /// returns whether the attribute is available in the shader
  bool hasAttribute (String name) => _attributes.containsKey(name);

  /// returns the type of the attribute, one of GL.FLOAT, GL.FLOAT_VEC2} etc
  int getAttributeType (String name) => _attributes[name].type;

  /// returns the location of the attribute 
  int getAttributeLocation (String name) => _attributesLocation[name];

  /// returns the size of the attribute
  int getAttributeSize (String name) => _attributes[name].size;

  /// returns whether the uniform is available in the shader
  bool hasUniform (String name) => _uniforms.containsKey(name);

  /// returns the type of the uniform, one of GL.FLOAT, GL.FLOAT_VEC2} etc
  int getUniformType (String name) => _uniforms[name].type;

  /// returns the location of the uniform
  GL.UniformLocation getUniformLocation (String name) => _uniformLocations[name];

  /// returns the size of the uniform
  int getUniformSize (String name) => _uniforms[name].size;

  /// all the attribute names
  List<String> get attributes => _attributeNames;

  /// all the uniform names
  List<String> get uniforms => _uniformNames;

}