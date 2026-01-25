///|
/// A variable declaration (const, static, global).
pub(all) struct Variable {
  /// The variable name.
  name : String
  /// The variable type.
  type_id : TypeId
  /// The initial value (if a constant with known value).
  value : ConstValue?
  /// Whether this is a const variable.
  is_const : Bool
}

///|
/// Create a new Variable.
pub fn Variable::new(
  name : String,
  type_id : TypeId,
  value? : ConstValue? = None,
  is_const? : Bool = false,
) -> Variable {
  { name, type_id, value, is_const }
}

///|
/// A constant value.
pub(all) enum ConstValue {
  /// An integer constant.
  Int(Int64)
  /// An unsigned integer constant.
  UInt(UInt64)
  /// A floating-point constant.
  Float(Double)
  /// A string constant.
  String(String)
} derive(Eq, Show)
