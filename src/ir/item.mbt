///|
/// An item in the IR. Items represent declarations in the C/C++ source.
pub(all) struct Item {
  /// Unique identifier for this item.
  id : ItemId
  /// The kind of item (type, function, variable, module).
  kind : ItemKind
  /// The name of the item, if it has one.
  name : String?
  /// Comment/documentation associated with the item.
  comment : String?
  /// Source location of the item.
  location : SourceLocation?
  /// Parent item (for nested items).
  parent : ItemId?
}

///|
/// Create a new Item.
pub fn Item::new(
  id : ItemId,
  kind : ItemKind,
  name? : String? = None,
  comment? : String? = None,
  location? : SourceLocation? = None,
  parent? : ItemId? = None,
) -> Item {
  { id, kind, name, comment, location, parent }
}

///|
/// Get the item's ID.
pub fn Item::id(self : Item) -> ItemId {
  self.id
}

///|
/// Get the item's kind.
pub fn Item::kind(self : Item) -> ItemKind {
  self.kind
}

///|
/// Get the item's name.
pub fn Item::name(self : Item) -> String? {
  self.name
}

///|
/// Check if this is a type item.
pub fn Item::is_type(self : Item) -> Bool {
  match self.kind {
    Type(_) => true
    _ => false
  }
}

///|
/// Check if this is a function item.
pub fn Item::is_function(self : Item) -> Bool {
  match self.kind {
    Function(_) => true
    _ => false
  }
}

///|
/// Check if this is a variable item.
pub fn Item::is_var(self : Item) -> Bool {
  match self.kind {
    Var(_) => true
    _ => false
  }
}

///|
/// Check if this is a module item.
pub fn Item::is_module(self : Item) -> Bool {
  match self.kind {
    Module(_) => true
    _ => false
  }
}
