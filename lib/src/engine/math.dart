library glib.math;

import 'dart:typed_data';

import 'dart:math';
export 'dart:math';

//import 'package:vector_math/vector_math.dart' as VMath;
//export 'package:vector_math/vector_math.dart';

part 'math/frustum.dart';
part 'math/matrix.dart';
part 'math/plane.dart';
part 'math/quaternion.dart';
part 'math/ray.dart';
part 'math/rect.dart';
part 'math/vector2.dart';
part 'math/vector3.dart';

class MathUtils{  
  static final double radiansToDegrees = 180 / PI;
  static final double degreesToRadians = PI / 180;
  static final Random _random = new Random();
  
  static double clampDouble(double value, double min, double max){
    if ( value < min)
      return min;
    if (value > max)
      return max;
    return value;
  }
  
  /// Returns a random number between 0 (inclusive) and the specified value (inclusive).
  static int randomInt(int range) {
    return _random.nextInt(range + 1);
  }

  static num cbrt(num val){
    return pow(val, 1 / 3);
  }

  static double cosDeg(num value){
    return cos(value * degreesToRadians);
  }

  static double sinDeg(num value){
    return sin(value * degreesToRadians);
  }
}

/// Number conversion utilities. Useful for packing data into single doubles and ints.
/// Ported from https://github.com/mattdesl/number-util
class NumberUtils{
  static final Int8List int8 = new Int8List(4);
  static final Int32List int32 = new Int32List.view(int8.buffer, 0, 1);
  static final Float32List float32 = new Float32List.view(int8.buffer, 0, 1);

  /// Returns a double representation of the given int bits. [Float32List] is used for the conversion.
  static double intToDoubleBits(int value){
    int32[0] = value;
    return float32[0];
  }

  /// Returns the int bits from the given float. [Int32List] is usedfor the conversion.
  static int floatToIntBits(double d) {
    float32[0] = d;
    return int32[0];
  }

  /// Encodes ABGR int as a float, with slight precision loss.
  ///
  /// [value] an ABGR packed integer
  static double intToFloatColor (int value) {
    return NumberUtils.intToDoubleBits( value & 0xfeffffff );
  }

  /// Returns a double encoded ABGR value from the given RGBA bytes (0 - 255). Useful for saving bandwidth in vertex data.
  ///
  /// [r] the Red byte (0 - 255)
  /// [g] the Green byte (0 - 255)
  /// [b] the Blue byte (0 - 255)
  /// [a] the Alpha byte (0 - 255)
  /// returns a Float32 of the RGBA color
  static double colorToDouble(int r, int g, int b, int a) {
    a = a << 24;
    b = b << 16;
    g = g << 8;
    r = r;
    int color = a | b | g | r;
    return NumberUtils.intToFloatColor(color);
  }
  
  
  /// Returns true if the number is a power-of-two.
  static bool isPowerOfTwo(int n) => (n & (n - 1)) == 0;

  /// Returns the next highest power-of-two from the specified number. 
  /// returns   the next highest power of two
  static int nextPowerOfTwo (int n) {
    n--;
    n |= n >> 1;
    n |= n >> 2;
    n |= n >> 4;
    n |= n >> 8;
    n |= n >> 16;
    return n+1;
  }

}

