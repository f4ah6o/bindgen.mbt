///|
/// High-level wrapper around CXType.
/// Represents a type in the clang type system.
pub(all) struct Type {
  raw : CXType
}

///|
/// Create a Type from a raw CXType.
pub fn Type::from_raw(raw : CXType) -> Type {
  { raw, }
}

///|
/// Get the raw CXType.
pub fn Type::to_raw(self : Type) -> CXType {
  self.raw
}

///|
/// Get the kind of this type.
pub fn Type::kind(self : Type) -> TypeKind {
  TypeKind::from_raw(self.raw.kind)
}

///|
/// Get the spelling of this type.
pub fn Type::spelling(self : Type) -> String {
  let cxstring = libclang_getTypeSpelling(self.raw)
  let result = cxstring_to_string(cxstring)
  libclang_disposeString(cxstring)
  result
}

///|
/// Get the canonical type for this type.
pub fn Type::canonical(self : Type) -> Type {
  let raw = libclang_getCanonicalType(self.raw)
  Type::from_raw(raw)
}

///|
/// Determine whether this type is const-qualified.
pub fn Type::is_const_qualified(self : Type) -> Bool {
  libclang_isConstQualifiedType(self.raw) != 0
}

///|
/// Determine whether this type is volatile-qualified.
pub fn Type::is_volatile_qualified(self : Type) -> Bool {
  libclang_isVolatileQualifiedType(self.raw) != 0
}

///|
/// Get the pointee type of a pointer type.
pub fn Type::pointee_type(self : Type) -> Type {
  let raw = libclang_getPointeeType(self.raw)
  Type::from_raw(raw)
}

///|
/// Get the typedef name (if this is a typedef).
pub fn Type::typedef_name(self : Type) -> String {
  let cxstring = libclang_getTypedefName(self.raw)
  let result = cxstring_to_string(cxstring)
  libclang_disposeString(cxstring)
  result
}

///|
/// Get the declaration cursor for this type.
pub fn Type::declaration(self : Type) -> Cursor {
  let raw = libclang_getTypeDeclaration(self.raw)
  Cursor::from_raw(raw)
}

///|
/// Get the size of this type in bytes (-1 if unknown or incomplete).
pub fn Type::size_of(self : Type) -> Int64 {
  libclang_Type_getSizeOf(self.raw)
}

///|
/// Get the alignment of this type in bytes (-1 if unknown).
pub fn Type::align_of(self : Type) -> Int64 {
  libclang_Type_getAlignOf(self.raw)
}

///|
/// Get the offset of a field in bits.
pub fn Type::offset_of(self : Type, field_name : String) -> Int64 {
  let field_bytes = string_to_cstring(field_name)
  libclang_Type_getOffsetOf(self.raw, field_bytes)
}

///|
/// Get the element type of an array type.
pub fn Type::array_element_type(self : Type) -> Type {
  let raw = libclang_getArrayElementType(self.raw)
  Type::from_raw(raw)
}

///|
/// Get the size of an array type.
pub fn Type::array_size(self : Type) -> Int64 {
  libclang_getArraySize(self.raw)
}

///|
/// Get the number of elements in a vector type.
pub fn Type::num_elements(self : Type) -> Int64 {
  libclang_getNumElements(self.raw)
}

///|
/// Get the return type of a function type.
pub fn Type::result_type(self : Type) -> Type {
  let raw = libclang_getResultType(self.raw)
  Type::from_raw(raw)
}

///|
/// Get the number of arguments for a function type.
pub fn Type::num_arg_types(self : Type) -> Int {
  libclang_getNumArgTypes(self.raw)
}

///|
/// Get the argument type at the given index.
pub fn Type::arg_type(self : Type, i : Int) -> Type {
  let raw = libclang_getArgType(self.raw, i.reinterpret_as_uint())
  Type::from_raw(raw)
}

///|
/// Get all argument types for a function type.
pub fn Type::arg_types(self : Type) -> Array[Type] {
  let n = self.num_arg_types()
  let result : Array[Type] = []
  for i = 0; i < n; i = i + 1 {
    result.push(self.arg_type(i))
  }
  result
}

///|
/// Determine if a function type is variadic.
pub fn Type::is_variadic(self : Type) -> Bool {
  libclang_isFunctionTypeVariadic(self.raw) != 0
}

///|
/// Get the named type of an elaborated type.
pub fn Type::named_type(self : Type) -> Type {
  let raw = libclang_Type_getNamedType(self.raw)
  Type::from_raw(raw)
}

///|
/// Check equality between types.
pub fn Type::equals(self : Type, other : Type) -> Bool {
  libclang_equalTypes(self.raw, other.raw) != 0
}

///|
/// Check if this is a valid type (not invalid).
pub fn Type::is_valid(self : Type) -> Bool {
  self.raw.kind != CXType_Invalid
}

///|
pub impl Eq for Type with equal(self, other) {
  self.equals(other)
}

///|
pub impl Show for Type with output(self, logger) {
  let kind = self.kind()
  let spelling = self.spelling()
  logger.write_string("Type { kind: ")
  kind.output(logger)
  logger.write_string(", spelling: \"")
  logger.write_string(spelling)
  logger.write_string("\" }")
}

// =============================================================================
// TypeKind enum
// =============================================================================

///|
/// High-level enum representing type kinds.
pub(all) enum TypeKind {
  Invalid
  Unexposed
  Void
  Bool
  Char_U
  UChar
  Char16
  Char32
  UShort
  UInt
  ULong
  ULongLong
  UInt128
  Char_S
  SChar
  WChar
  Short
  Int
  Long
  LongLong
  Int128
  Float
  Double
  LongDouble
  NullPtr
  Pointer
  BlockPointer
  LValueReference
  RValueReference
  Record
  Enum
  Typedef
  FunctionNoProto
  FunctionProto
  ConstantArray
  Vector
  IncompleteArray
  VariableArray
  DependentSizedArray
  MemberPointer
  Elaborated
  Other(Int)
} derive(Eq, Show, ToJson)

///|
/// Convert from raw type kind integer.
pub fn TypeKind::from_raw(kind : Int) -> TypeKind {
  match kind {
    0 => Invalid
    1 => Unexposed
    2 => Void
    3 => Bool
    4 => Char_U
    5 => UChar
    6 => Char16
    7 => Char32
    8 => UShort
    9 => UInt
    10 => ULong
    11 => ULongLong
    12 => UInt128
    13 => Char_S
    14 => SChar
    15 => WChar
    16 => Short
    17 => Int
    18 => Long
    19 => LongLong
    20 => Int128
    21 => Float
    22 => Double
    23 => LongDouble
    24 => NullPtr
    101 => Pointer
    102 => BlockPointer
    103 => LValueReference
    104 => RValueReference
    105 => Record
    106 => Enum
    107 => Typedef
    110 => FunctionNoProto
    111 => FunctionProto
    112 => ConstantArray
    113 => Vector
    114 => IncompleteArray
    115 => VariableArray
    116 => DependentSizedArray
    117 => MemberPointer
    119 => Elaborated
    _ => Other(kind)
  }
}

///|
/// Convert to raw type kind integer.
pub fn TypeKind::to_raw(self : TypeKind) -> Int {
  match self {
    Invalid => 0
    Unexposed => 1
    Void => 2
    Bool => 3
    Char_U => 4
    UChar => 5
    Char16 => 6
    Char32 => 7
    UShort => 8
    UInt => 9
    ULong => 10
    ULongLong => 11
    UInt128 => 12
    Char_S => 13
    SChar => 14
    WChar => 15
    Short => 16
    Int => 17
    Long => 18
    LongLong => 19
    Int128 => 20
    Float => 21
    Double => 22
    LongDouble => 23
    NullPtr => 24
    Pointer => 101
    BlockPointer => 102
    LValueReference => 103
    RValueReference => 104
    Record => 105
    Enum => 106
    Typedef => 107
    FunctionNoProto => 110
    FunctionProto => 111
    ConstantArray => 112
    Vector => 113
    IncompleteArray => 114
    VariableArray => 115
    DependentSizedArray => 116
    MemberPointer => 117
    Elaborated => 119
    Other(k) => k
  }
}

///|
/// Check if this is an integer type.
pub fn TypeKind::is_integer(self : TypeKind) -> Bool {
  match self {
    Bool
    | Char_U
    | UChar
    | Char16
    | Char32
    | UShort
    | UInt
    | ULong
    | ULongLong
    | UInt128
    | Char_S
    | SChar
    | WChar
    | Short
    | Int
    | Long
    | LongLong
    | Int128 => true
    _ => false
  }
}

///|
/// Check if this is a floating-point type.
pub fn TypeKind::is_floating(self : TypeKind) -> Bool {
  match self {
    Float | Double | LongDouble => true
    _ => false
  }
}

///|
/// Check if this is a signed integer type.
pub fn TypeKind::is_signed(self : TypeKind) -> Bool {
  match self {
    Char_S | SChar | Short | Int | Long | LongLong | Int128 => true
    _ => false
  }
}

///|
/// Check if this is an unsigned integer type.
pub fn TypeKind::is_unsigned(self : TypeKind) -> Bool {
  match self {
    Bool
    | Char_U
    | UChar
    | Char16
    | Char32
    | UShort
    | UInt
    | ULong
    | ULongLong
    | UInt128 => true
    _ => false
  }
}
