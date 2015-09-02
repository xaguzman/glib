part of glib.graphics;

/** A single vertex attribute defined by its {@link Usage}, its number of components and its shader alias. The Usage is needed for
 * the fixed function pipeline of OpenGL ES 1.x. Generic attributes are not supported in the fixed function pipeline. The number
 * of components defines how many components the attribute has. The alias defines to which shader attribute this attribute should
 * bind. The alias is used by a {@link Mesh} when drawing with a {@link ShaderProgram}. The alias can be changed at any time.
 * 
 * @author mzechner */
class VertexAttribute {
  
  /// the attribute [Usage]
  final int usage;
  
  /// the number of components this attribute has
  final int numComponents;
  
  /// whether the values are normalized to either -1f and +1f (signed) or 0f and +1f (unsigned)
  final bool isNormalized;
  
  /// the GL type of each component, e.g. GL.FLOAT or GL.UNSIGNED_BYTE
  final int type;
  
  /// the offset of this attribute in bytes
  int _offset;
  int get offset => _offset;
  
  /// the alias for the attribute used in a [ShaderProgram]
  String alias;
  
  /// optional unit/index specifier, used for texture coordinates and bone weights
  int unit;
 

  /** Constructs a new VertexAttribute.
   * 
   * [usage] the usage, used for the fixed function pipeline. Generic attributes are not supported in the fixed function
   *           pipeline.
   * [numComponents] the number of components of this attribute, must be between 1 and 4.
   * [alias] the alias used in a shader for this attribute. Can be changed after construction.
   * [index] unit/index of the attribute, used for boneweights and texture coordinates. */
  factory VertexAttribute (int usage, int numComponents, String alias, [int index = 0])
  {
    int type = usage == Usage.ColorPacked ? GL.UNSIGNED_BYTE : GL.FLOAT;
    bool normalized = usage == Usage.ColorPacked;
    return new VertexAttribute._internal(usage, numComponents, type, normalized, alias, index);
  }
    
  VertexAttribute._internal(this.usage, this.numComponents, this.type, this.isNormalized, this.alias, this.unit);
  
  factory VertexAttribute.Position () {
    return new VertexAttribute(Usage.Position, 3, ShaderProgram.POSITION_ATTRIBUTE);
  }

  factory VertexAttribute.TexCoords (int unit) {
    return new VertexAttribute(Usage.TextureCoordinates, 2, '${ShaderProgram.TEXCOORD_ATTRIBUTE}$unit', unit);
  }

  factory VertexAttribute.Normal () {
    return new VertexAttribute(Usage.Normal, 3, ShaderProgram.NORMAL_ATTRIBUTE);
  }
  
  factory VertexAttribute.ColorPacked () {
    return new VertexAttribute(Usage.ColorPacked, 4, ShaderProgram.COLOR_ATTRIBUTE);
  }

  factory VertexAttribute.ColorUnpacked () {
    return new VertexAttribute(Usage.Color, 4, ShaderProgram.COLOR_ATTRIBUTE);
  }

  factory VertexAttribute.Tangent () {
    return new VertexAttribute(Usage.Tangent, 3, ShaderProgram.TANGENT_ATTRIBUTE);
  }

  factory VertexAttribute.Binormal () {
    return new VertexAttribute(Usage.BiNormal, 3, ShaderProgram.BINORMAL_ATTRIBUTE);
  }

  factory VertexAttribute.BoneWeight (int unit) {
    return new VertexAttribute(Usage.BoneWeight, 2, "a_boneWeight$unit", unit);
  }

  /** Tests to determine if the passed object was created with the same parameters */
  operator ==(other) {
    if (other is! VertexAttribute) {
      return false;
    }
    
    return other != null && usage == other.usage && numComponents == other.numComponents && alias == other.alias && unit == other.unit;
  }
  
}

///A set of [VertexAttribute]
class VertexAttributes{
  /// the attributes in the order they were specified
  final List<VertexAttribute> _attributes;
   
  
  /// the size of a single vertex in bytes
  int get vertexStride => _vertexStride;
  int _vertexStride;
  
  /// return the number of attributes
  int get size => _attributes.length;
  
  /// cache of the value calculated by getMask()
  int _mask = -1;
    
  VertexAttributes(this._attributes){
      _vertexStride = _calculateVertexStride();
  }
  
  /// the offset for the first VertexAttribute with the specified [Usage]
  int getOffset (int usage) {
    VertexAttribute vertexAttribute = findByUsage(usage);
    if (vertexAttribute == null) return 0;
    return vertexAttribute.offset ~/ 4;
  }
  
  /** Returns the first VertexAttribute for the given usage.
   * usage The usage of the VertexAttribute to find. */
  VertexAttribute findByUsage (int usage) =>
    _attributes.firstWhere((attrib) => attrib.usage == usage, orElse: () => null);
  
  
  int _calculateVertexStride () {
    int totalComponents = 0;
    for (int i = 0; i < _attributes.length; i++) {
      VertexAttribute attribute = _attributes[i];
      attribute._offset = totalComponents;
      if (attribute.usage == Usage.ColorPacked)
        totalComponents += 4; 
      else
        totalComponents += 4 * attribute.numComponents;
    }
  
    return totalComponents;
  }
  
  String toString () {
    return '[' + _attributes.map((attr) => 
        '(alias: ${attr.alias}, usage: ${attr.usage}, numComponents: ${attr.numComponents}, offset: ${attr.offset})').join('\n') + ']';
  }
  
  VertexAttribute get (int index)  => this[index];
  VertexAttribute operator [](int index) => _attributes[index];
  
  operator ==(obj) {
    if (obj is! VertexAttributes) return false;
    var other = obj as VertexAttributes;
    if (this._attributes.length != other.size) 
      return false;
    for (int i = 0; i < _attributes.length; i++) {
      if (_attributes[i] != other._attributes[i]) 
        return false;
    }
    return true;
  }
  
  /// Calculates a mask based on the contained [VertexAttribute] instances. The mask is a bit-wise or of each attributes [VertexAttribute.usage]
  int getMask () {
    if (_mask == -1) {
      int result = 0;
      for (int i = 0; i < _attributes.length; i++) {
        result |= _attributes[i].usage;
      }
      _mask = result;
    }
    return _mask;
  }
}

class Usage {
  static final int Position = 1;
  static final int Color = 1 << 1;
  static final int ColorPacked = 1 << 2;
  static final int Normal = 1 << 3;
  static final int TextureCoordinates = 1 << 4 ;
  static final int Generic = 1 << 5;
  static final int BoneWeight = 1 << 6;
  static final int Tangent = 1 << 7;
  static final int BiNormal = 1 << 8;
}