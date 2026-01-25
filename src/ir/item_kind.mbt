///|
/// The different kinds of items we can have in the IR.
pub(all) enum ItemKind {
  /// A module (namespace in C++, or the root module).
  Module(Module)
  /// A type declaration (struct, union, enum, typedef, etc).
  Type(IrType)
  /// A function declaration.
  Function(Function)
  /// A variable declaration (const, static).
  Var(Variable)
}

///|
/// Get the kind name as a string.
pub fn ItemKind::kind_name(self : ItemKind) -> String {
  match self {
    Module(_) => "Module"
    Type(_) => "Type"
    Function(_) => "Function"
    Var(_) => "Var"
  }
}

///|
/// Get the Module if this is a module kind.
pub fn ItemKind::as_module(self : ItemKind) -> Module? {
  match self {
    Module(m) => Some(m)
    _ => None
  }
}

///|
/// Get the IrType if this is a type kind.
pub fn ItemKind::as_type(self : ItemKind) -> IrType? {
  match self {
    Type(t) => Some(t)
    _ => None
  }
}

///|
/// Get the Function if this is a function kind.
pub fn ItemKind::as_function(self : ItemKind) -> Function? {
  match self {
    Function(f) => Some(f)
    _ => None
  }
}

///|
/// Get the Variable if this is a variable kind.
pub fn ItemKind::as_var(self : ItemKind) -> Variable? {
  match self {
    Var(v) => Some(v)
    _ => None
  }
}
