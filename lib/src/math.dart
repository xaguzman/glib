library glib.math;

import 'dart:typed_data';
import 'common.dart';
import 'dart:math' as math;

//import 'package:vector_math/vector_math.dart' as VMath;
//export 'package:vector_math/vector_math.dart';

part 'math/frustum.dart';
part 'math/matrix.dart';
part 'math/quaternion.dart';
part 'math/ray.dart';
part 'math/vector2.dart';
part 'math/vector3.dart';

class MathUtils{  
  static double clampDouble(double value, double min, double max){
    if ( value < min)
      return min;
    if (value > max)
      return max;
    return value;
  }
}

class NumberUtils{
  static final Int8List int8 = new Int8List(4);
  static final Int32List int32 = new Int32List.view(int8.buffer, 0, 1);
  static final Float32List float32 = new Float32List.view(int8.buffer, 0, 1);

  /**
   * Returns a float representation of the given int bits. ArrayBuffer
   * is used for the conversion.
   *
   * @method  intBitsToFloat
   * @static
   * @param  {Number} i the int to cast
   * @return {Number}   the float
   */
  static double intBitsToDouble(int value){
    int32[0] = value;
    return float32[0];
  }

  /**
   * Returns the int bits from the given float. ArrayBuffer is used
   * for the conversion.
   *
   * @method  floatToIntBits
   * @static
   * @param  {Number} f the float to cast
   * @return {Number}   the int bits
   */
  static int floatToIntBits(double d) {
    float32[0] = d;
    return int32[0];
  }

  /**
   * Encodes ABGR int as a float, with slight precision loss.
   *
   * @method  intToFloatColor
   * @static
   * @param {Number} value an ABGR packed integer
   */
  static double intToFloatColor (value) {
    return NumberUtils.intBitsToDouble( value & 0xfeffffff );
  }

  /**
   * Returns a float encoded ABGR value from the given RGBA
   * bytes (0 - 255). Useful for saving bandwidth in vertex data.
   *
   * @method  colorToFloat
   * @static
   * @param {Number} r the Red byte (0 - 255)
   * @param {Number} g the Green byte (0 - 255)
   * @param {Number} b the Blue byte (0 - 255)
   * @param {Number} a the Alpha byte (0 - 255)
   * @return {Float32}  a Float32 of the RGBA color
   */
  static colorToDouble(int r, int g, int b, int a) {
    a = a << 24;
    b = b << 16;
    g = g << 8;
    r = r;
    int color = a | b | g | r;
    return NumberUtils.intToFloatColor(color);
  }

  /**
   * Returns true if the number is a power-of-two.
   *
   * @method  isPowerOfTwo
   * @param  {Number}  n the number to test
   * @return {Boolean}   true if power-of-two
   */
  static bool isPowerOfTwo(int n) => (n & (n - 1)) == 0;

  /**
   * Returns the next highest power-of-two from the specified number. 
   * 
   * @param  {Number} n the number to test
   * @return {Number}   the next highest power of two
   */
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

