library glib;

import 'dart:html';
import 'glib_graphics.dart';

abstract class Game extends Object with Graphics{
  CanvasElement canvas;
  
  Game({CanvasElement canvas}){
    if (canvas == null){
      canvas = new CanvasElement(width:800, height: 480);
      document.body.append(canvas);
    }
    this.canvas = canvas;
  }
  
  start(){
    this.initGraphics(canvas); //init graphics
    
  }
  
  init();
  update(num delta);
  
}

