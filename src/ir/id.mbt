///|
/// Unique identifier for an item in the IR.
pub(all) struct ItemId(UInt64) derive(Eq, Hash, Show, Compare, ToJson)

///|
/// Unique identifier for a type in the IR.
pub(all) struct TypeId(UInt64) derive(Eq, Hash, Show, Compare, ToJson)

///|
/// Create an ItemId from a raw value.
pub fn ItemId::new(id : UInt64) -> ItemId {
  ItemId(id)
}

///|
/// Create a TypeId from a raw value.
pub fn TypeId::new(id : UInt64) -> TypeId {
  TypeId(id)
}

///|
/// Get the raw value of an ItemId.
pub fn ItemId::raw(self : ItemId) -> UInt64 {
  self.0
}

///|
/// Get the raw value of a TypeId.
pub fn TypeId::raw(self : TypeId) -> UInt64 {
  self.0
}
