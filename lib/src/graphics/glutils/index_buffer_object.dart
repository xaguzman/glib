part of glib.graphics;

class IndexBufferObject implements Disposable{
  Int16List buffer;
  GL.Buffer glBuffer;
  bool isDirty = true;
  bool isBound = false;
  final int usage;
  
  int _limit = 0;

  /** Creates a new IndexBufferObject.
   * 
   * isStatic whether the index buffer is static
   * maxIndices the maximum number of indices this buffer can hold */
  IndexBufferObject (bool isStatic, int numIndices):
    usage = isStatic ? GL.STATIC_DRAW : GL.DYNAMIC_DRAW
  {
    buffer = new Int16List(numIndices);
    _createBufferObject();
  }

  void _createBufferObject () {
    glBuffer = _gl.createBuffer();
  }

  /// the number of indices currently stored in this buffer
  int getNumIndices () {
    return _limit ;
  }

  /// the maximum number of indices this IndexBufferObject can store.
  int getNumMaxIndices () {
    return buffer.length;
  }

  /** 
   * Sets the indices of this IndexBufferObject, discarding the old indices. The count must equal the number of indices to be
   * copied to this IndexBufferObject.
   * 
   * This can be called in between calls to {@link #bind()} and {@link #unbind()}. The index data will be updated instantly.
   * 
   * indices the vertex data
   * offset the offset to start copying the data from
   * count the number of shorts to copy */
  void setIndices (Int16List indices, int offset, int count) {
    isDirty = true;
    buffer.setRange(offset, offset + count - 1, indices);
    if(offset + count > _limit)
          _limit = offset + count ;

    if (isBound) {
      _gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, buffer, usage);
      isDirty = false;
    }
  }

  Int16List getBuffer () {
    isDirty = true;
    return buffer;
  }

  /// Binds this IndexBufferObject for rendering with glDrawElements
  void bind () {
    if (glBuffer == null) throw new StateError("No buffer allocated!");

    _gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, glBuffer);
    if (isDirty) {
      _gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, buffer, usage);
      isDirty = false;
    }
    isBound = true;
  }

  /// Unbinds this IndexBufferObject
  void unbind () {
    _gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
    isBound = false;
  }

  /** Invalidates the IndexBufferObject so a new OpenGL buffer handle is created. Use this in case of a context loss. */
  void invalidate () {
    _createBufferObject();
    isDirty = true;
  }

  /// Disposes this IndexBufferObject and all its associated OpenGL resources.
  void dispose () {
    _gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
    _gl.deleteBuffer(glBuffer);
    glBuffer = null;
  }
}