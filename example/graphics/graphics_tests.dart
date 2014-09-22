library glib.tests;

import 'package:glib/glib_graphics.dart';
import 'dart:html';
import 'dart:web_gl' as GL;
import 'dart:typed_data';

part 'tests/mesh.dart';
part 'tests/font_test.dart';
part 'tests/texture.dart';
part 'tests/orthocam_test.dart';

TestSuite suite;
Map<String, Test> tests;

main(){
  var canvas = querySelector('#canvas');
  SelectElement select = querySelector('#tests');
  suite = new TestSuite(canvas);
  
  tests = new Map.fromIterable( [
    new MeshTest(suite.gl),
    new TextureTest(suite.gl), 
    new FontTest(suite.gl),
    new OrthographicCameraTest(suite.gl)
  ], key: (test) => test.name, value: (test) => test);

  select.children.addAll(tests.keys.map( (key) => new OptionElement(data: key, value: key) ));
  select.options.first.selected= true;
  
  select.onChange.listen((Event e) {
    var nextTest = tests[ select.children[select.selectedIndex].text ];
    if (suite.currentTest != null)
      suite.currentTest.dispose();
    suite.currentTest= nextTest..init(); 
  });
  
  suite.currentTest = tests.values.first..init();
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
  String get name;
  static final SpriteBatch batch = new SpriteBatch();
  
  Test(this.gl);
  
  init();
  render();
  dispose();
}
