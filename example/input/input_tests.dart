library glib.tests.input;

import 'package:glib/glib.dart';
import 'dart:html';
import 'dart:web_gl' as GL;
import 'dart:typed_data';

part 'tests/touch_test.dart';

TestSuite suite;
Map<String, Test> tests;

main(){
  var canvas = querySelector('#canvas');
  
  SelectElement select = querySelector('#tests');
  suite = new TestSuite(canvas);
  
  tests = new Map.fromIterable( [
    new TouchTest(suite.gl),
  ], key: (test) => test.name, value: (test) => test);
  
  select.children.addAll(tests.keys.map( (key) => new OptionElement(data: key, value: key) ));
  select.options.first.selected= true;
  
  select.onChange.listen((Event e) {
    var nextTest = tests[ select.children[select.selectedIndex].text ];
    if (suite.currentTest != null)
      suite.currentTest.dispose();
    suite.currentTest= nextTest..init(suite.input); 
  });
  
  suite.currentTest = tests.values.first..init(suite.input);
  window.animationFrame.then(update);
}

update(num delta){
  suite.render();
  window.animationFrame.then(update);
}


class TestSuite extends Object with Graphics{
  Test currentTest;
  Input input;
  
  TestSuite(CanvasElement canvas){
    initGraphics(canvas);
    input = new CanvasInput(canvas);
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
  String get name => "input test";
  static final SpriteBatch batch = new SpriteBatch();
  
  Test(this.gl);
  
  init(Input input);
  render(){}
  dispose();
}