part of glib.common;

/// Various scaling types for fitting one rectangle into another
class Scaling {
  /// Scales the source to fit the target while keeping the same aspect ratio. This may cause the source to be smaller than the target in one direction
  static const Scaling fit = const Scaling._internal(1);
  
  /// Scales the source to fill the target while keeping the same aspect ratio. This may cause the source to be larger than the target in one direction
  static const Scaling fill = const Scaling._internal(2);
  
  /// Scales the source to fill the target in the x direction while keeping the same aspect ratio. This may cause the source to be smaller or larger than the target in the y direction
  static const Scaling fillX = const Scaling._internal(3);
  
  /// Scales the source to fill the target in the y direction while keeping the same aspect ratio. This may cause the source to be smaller or larger than the target in the x direction
  static const Scaling fillY = const Scaling._internal(4);
  
  /// Scales the source to fill the target. This may cause the source to not keep the same aspect ratio.
  static const Scaling stretch = const Scaling._internal(5);
  
  /// Scales the source to fill the target in the x direction, without changing the y direction. This may cause the source to not keep the same aspect ratio
  static const Scaling stretchX = const Scaling._internal(6);
  
  /// Scales the source to fill the target in the y direction, without changing the x direction. This may cause the source to not keep the same aspect ratio
  static const Scaling stretchY = const Scaling._internal(7);
  
  /// The source is not scaled
  static const Scaling none = const Scaling._internal(8);

  static final List<double> _temp = new List.filled(2, 0.0);
  final int _val;
  
  
  const Scaling._internal(this._val);

  /** Returns the size of the source scaled to the target. Note the same Vector2 instance is always returned and should never be
   * cached. */
  List<double> apply (double sourceWidth, double sourceHeight, double targetWidth, double targetHeight) {
    switch (this._val) {
      case 1: 
        double targetRatio = targetHeight / targetWidth;
        double sourceRatio = sourceHeight / sourceWidth;
        double scale = targetRatio > sourceRatio ? targetWidth / sourceWidth : targetHeight / sourceHeight;
       _temp[0] = sourceWidth * scale;
       _temp[1] = sourceHeight * scale;
        break;
      
      case 2: 
        double targetRatio = targetHeight / targetWidth;
        double sourceRatio = sourceHeight / sourceWidth;
        double scale = targetRatio < sourceRatio ? targetWidth / sourceWidth : targetHeight / sourceHeight;
       _temp[0] = sourceWidth * scale;
       _temp[1] = sourceHeight * scale;
        break;
      
      case 3: 
        double scale = targetWidth / sourceWidth;
       _temp[0] = sourceWidth * scale;
       _temp[1] = sourceHeight * scale;
        break;
      
      case 4: 
        double scale = targetHeight / sourceHeight;
       _temp[0] = sourceWidth * scale;
       _temp[1] = sourceHeight * scale;
        break;
      
      case 5:
       _temp[0] = targetWidth;
       _temp[1] = targetHeight;
        break;
        
      case 6:
       _temp[0] = targetWidth;
       _temp[1] = sourceHeight;
        break;
        
      case 7:
       _temp[0] = sourceWidth;
       _temp[1] = targetHeight;
        break;
        
      case 8:
       _temp[0] = sourceWidth;
       _temp[1] = sourceHeight;
        break;
    }
    return _temp;
  }
}