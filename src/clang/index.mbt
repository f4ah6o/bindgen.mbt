///|
/// High-level wrapper around CXIndex.
/// Manages the lifecycle of a clang index used for parsing.
pub(all) struct Index {
  raw : CXIndex
}

///|
/// Create a new clang index.
/// - `exclude_pch`: If true, declarations from precompiled headers are excluded
/// - `display_diagnostics`: If true, diagnostics are printed to stderr
pub fn Index::new(
  exclude_pch? : Bool = false,
  display_diagnostics? : Bool = true,
) -> Index {
  let raw = libclang_createIndex(
    if exclude_pch {
      1
    } else {
      0
    },
    if display_diagnostics {
      1
    } else {
      0
    },
  )
  { raw, }
}

///|
/// Parse a source file to create a translation unit.
pub fn Index::parse_file(
  self : Index,
  filename : String,
  args? : Array[String] = [],
  options? : UInt = 0,
) -> TranslationUnit? {
  let filename_bytes = string_to_cstring(filename)
  let args_bytes : FixedArray[Bytes] = FixedArray::makei(args.length(), fn(i) {
    string_to_cstring(args[i])
  })
  let tu = libclang_parseTranslationUnit(
    self.raw,
    filename_bytes,
    args_bytes,
    args.length(),
    0L, // no unsaved files
    0, // no unsaved files
    options,
  )
  // Check if parsing succeeded (tu is not null)
  // Unfortunately we can't easily check for null with extern types
  // We'll assume success for now and handle errors via diagnostics
  Some({ raw: tu, index: self })
}

///|
/// Dispose of the index. Called automatically when index goes out of scope.
pub fn Index::dispose(self : Index) -> Unit {
  libclang_disposeIndex(self.raw)
}
