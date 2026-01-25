///|
/// The different kinds of types in our IR.
pub(all) enum IrTypeKind {
  /// The void type.
  Void
  /// The nullptr type.
  NullPtr
  /// An integer type.
  Int(IntKind)
  /// A floating-point type.
  Float(FloatKind)
  /// A pointer to another type.
  Pointer(TypeId)
  /// An array type with element type and optional size.
  Array(TypeId, Int64?)
  /// A function type.
  Function(FunctionSig)
  /// A compound type (struct or union).
  Comp(CompInfo)
  /// An enumeration type.
  Enum(EnumInfo)
  /// A type alias (typedef).
  Alias(TypeId)
  /// An opaque type we cannot represent.
  Opaque
}

///|
/// Integer type kinds.
pub(all) enum IntKind {
  /// C `bool` or C++ `bool`.
  Bool
  /// C `char` (may be signed or unsigned).
  Char
  /// C `signed char`.
  SChar
  /// C `unsigned char`.
  UChar
  /// C `short`.
  Short
  /// C `unsigned short`.
  UShort
  /// C `int`.
  Int
  /// C `unsigned int`.
  UInt
  /// C `long`.
  Long
  /// C `unsigned long`.
  ULong
  /// C `long long`.
  LongLong
  /// C `unsigned long long`.
  ULongLong
  /// C `__int128` (if supported).
  Int128
  /// C `unsigned __int128` (if supported).
  UInt128
  /// Custom integer type with specific width.
  Custom(Int, Bool) // (bit_width, is_signed)
} derive(Eq, Show)

///|
/// Floating-point type kinds.
pub(all) enum FloatKind {
  /// C `float`.
  Float
  /// C `double`.
  Double
  /// C `long double`.
  LongDouble
  /// C `__float128` (if supported).
  Float128
} derive(Eq, Show)

///|
/// Check if this integer kind is signed.
pub fn IntKind::is_signed(self : IntKind) -> Bool {
  match self {
    Bool | UChar | UShort | UInt | ULong | ULongLong | UInt128 => false
    Char => true // char signedness is implementation-defined, assume signed
    SChar | Short | Int | Long | LongLong | Int128 => true
    Custom(_, signed) => signed
  }
}

///|
/// Get the size in bits for this integer kind (approximate, platform-dependent).
pub fn IntKind::bit_width(self : IntKind) -> Int {
  match self {
    Bool => 1
    Char | SChar | UChar => 8
    Short | UShort => 16
    Int | UInt => 32
    Long | ULong => 64 // Assuming 64-bit platform
    LongLong | ULongLong => 64
    Int128 | UInt128 => 128
    Custom(width, _) => width
  }
}
