part of glib.math;

class Rect{
  double x, y, width, height;
  
  Rect({this.x: 0.0, this.y:0.0, this.width:0.0, this.height:0.0});
  
  bool contains(double x, double y) => 
    this.x <= x && this.x + this.width >= x && this.y <= y && this.y + this.height >= y;

  bool overlaps (Rect r) => 
    x < r.x + r.width && x + width > r.x && y < r.y + r.height && y + height > r.y;

  void set(num x, num y, num width, num height){
    this
      ..x = x.toDouble()
      ..y = y.toDouble()
      ..width = width.toDouble()
      ..height = height.toDouble();
  }

}