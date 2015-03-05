part of glib.graphics;

abstract class ImmediateModeRenderer extends Disposable{
  void begin (Matrix4 projModelView, int primitiveType);

  void flush ();
  
  void color (Color color);

  void colorValues(double r, double g, double b, double a);

  void texCoord (double u, double v);

  void normal (double x, double y, double z);

  void vertex (double x, double y, double z);

  void end ();

  int getNumVertices ();

  int getMaxVertices ();

  void dispose ();
}


class WebGLImmediateModeRenderer implements ImmediateModeRenderer{
  int primitiveType;
  int vertexIdx;
  int numSetTexCoords;
  final int maxVertices;
  int numVertices;

  Mesh mesh;
  ShaderProgram shader;
  bool ownsShader;
  
  final int numTexCoords;
  /* final */ int vertexSize;
  /* final */ int normalOffset;
  /* final */ int colorOffset;
  /* final */ int texCoordOffset;
  /* final */ Matrix4 projModelView = new Matrix4();
  /* final */ Float32List vertices;
  /* final */ List<String> shaderUniformNames;

//  WebGLImmediateModeRenderer (bool hasNormals, bool hasColors, int numTexCoords) {
//    this(5000, hasNormals, hasColors, numTexCoords, createDefaultShader(hasNormals, hasColors, numTexCoords));
//    ownsShader = true;
//  }
//
//  WebGLImmediateModeRenderer (int maxVertices, bool hasNormals, bool hasColors, int numTexCoords) {
//    this(maxVertices, hasNormals, hasColors, numTexCoords, createDefaultShader(hasNormals, hasColors, numTexCoords));
//    ownsShader = true;
//  }

  WebGLImmediateModeRenderer (bool hasNormals, bool hasColors, int this.numTexCoords, [int this.maxVertices, ShaderProgram this.shader]) {
    
    if (this.shader == null){
      shader = createDefaultShader(hasNormals, hasColors, numTexCoords);
      ownsShader = true;
    }
   
    VertexAttributes attribs = _buildVertexAttributes(hasNormals, hasColors, numTexCoords);
    mesh = new Mesh(false, maxVertices, 0, attribs);
    
    vertices = new List(maxVertices * (mesh.getVertexAttributes().vertexStride ~/ 4));
    vertexSize = mesh.getVertexAttributes().vertexStride ~/ 4;
    normalOffset = mesh.getVertexAttribute(Usage.Normal) != null ? mesh.getVertexAttribute(Usage.Normal).offset / 4 : 0;
    colorOffset = mesh.getVertexAttribute(Usage.ColorPacked) != null ? mesh.getVertexAttribute(Usage.ColorPacked).offset / 4
      : 0;
    texCoordOffset = mesh.getVertexAttribute(Usage.TextureCoordinates) != null ? mesh
      .getVertexAttribute(Usage.TextureCoordinates).offset / 4 : 0;
        
    shaderUniformNames = new List(numTexCoords);
    for (int i = 0; i < numTexCoords; i++) {
      shaderUniformNames[i] = "u_sampler$i";
    }
  }

  VertexAttributes _buildVertexAttributes (bool hasNormals, bool hasColor, int numTexCoords) {
    List<VertexAttribute> attribs = new List();
    attribs.add(new VertexAttribute(Usage.Position, 3, ShaderProgram.POSITION_ATTRIBUTE));
    if (hasNormals) attribs.add(new VertexAttribute(Usage.Normal, 3, ShaderProgram.NORMAL_ATTRIBUTE));
    if (hasColor) attribs.add(new VertexAttribute(Usage.ColorPacked, 4, ShaderProgram.COLOR_ATTRIBUTE));
    for (int i = 0; i < numTexCoords; i++) {
      attribs.add(new VertexAttribute(Usage.TextureCoordinates, 2, '${ShaderProgram.TEXCOORD_ATTRIBUTE}$i'));
    }
    List<VertexAttribute> array = new List(attribs.length);
    for (int i = 0; i < attribs.length; i++)
      array[i] = attribs[i];
    return new VertexAttributes(attribs);
  }

  void setShader (ShaderProgram shader) {
    if (ownsShader) this.shader.dispose();
    this.shader = shader;
    ownsShader = false;
  }

  void begin (Matrix4 projModelView, int primitiveType) {
    this.projModelView.setMatrix(projModelView);
    this.primitiveType = primitiveType;
  }

  void color (Color color) {
    vertices[vertexIdx + colorOffset] = color.toDouble();
  }

  void colorValues(double r, double g, double b, double a) {
    vertices[vertexIdx + colorOffset] = Color.toDoubleBits(r, g, b, a);
  }

  void texCoord (double u, double v) {
    final int idx = vertexIdx + texCoordOffset;
    vertices[idx + numSetTexCoords] = u;
    vertices[idx + numSetTexCoords + 1] = v;
    numSetTexCoords += 2;
  }

  void normal (double x, double y, double z) {
    final int idx = vertexIdx + normalOffset;
    vertices[idx] = x;
    vertices[idx + 1] = y;
    vertices[idx + 2] = z;
  }

  void vertex (double x, double y, double z) {
    final int idx = vertexIdx;
    vertices[idx] = x;
    vertices[idx + 1] = y;
    vertices[idx + 2] = z;

    numSetTexCoords = 0;
    vertexIdx += vertexSize;
    numVertices++;
  }

  void flush () {
    if (numVertices == 0) return;
    shader.begin();
    shader.setUniformMatrix4fv("u_projModelView", projModelView);
    for (int i = 0; i < numTexCoords; i++)
      shader.setUniformi(shaderUniformNames[i], i);
    mesh.setVertices(vertices, 0, vertexIdx);
    mesh.render(shader, primitiveType);
    shader.end();

    numSetTexCoords = 0;
    vertexIdx = 0;
    numVertices = 0;
  }

  void end () {
    flush();
  }

  int getNumVertices () {
    return numVertices;
  }

  @override
  int getMaxVertices () {
    return maxVertices;
  }

  void dispose () {
    if (ownsShader && shader != null) shader.dispose();
    mesh.dispose();
  }

  static String _createVertexShader (bool hasNormals, bool hasColors, int numTexCoords) {
    StringBuffer buffer = new StringBuffer();
    
    buffer
      ..write("attribute vec4 ${ShaderProgram.POSITION_ATTRIBUTE};\n")
      ..write(hasNormals ? "attribute vec3 ${ShaderProgram.NORMAL_ATTRIBUTE};\n" : "")
      ..write(hasColors ? "attribute vec4 ${ShaderProgram.COLOR_ATTRIBUTE};\n" : "");

    for (int i = 0; i < numTexCoords; i++) {
      buffer.write("attribute vec2 ${ShaderProgram.TEXCOORD_ATTRIBUTE}$i;\n");
    }

    buffer
      ..write("uniform mat4 u_projModelView;\n")
      ..write(hasColors ? "varying vec4 v_col;\n" : "");

    for (int i = 0; i < numTexCoords; i++) {
      buffer.write("varying vec2 v_tex$i;\n");
    }

    buffer
      ..write("void main() {\n   gl_Position = u_projModelView * ${ShaderProgram.POSITION_ATTRIBUTE};\n")
      ..write(hasColors ? "   v_col = ${ShaderProgram.COLOR_ATTRIBUTE};\n" : "");

    for (int i = 0; i < numTexCoords; i++) {
      buffer.write("   v_tex$i = ${ShaderProgram.TEXCOORD_ATTRIBUTE}$i;\n");
    }
    buffer
      ..write("   gl_PointSize = 1.0;\n")
      ..write("}\n");
    return buffer.toString();
  }

  static String _createFragmentShader (bool hasNormals, bool hasColors, int numTexCoords) {
    StringBuffer shader = new StringBuffer("#ifdef GL_ES\n precision mediump float;\n #endif\n");

    if (hasColors) 
      shader.write("varying vec4 v_col;\n");
    for (int i = 0; i < numTexCoords; i++) {
      shader
        ..write("varying vec2 v_tex$i;\n")
        ..write("uniform sampler2D u_sampler$i;\n");
    }

    shader
      ..write("void main() {\n   gl_FragColor = ")
      ..write(hasColors ? "v_col" : "vec4(1, 1, 1, 1)");

    if (numTexCoords > 0)
      shader.write(" * ");

    for (int i = 0; i < numTexCoords; i++) {
      
      shader.write(" texture2D(u_sampler$i, v_tex$i)");
      if (i < numTexCoords - 1)
        shader.write(" *");
    }

    shader.write(";\n}");
    return shader.toString();
  }

  /** Returns a new instance of the default shader used by SpriteBatch for WebGL when no shader is specified. */
  static ShaderProgram createDefaultShader (bool hasNormals, bool hasColors, int numTexCoords) {
    String vertexShader = _createVertexShader(hasNormals, hasColors, numTexCoords);
    String fragmentShader = _createFragmentShader(hasNormals, hasColors, numTexCoords);
    ShaderProgram program = new ShaderProgram(vertexShader, fragmentShader);
    return program;
  }
}
