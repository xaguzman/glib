library glib.tests;

import 'package:glib/glib_graphics.dart';
import 'package:glib/glib_math.dart';
import 'dart:html';
import 'dart:web_gl' as GL;
import 'dart:typed_data';

part 'tests/mesh.dart';
part 'tests/font_test.dart';
part 'tests/texture.dart';

TestSuite suite;

main(){
  var canvas = querySelector('#canvas');
  suite = new TestSuite(canvas);
  suite.currentTest = new FontTest(suite.gl)..init();
  window.animationFrame.then(update);
}

update(num delta){
  suite.render();
  window.animationFrame.then(update);
}

class TestSuite extends Object with Graphics{
  Test currentTest;
  
  TestSuite(CanvasElement canvas){
    initGraphics(canvas);
  }
  
  render(){
    gl.clearColor(0, 0, 0, 1);
    gl.clear(GL.COLOR_BUFFER_BIT);
    
    if (currentTest != null)
      currentTest.render();
  }
}

abstract class Test{
  GL.RenderingContext gl;
  static final SpriteBatch batch = new SpriteBatch();
  
  Test(this.gl);
  
  init();
  render();
  dispose();
}
