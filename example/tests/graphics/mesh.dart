part of glib.tests;

class MeshTest extends Test{
  
  Mesh mesh;
  Texture texture;
  ShaderProgram shader;
  Matrix4 matrix = new Matrix4.identity();
  
  MeshTest():super("Mesh test");
  
  create(){
    
    var attrib = new VertexAttributes([new VertexAttribute.Position()]);
    
    mesh = new Mesh(true, 4, 6, attrib);
    
    
    var vert = [-0.5, -0.5, 0.0, 
                 0.5, -0.5, 1.0,  
                 0.5,  0.5, 0.6, 
                -0.5,  0.5, 0.25 ];
    mesh.setVertices(new Float32List.fromList(vert));
    mesh.setIndices(new Int16List.fromList([0, 1, 2, 2, 3, 0]));
    
    String vertexShader = """
      attribute vec4 a_position;
      uniform mat4 u_worldView;
      varying vec4 v_color;
      
      void main(){ 
        v_color = vec4(1, 0, 0, 1);
        gl_Position =  u_worldView * a_position;
      }""";
    
      String fragmentShader = """
        precision mediump float;
        varying vec4 v_color;

        void main(){
          gl_FragColor = v_color;
        }""";
    
    shader = new ShaderProgram(vertexShader, fragmentShader);
    if (shader.isCompiled == false) {
      print(shader.log);
    }
  }
  
  render(){
    super.render();
    Glib.gl.viewport(0, 0, 800, 480);
    Glib.gl.enable(GL.BLEND);
    Glib.gl.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
    shader.begin();
    shader.setUniformMatrix4fv("u_worldView", matrix);
    mesh.render(shader, GL.TRIANGLES);
    shader.end();
  }
  
  dispose(){
    mesh.dispose();
    shader.dispose();
  }
  
  String get name => 'Mesh test';
}