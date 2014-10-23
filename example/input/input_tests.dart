library glib.tests.input;

import 'package:glib/glib.dart';
import 'dart:html';
import 'dart:web_gl' as GL;
import 'dart:typed_data';

main(){
  var canvas = querySelector('#canvas');
  
  
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




class Test{
  GL.RenderingContext gl;
  String get name => "input test";
  static final SpriteBatch batch = new SpriteBatch();
  
  Test(this.gl);
  
  init();
  render();
  dispose();
}