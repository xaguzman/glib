part of glib.graphics;

class Mesh implements Disposable {
  /// list of all meshes
//  static final Map<Application, Array<Mesh>> meshes = new HashMap<Application, Array<Mesh>>();

  final VertexBufferObject vertices;
  final IndexBufferObject indices;
  
  ///whether to bind the underlying [VertexBufferObject] automatically on a call to one of the render methods.
  bool autoBind = true;
  

  /** Creates a new Mesh with the given attributes.
   * 
   * isStatic whether this mesh is static or not. Allows for internal optimizations.
   * maxVertices the maximum number of vertices this mesh can hold
   * maxIndices the maximum number of indices this mesh can hold
   * attributes the [VertexAttributes]. Each vertex attribute defines one property of a vertex such as position, normal or texture coordinate */
  Mesh (bool isStatic, int numVertices, int numIndices, VertexAttributes attributes):
    vertices = new VertexBufferObject(isStatic, numVertices, attributes),
    indices = new IndexBufferObject(isStatic, numIndices)
    {
//      addManagedMesh(Gdx.app, this);
    }

  void setVertices (Float32List vertices, [int offset = 0, int count]) {
    if (count == null)
      count = vertices.length;
    this.vertices.setVertices(vertices, offset, count);
  }

  /// copy this mesh's vertices into the passed list 
  Float32List copyVertices (Float32List vertices, [int srcOffset = 0, int count = -1, int destOffset = 0]) {
    final int max = getNumVertices() * getVertexSize() ~/ 4;
    if (count == -1) {
      count = max - srcOffset;
      if (count > vertices.length - destOffset) 
        count = vertices.length - destOffset;
    }
    if (srcOffset < 0 || count <= 0 || (srcOffset + count) > max || destOffset < 0 || destOffset >= vertices.length)
      throw new RangeError('incorrect parameters in mesh.copyVertices()');
    if ((vertices.length - destOffset) < count)
      throw new ArgumentError("not enough room in vertices array, has ${vertices.length} floats, needs $count");
    
    vertices.setRange(destOffset, count, getVerticesBuffer());
    return vertices;
  }

  /// copy the passed list into this mesh's indices 
  void setIndices (Int16List indices, [int offset = 0, int count]) {
    if (count == null)
      count = indices.length;
    this.indices.setIndices(indices, offset, count);
  }

  /// copy this mesh's indices into the passed list  
  void copyIndices (Int16List indices, [int destOffset=0]) {
    if ((indices.length - destOffset) < getNumIndices())
      throw new ArgumentError("not enough room in indices array, has ${indices.length} floats, needs ${getNumIndices()}" );
    
    indices.setRange(destOffset, getNumIndices(), getIndicesBuffer());
  }

  /// the number of defined indices
  int getNumIndices () {
    return indices.getNumIndices();
  }

  /// the number of defined vertices
  int getNumVertices () {
    return vertices.getNumVertices();
  }

  /// the maximum number of vertices this mesh can hold */
  int getMaxVertices () {
    return vertices.getNumMaxVertices();
  }

  /// the maximum number of indices this mesh can hold
  int getMaxIndices () {
    return indices.getNumMaxIndices();
  }

  /// the size of a single vertex in bytes
  int getVertexSize () {
    return vertices.attributes.vertexStride;
  }

  /** Binds the underlying [VertexBufferObject] and [IndexBufferObject] if indices where given. Use this only if auto-bind is disabled.
   * 
   * shader the shader (does not bind the shader)
   * locations array containing the attribute locations. */
  void bind (final ShaderProgram shader, [final Int32List locations = null]) {
    vertices.bind(shader, locations);
    if (indices.getNumIndices() > 0) indices.bind();
  }

   /** Unbinds Binds the underlying [VertexBufferObject] and [IndexBufferObject] if indices where given. Use this only if auto-bind is disabled.
    * 
    * shader the shader (does not bind the shader)
    * locations array containing the attribute locations. */
  void unbind (ShaderProgram shader, [Int32List locations = null]) {
    vertices.unbind(shader, locations);
    if (indices.getNumIndices() > 0) indices.unbind();
  }

  /** <p>
   * Renders the mesh using the given primitive type. offset specifies the offset into either the vertex buffer or the index
   * buffer depending on whether indices are defined. count specifies the number of vertices or indices to use thus count /
   * #vertices per primitive primitives are rendered.
   * </p>
   * 
   * <p>
   * This method will automatically bind each vertex attribute as specified at construction time via {@link VertexAttributes} to
   * the respective shader attributes. The binding is based on the alias defined for each VertexAttribute.
   * </p>
   * 
   * <p>
   * This method must only be called after the {@link ShaderProgram#begin()} method has been called!
   * </p>
   * 
   * <p>
   * This method is intended for use with OpenGL ES 2.0 and will throw an IllegalStateException when OpenGL ES 1.x is used.
   * </p>
   * 
   * shader the shader to be used
   * primitiveType the primitive type
   * offset the offset into the vertex or index buffer
   * count number of vertices or indices to use
   * autoBind overrides the autoBind member of this Mesh */
  void render (ShaderProgram shader, int primitiveType,[ int offset = 0, int count = null, bool autoBind = null]) {
    if ( count == null)
      count = indices.getNumMaxIndices() > 0 ? getNumIndices() : getNumVertices();
    
    if (count == 0) return;
    
    if ( autoBind == null) 
      autoBind = this.autoBind;
    
    if (autoBind) 
      bind(shader);

    if (indices.getNumIndices() > 0)
      _gl.drawElements(primitiveType, count, GL.UNSIGNED_SHORT, offset * 2);
    else
      _gl.drawArrays(primitiveType, offset, count);
    
    if (autoBind) 
      unbind(shader);
  }

  /** Frees all resources associated with this Mesh */
  void dispose () {
//    if (meshes.get(Gdx.app) != null) meshes.get(Gdx.app).removeValue(this, true);
    vertices.dispose();
    indices.dispose();
  }

  /** Returns the first {@link VertexAttribute} having the given {@link Usage}.
   * 
   * usage the Usage.
   * @return the VertexAttribute or null if no attribute with that usage was found. */
  VertexAttribute getVertexAttribute (int usage) {
    VertexAttributes attributes = vertices.attributes;
    int len = attributes.size;
    return attributes._attributes.firstWhere((attrib) => attrib.usage == usage, orElse: () => null);
  }

  /** @return the vertex attributes of this Mesh */
  VertexAttributes getVertexAttributes () {
    return vertices.attributes;
  }

  /** @return the backing Float32List holding the vertices. Does not have to be a direct buffer on Android! */
  Float32List getVerticesBuffer () {
    return vertices.buffer;
  }

  /** @return the backing shortbuffer holding the indices. Does not have to be a direct buffer on Android! */
  Int16List getIndicesBuffer () {
    return indices.buffer;
  }

//  static void _addManagedMesh (Application app, Mesh mesh) {
//    List<Mesh> managedResources = meshes.get(app);
//    if (managedResources == null) managedResources = new Array<Mesh>();
//    managedResources.add(mesh);
//    meshes.put(app, managedResources);
//  }
//
//  /** Invalidates all meshes so the next time they are rendered new VBO handles are generated.
//   * app */
//  static void invalidateAllMeshes (Application app) {
//    Array<Mesh> meshesArray = meshes.get(app);
//    if (meshesArray == null) return;
//    for (int i = 0; i < meshesArray.size; i++) {
//      if (meshesArray.get(i).vertices instanceof VertexBufferObject) {
//        ((VertexBufferObject)meshesArray.get(i).vertices).invalidate();
//      }
//      meshesArray.get(i).indices.invalidate();
//    }
//  }
//
//  /** Will clear the managed mesh cache. I wouldn't use this if i was you :) */
//  static void clearAllMeshes (Application app) {
//    meshes.remove(app);
//  }

  static String getManagedStatus () {
//    StringBuilder builder = new StringBuilder();
//    int i = 0;
//    
//    
//    
//    builder.append("Managed meshes/app: { ");
////    for (Application app : meshes.keySet()) {
////      builder.append(meshes.get(app).size);
////      builder.append(" ");
////    }
//    builder.append("}");
//    return builder.toString();
    return '';
  }

}

//class VertexDataType {
//  final int val;
//  
//  const VertexDataType._internal(this.val);
//  
//  static const VertexDataType VertexArray = const VertexDataType._internal(1);
//  static const VertexDataType VertexBufferObject = const VertexDataType._internal(2);
//  static const VertexDataType VertexBufferObjectSubData = const VertexDataType._internal(3);
//}


//var Mesh = new Class({
//
//
//  /**
//   * A write-only property which sets both vertices and indices 
//   * flag to dirty or not. 
//   *
//   * @property dirty
//   * @type {Boolean}
//   * @writeOnly
//   */
//  dirty: {
//    set: function(val) {
//      this.verticesDirty = val;
//      this.indicesDirty = val;
//    }
//  },
//
//  /**
//   * Creates a new Mesh with the provided parameters.
//   *
//   * If numIndices is 0 or falsy, no index buffer will be used
//   * and indices will be an empty ArrayBuffer and a null indexBuffer.
//   * 
//   * If isStatic is true, then vertexUsage and indexUsage will
//   * be set to gl.STATIC_DRAW. Otherwise they will use gl.DYNAMIC_DRAW.
//   * You may want to adjust these after initialization for further control.
//   * 
//   *  {WebGLContext}  context the context for management
//   *  {Boolean} isStatic      a hint as to whether this geometry is static
//   *  {[type]}  numVerts      [description]
//   *  {[type]}  numIndices    [description]
//   *  {[type]}  vertexAttribs [description]
//   * @return {[type]}                [description]
//   */
//  initialize: function Mesh(context, isStatic, numVerts, numIndices, vertexAttribs) {
//    if (typeof context !== "object")
//      throw "GL context not specified to Mesh";
//    if (!numVerts)
//      throw "numVerts not specified, must be > 0";
//
//    this.context = context;
//    this.gl = context.gl;
//    
//    this.numVerts = null;
//    this.numIndices = null;
//    
//    this.vertices = null;
//    this.indices = null;
//    this.vertexBuffer = null;
//    this.indexBuffer = null;
//
//    this.verticesDirty = true;
//    this.indicesDirty = true;
//    this.indexUsage = null;
//    this.vertexUsage = null;
//
//    /** 
//     * @property
//     * @private
//     */
//    this._vertexAttribs = null;
//
//    /** 
//     * The stride for one vertex _in bytes_. 
//     * 
//     * @property {Number} vertexStride
//     */
//    this.vertexStride = null;
//
//    this.numVerts = numVerts;
//    this.numIndices = numIndices || 0;
//    this.vertexUsage = isStatic ? this.gl.STATIC_DRAW : this.gl.DYNAMIC_DRAW;
//    this.indexUsage  = isStatic ? this.gl.STATIC_DRAW : this.gl.DYNAMIC_DRAW;
//    this._vertexAttribs = vertexAttribs || [];
//    
//    this.indicesDirty = true;
//    this.verticesDirty = true;
//
//    //determine the vertex stride based on given attributes
//    var totalNumComponents = 0;
//    for (var i=0; i<this._vertexAttribs.length; i++)
//      totalNumComponents += this._vertexAttribs[i].offsetCount;
//    this.vertexStride = totalNumComponents * 4; // in bytes
//
//    this.vertices = new Float32Array(this.numVerts);
//    this.indices = new Uint16Array(this.numIndices);
//
//    //add this VBO to the managed cache
//    this.context.addManagedObject(this);
//
//    this.create();
//  },
//
//  //recreates the buffers on context loss
//  create: function() {
//    this.gl = this.context.gl;
//    var gl = this.gl;
//    this.vertexBuffer = gl.createBuffer();
//
//    //ignore index buffer if we haven't specified any
//    this.indexBuffer = this.numIndices > 0
//          ? gl.createBuffer()
//          : null;
//
//    this.dirty = true;
//  },
//
//  destroy: function() {
//    this.vertices = null;
//    this.indices = null;
//    if (this.vertexBuffer && this.gl)
//      this.gl.deleteBuffer(this.vertexBuffer);
//    if (this.indexBuffer && this.gl)
//      this.gl.deleteBuffer(this.indexBuffer);
//    this.vertexBuffer = null;
//    this.indexBuffer = null;
//    if (this.context)
//      this.context.removeManagedObject(this);
//    this.gl = null;
//    this.context = null;
//  },
//
//  _updateBuffers: function(ignoreBind, subDataLength) {
//    var gl = this.gl;
//
//    //bind our index data, if we have any
//    if (this.numIndices > 0) {
//      if (!ignoreBind)
//        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.indexBuffer);
//
//      //update the index data
//      if (this.indicesDirty) {
//        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, this.indexUsage);
//        this.indicesDirty = false;
//      }
//    }
//
//    //bind our vertex data
//    if (!ignoreBind)
//      gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexBuffer);
//
//    //update our vertex data
//    if (this.verticesDirty) {
//      if (subDataLength) {
//        // TODO: When decoupling VBO/IBO be sure to give better subData support..
//        var view = this.vertices.subarray(0, subDataLength);
//        gl.bufferSubData(gl.ARRAY_BUFFER, 0, view);
//      } else {
//        gl.bufferData(gl.ARRAY_BUFFER, this.vertices, this.vertexUsage);  
//      }
//
//      
//      this.verticesDirty = false;
//    }
//  },
//
//  draw: function(primitiveType, count, offset, subDataLength) {
//    if (count === 0)
//      return;
//
//    var gl = this.gl;
//    
//    offset = offset || 0;
//
//    //binds and updates our buffers. pass ignoreBind as true
//    //to avoid binding unnecessarily
//    this._updateBuffers(true, subDataLength);
//
//    if (this.numIndices > 0) { 
//      gl.drawElements(primitiveType, count, 
//            gl.UNSIGNED_SHORT, offset * 2); //* Uint16Array.BYTES_PER_ELEMENT
//    } else
//      gl.drawArrays(primitiveType, offset, count);
//  },
//
//  //binds this mesh's vertex attributes for the given shader
//  bind: function(shader) {
//    var gl = this.gl;
//
//    var offset = 0;
//    var stride = this.vertexStride;
//
//    //bind and update our vertex data before binding attributes
//    this._updateBuffers();
//
//    //for each attribtue
//    for (var i=0; i<this._vertexAttribs.length; i++) {
//      var a = this._vertexAttribs[i];
//
//      //location of the attribute
//      var loc = a.location === null 
//          ? shader.getAttributeLocation(a.name)
//          : a.location;
//
//      //TODO: We may want to skip unfound attribs
//      // if (loc!==0 && !loc)
//      //  console.warn("WARN:", a.name, "is not enabled");
//
//      //first, enable the vertex array
//      gl.enableVertexAttribArray(loc);
//
//      //then specify our vertex format
//      gl.vertexAttribPointer(loc, a.numComponents, a.type || gl.FLOAT, 
//                   a.normalize, stride, offset);
//
//      //and increase the offset...
//      offset += a.offsetCount * 4; //in bytes
//    }
//  },
//
//  unbind: function(shader) {
//    var gl = this.gl;
//
//    //for each attribtue
//    for (var i=0; i<this._vertexAttribs.length; i++) {
//      var a = this._vertexAttribs[i];
//
//      //location of the attribute
//      var loc = a.location === null 
//          ? shader.getAttributeLocation(a.name)
//          : a.location;
//
//      //first, enable the vertex array
//      gl.disableVertexAttribArray(loc);
//    }
//  }
//});
//
//Mesh.Attrib = new Class({
//
//  name: null,
//  numComponents: null,
//  location: null,
//  type: null,
//
//  /**
//   * Location is optional and for advanced users that
//   * want vertex arrays to match across shaders. Any non-numerical
//   * value will be converted to null, and ignored. If a numerical
//   * value is given, it will override the position of this attribute
//   * when given to a mesh.
//   * 
//   *  {[type]} name          [description]
//   *  {[type]} numComponents [description]
//   *  {[type]} location      [description]
//   * @return {[type]}               [description]
//   */
//  initialize: function(name, numComponents, location, type, normalize, offsetCount) {
//    this.name = name;
//    this.numComponents = numComponents;
//    this.location = typeof location === "number" ? location : null;
//    this.type = type;
//    this.normalize = Boolean(normalize);
//    this.offsetCount = typeof offsetCount === "number" ? offsetCount : this.numComponents;
//  }
//})