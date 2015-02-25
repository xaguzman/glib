library glib.tests;

import 'dart:html' hide Animation;
import 'package:glib/glib.dart';
import 'dart:web_gl' as GL;
import 'dart:typed_data';

part 'graphics/font_test.dart';
part 'graphics/mesh.dart';
part 'graphics/orthocam_test.dart';
part 'graphics/texture.dart';
part 'graphics/animation2d_test.dart';
part 'input/touch_test.dart';
part 'input/keyboard_test.dart';

TestSuite suite;
Map<String, ApplicationListener> tests;

main(){
  var canvas = querySelector('#canvas');
  
  SelectElement select = querySelector('#tests');
  
  
  tests = new Map.fromIterable( [
    new MeshTest(),
    new FontTest(),
    new OrthographicCameraTest(),
    new TextureTest(),
    new Animation2dTest(),
    new TouchTest(),
    new KeyboardTest()
  ], key: (test) => test.name, value: (test) => test);
  
  suite = new TestSuite(tests.values.first, new WebApplicationConfiguration(), canvas);
  
  select.children.addAll(tests.keys.map( (key) => new OptionElement(data: key, value: key) ));
  select.options.first.selected= true;
  
  select.onChange.listen((Event e) {
    var nextTest = tests[ select.children[select.selectedIndex].text ];
    if (suite.listener != null)
      suite.listener.dispose();
    
    suite.dispose();
    
    suite = new TestSuite(nextTest, new WebApplicationConfiguration(), canvas);
  });
}

class TestSuite extends WebApplication{
    
  TestSuite(ApplicationListener listener, WebApplicationConfiguration config, CanvasElement canvas):
    super(listener, config, canvas: canvas);
  
  
}

abstract class Test implements ApplicationListener{
  final String name;
  
  Test(this.name);
  
  @override render(){
    Glib.gl.clearColor(0, 0, 0, 1);
    Glib.gl.clear(GL.COLOR_BUFFER_BIT);
  }
  
  @override pause(){}
  @override resume() {}
  @override resize(width, height){}
}