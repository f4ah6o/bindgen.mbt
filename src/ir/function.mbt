///|
/// A function declaration.
pub(all) struct Function {
  /// The function name.
  name : String
  /// The mangled name (symbol name).
  mangled_name : String?
  /// The function signature type.
  signature : TypeId
  /// The kind of function.
  kind : FunctionKind
  /// Whether this function is variadic.
  is_variadic : Bool
}

///|
/// Create a new Function.
pub fn Function::new(
  name : String,
  signature : TypeId,
  kind? : FunctionKind = FunctionKind::Function,
  mangled_name? : String? = None,
  is_variadic? : Bool = false,
) -> Function {
  { name, mangled_name, signature, kind, is_variadic }
}

///|
/// What kind of function is this?
pub(all) enum FunctionKind {
  /// A plain, free function.
  Function
  /// A static method.
  StaticMethod
  /// A normal method.
  Method
  /// A constructor.
  Constructor
  /// A destructor.
  Destructor
  /// A virtual method.
  Virtual
  /// A pure virtual method.
  PureVirtual
} derive(Eq, Show)

///|
/// A function signature (type).
pub(all) struct FunctionSig {
  /// Return type.
  return_type : TypeId
  /// Argument types with optional names.
  args : Array[FunctionArg]
  /// Whether this is a variadic function.
  is_variadic : Bool
  /// Calling convention (if known).
  abi : String?
}

///|
/// Create a new FunctionSig.
pub fn FunctionSig::new(
  return_type : TypeId,
  args : Array[FunctionArg],
  is_variadic? : Bool = false,
  abi? : String? = None,
) -> FunctionSig {
  { return_type, args, is_variadic, abi }
}

///|
/// A function argument.
pub(all) struct FunctionArg {
  /// The argument name (may be empty for unnamed parameters).
  name : String
  /// The argument type.
  type_id : TypeId
}

///|
/// Create a new FunctionArg.
pub fn FunctionArg::new(name : String, type_id : TypeId) -> FunctionArg {
  { name, type_id }
}
