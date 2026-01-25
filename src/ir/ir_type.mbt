///|
/// A type in the IR.
/// Named IrType to avoid conflict with MoonBit's built-in Type.
pub(all) struct IrType {
  /// Optional name for the type.
  name : String?
  /// The kind of type.
  kind : IrTypeKind
  /// Whether this type is const-qualified.
  is_const : Bool
  /// Layout information (size, alignment).
  layout : Layout?
}

///|
/// Create a new IrType.
pub fn IrType::new(
  kind : IrTypeKind,
  name? : String? = None,
  is_const? : Bool = false,
  layout? : Layout? = None,
) -> IrType {
  { name, kind, is_const, layout }
}

///|
/// Get the type's kind.
pub fn IrType::kind(self : IrType) -> IrTypeKind {
  self.kind
}

///|
/// Check if this is a void type.
pub fn IrType::is_void(self : IrType) -> Bool {
  match self.kind {
    Void => true
    _ => false
  }
}

///|
/// Check if this is a pointer type.
pub fn IrType::is_pointer(self : IrType) -> Bool {
  match self.kind {
    Pointer(_) => true
    _ => false
  }
}

///|
/// Check if this is a function type.
pub fn IrType::is_function(self : IrType) -> Bool {
  match self.kind {
    Function(_) => true
    _ => false
  }
}

///|
/// Check if this is an integer type.
pub fn IrType::is_int(self : IrType) -> Bool {
  match self.kind {
    Int(_) => true
    _ => false
  }
}

///|
/// Check if this is a floating-point type.
pub fn IrType::is_float(self : IrType) -> Bool {
  match self.kind {
    Float(_) => true
    _ => false
  }
}

///|
/// Check if this is a compound type (struct/union).
pub fn IrType::is_comp(self : IrType) -> Bool {
  match self.kind {
    Comp(_) => true
    _ => false
  }
}

///|
/// Check if this is an enum type.
pub fn IrType::is_enum(self : IrType) -> Bool {
  match self.kind {
    Enum(_) => true
    _ => false
  }
}
