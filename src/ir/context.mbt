///|
/// The central context for bindgen - holds all parsed items.
pub(all) struct BindgenContext {
  /// All items, indexed by ItemId.
  items : Map[UInt64, Item]
  /// All types, indexed by TypeId.
  types : Map[UInt64, IrType]
  /// The root module.
  root_module : ItemId
  /// Counter for generating new item IDs.
  mut next_item_id : UInt64
  /// Counter for generating new type IDs.
  mut next_type_id : UInt64
}

///|
/// Create a new BindgenContext.
pub fn BindgenContext::new() -> BindgenContext {
  let ctx : BindgenContext = {
    items: {},
    types: {},
    root_module: ItemId::new(0UL),
    next_item_id: 1UL,
    next_type_id: 1UL,
  }
  // Create the root module as item 0
  let root = Module::new("")
  let root_item = Item::new(ItemId::new(0UL), Module(root))
  ctx.items[0UL] = root_item
  ctx
}

///|
/// Generate a new unique ItemId.
pub fn BindgenContext::next_item_id(self : BindgenContext) -> ItemId {
  let id = self.next_item_id
  self.next_item_id = id + 1UL
  ItemId::new(id)
}

///|
/// Generate a new unique TypeId.
pub fn BindgenContext::next_type_id(self : BindgenContext) -> TypeId {
  let id = self.next_type_id
  self.next_type_id = id + 1UL
  TypeId::new(id)
}

///|
/// Add an item to the context.
pub fn BindgenContext::add_item(self : BindgenContext, item : Item) -> Unit {
  self.items[item.id.raw()] = item
}

///|
/// Add a type to the context.
pub fn BindgenContext::add_type(
  self : BindgenContext,
  id : TypeId,
  ty : IrType,
) -> Unit {
  self.types[id.raw()] = ty
}

///|
/// Get an item by ID.
pub fn BindgenContext::get_item(self : BindgenContext, id : ItemId) -> Item? {
  self.items.get(id.raw())
}

///|
/// Get a type by ID.
pub fn BindgenContext::get_type(self : BindgenContext, id : TypeId) -> IrType? {
  self.types.get(id.raw())
}

///|
/// Get the root module.
pub fn BindgenContext::root(self : BindgenContext) -> Item? {
  self.get_item(self.root_module)
}

///|
/// Iterate over all items.
pub fn BindgenContext::iter_items(
  self : BindgenContext,
  f : (Item) -> Unit,
) -> Unit {
  self.items.each(fn(_k, v) { f(v) })
}

///|
/// Iterate over all types.
pub fn BindgenContext::iter_types(
  self : BindgenContext,
  f : (TypeId, IrType) -> Unit,
) -> Unit {
  self.types.each(fn(k, v) { f(TypeId::new(k), v) })
}

///|
/// Get the count of items.
pub fn BindgenContext::item_count(self : BindgenContext) -> Int {
  self.items.length()
}

///|
/// Get the count of types.
pub fn BindgenContext::type_count(self : BindgenContext) -> Int {
  self.types.length()
}
