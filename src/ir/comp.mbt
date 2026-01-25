///|
/// Information about a compound type (struct or union).
pub(all) struct CompInfo {
  /// What kind of compound type is this?
  kind : CompKind
  /// The fields of this compound type.
  fields : Array[Field]
  /// Whether this is a forward declaration.
  is_forward_decl : Bool
  /// Whether this type is packed.
  is_packed : Bool
}

///|
/// Create a new CompInfo.
pub fn CompInfo::new(
  kind : CompKind,
  fields? : Array[Field] = [],
  is_forward_decl? : Bool = false,
  is_packed? : Bool = false,
) -> CompInfo {
  { kind, fields, is_forward_decl, is_packed }
}

///|
/// The kind of compound type.
pub(all) enum CompKind {
  /// A struct.
  Struct
  /// A union.
  Union
} derive(Eq, Show)

///|
/// Check if this is a struct.
pub fn CompInfo::is_struct(self : CompInfo) -> Bool {
  match self.kind {
    Struct => true
    _ => false
  }
}

///|
/// Check if this is a union.
pub fn CompInfo::is_union(self : CompInfo) -> Bool {
  match self.kind {
    Union => true
    _ => false
  }
}

///|
/// A field in a compound type.
pub(all) struct Field {
  /// The field name (may be empty for anonymous fields).
  name : String
  /// The field type.
  type_id : TypeId
  /// Bit offset from the start of the struct (if known).
  bit_offset : Int64?
  /// Bit width for bit-fields (None for regular fields).
  bit_width : Int?
  /// Whether this is an anonymous field.
  is_anonymous : Bool
}

///|
/// Create a new Field.
pub fn Field::new(
  name : String,
  type_id : TypeId,
  bit_offset? : Int64? = None,
  bit_width? : Int? = None,
  is_anonymous? : Bool = false,
) -> Field {
  { name, type_id, bit_offset, bit_width, is_anonymous }
}

///|
/// Check if this is a bit-field.
pub fn Field::is_bitfield(self : Field) -> Bool {
  not(self.bit_width is None)
}
