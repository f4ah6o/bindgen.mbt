///|
/// Information about an enumeration type.
pub(all) struct EnumInfo {
  /// The underlying integer type of the enum.
  repr : TypeId?
  /// The variants/values of the enum.
  variants : Array[EnumVariant]
}

///|
/// Create a new EnumInfo.
pub fn EnumInfo::new(
  variants : Array[EnumVariant],
  repr? : TypeId? = None,
) -> EnumInfo {
  { repr, variants }
}

///|
/// An enumeration variant (value).
pub(all) struct EnumVariant {
  /// The variant name.
  name : String
  /// The variant value.
  value : Int64
  /// Optional comment/documentation.
  comment : String?
}

///|
/// Create a new EnumVariant.
pub fn EnumVariant::new(
  name : String,
  value : Int64,
  comment? : String? = None,
) -> EnumVariant {
  { name, value, comment }
}
