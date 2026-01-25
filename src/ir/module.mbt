///|
/// A module (namespace in C++, or the root module).
pub(all) struct Module {
  /// The module name (empty for root module).
  name : String
  /// Child items in this module.
  children : Array[ItemId]
}

///|
/// Create a new Module.
pub fn Module::new(name : String, children? : Array[ItemId] = []) -> Module {
  { name, children }
}

///|
/// Check if this is the root module.
pub fn Module::is_root(self : Module) -> Bool {
  self.name.is_empty()
}

///|
/// Add a child to this module.
pub fn Module::add_child(self : Module, id : ItemId) -> Unit {
  self.children.push(id)
}
