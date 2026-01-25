///|
/// Layout information for a type (size and alignment).
pub(all) struct Layout {
  /// Size in bytes.
  size : Int64
  /// Alignment in bytes.
  align : Int64
} derive(Eq, Show, ToJson)

///|
/// Create a new Layout.
pub fn Layout::new(size : Int64, align : Int64) -> Layout {
  { size, align }
}

///|
/// Get the size in bytes.
pub fn Layout::size(self : Layout) -> Int64 {
  self.size
}

///|
/// Get the alignment in bytes.
pub fn Layout::align(self : Layout) -> Int64 {
  self.align
}

///|
/// Check if this is a zero-sized type.
pub fn Layout::is_zero_sized(self : Layout) -> Bool {
  self.size == 0L
}

///|
/// Known layouts for common types.
pub fn Layout::for_int() -> Layout {
  Layout::new(4L, 4L)
}

///|
pub fn Layout::for_long() -> Layout {
  Layout::new(8L, 8L)
}

///|
pub fn Layout::for_pointer() -> Layout {
  Layout::new(8L, 8L) // 64-bit
}
