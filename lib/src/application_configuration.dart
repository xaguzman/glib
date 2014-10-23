part of glib;

class WebApplicationConfiguration{
/** the width of the drawing area in pixels **/
  int width;
  /** the height of the drawing area in pixels **/
  int height;
  /** whether to use a stencil buffer **/
  bool stencil = false;
  /** whether to enable antialiasing **/
  bool antialiasing = false;
  /** the framerate to run the game at **/
  int fps = 60;
  /** preserve the back buffer, needed if you fetch a screenshot via canvas#toDataUrl, may have performance impact **/
  bool preserveDrawingBuffer = false;
  
  WebApplicationConfiguration(this.width, this.height);

}