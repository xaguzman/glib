part of glib.graphics;

class VertexBufferObject implements Disposable{
  final VertexAttributes _attributes;
  Float32List _buffer;
  GL.Buffer glBuffer;
  final bool isStatic;
  int usage;
  bool isDirty = false;
  bool isBound = false;
  int _limit = 0;
  
  /** Constructs a new interleaved VertexBufferObject.
   * 
   * [isStatic] whether the vertex data is static.
   * [numVertices] the maximum number of vertices
   * [_attributes] the [VertexAttributes] */
  VertexBufferObject (this.isStatic, int numVertices, this._attributes)
  {
    int numComponents = numVertices * (_attributes.vertexStride ~/ 4);
    _buffer = new Float32List(numComponents);
    glBuffer = _graphics.gl.createBuffer();
    usage = isStatic ? GL.STATIC_DRAW : GL.DYNAMIC_DRAW;
  }
  
  VertexAttributes get attributes => _attributes;

  
  int getNumVertices () {
    return _limit ~/ attributes.vertexStride;
  }

  
  int getNumMaxVertices () {
    return buffer.length ~/ attributes.vertexStride;
  }

  
  Float32List get buffer {
    isDirty = true;
    return _buffer;
  }

  void _bufferChanged () {
    if (!isBound)
      return;
    
    _graphics.gl.bufferData(GL.ARRAY_BUFFER, _buffer, usage);
    isDirty = false;
  }

   void setVertices (Float32List vertices, int offset, int count) {
    isDirty = true;
    _buffer.setRange(offset, offset + count, vertices);
    if(offset + count > _limit)
      _limit = offset + count ;
    _bufferChanged();
    }

  void bind (ShaderProgram shader, [List<int> locations = null]) {
    
    _graphics.gl.bindBuffer(GL.ARRAY_BUFFER, glBuffer); 
    if (isDirty) {
      _graphics.gl.bufferData(GL.ARRAY_BUFFER, _buffer, usage);
      isDirty = false;
    }

    final int numAttributes = attributes.size;
    if (locations == null) {
      for (int i = 0; i < numAttributes; i++) {
        final VertexAttribute attribute = attributes.get(i);
        final int location = shader.getAttributeLocation(attribute.alias);
        if (location == null) continue;
        shader.enableVertexAttribute(location);

        shader.setVertexAttribute(location, attribute.numComponents, attribute.type, attribute.isNormalized, attributes.vertexStride,
            attribute._offset);
      }
      
    } else {
      for (int i = 0; i < numAttributes; i++) {
        final VertexAttribute attribute = attributes.get(i);
        final int location = locations[i];
        if (location < 0) continue;
        shader.enableVertexAttribute(location);

        shader.setVertexAttribute(location, attribute.numComponents, attribute.type, attribute.isNormalized, attributes.vertexStride,
          attribute._offset);
      }
    }
    isBound = true;
  }
  
  void unbind (final ShaderProgram shader, [final List<int> locations = null]) {
    final int numAttributes = attributes.size;
    if (locations == null) {
      for (int i = 0; i < numAttributes; i++) {
        shader.disableVertexAttribute(attributes.get(i).alias);
      }
    } else {
      for (int i = 0; i < numAttributes; i++) {
        final int location = locations[i];
        if (location >= 0) shader.disableVertexAttribute(location);
      }
    }
    _graphics.gl.bindBuffer(GL.ARRAY_BUFFER, null);
    isBound = false;
  }

//  /** Invalidates the VertexBufferObject so a new OpenGL buffer handle is created. Use this in case of a context loss. */
//  void invalidate () {
//    bufferHandle = createBufferObject();
//    isDirty = true;
//  }

  /// Disposes of all resources this VertexBufferObject uses
  void dispose () {   
    _graphics.gl.bindBuffer(GL.ARRAY_BUFFER, null);
    _graphics.gl.deleteBuffer(glBuffer);
    glBuffer = null;
//    _buffer.clear();
  }
}