///|
/// High-level wrapper around CXTranslationUnit.
/// Represents a parsed source file and provides access to its AST.
pub(all) struct TranslationUnit {
  raw : CXTranslationUnit
  index : Index
}

///|
/// Get the cursor representing the translation unit itself.
/// This is the root of the AST.
pub fn TranslationUnit::cursor(self : TranslationUnit) -> Cursor {
  let raw = libclang_getTranslationUnitCursor(self.raw)
  Cursor::from_raw(raw)
}

///|
/// Get the number of diagnostics for this translation unit.
pub fn TranslationUnit::num_diagnostics(self : TranslationUnit) -> UInt {
  libclang_getNumDiagnostics(self.raw)
}

///|
/// Get a diagnostic at the given index.
pub fn TranslationUnit::diagnostic(
  self : TranslationUnit,
  index : UInt,
) -> Diagnostic {
  let raw = libclang_getDiagnostic(self.raw, index)
  { raw, }
}

///|
/// Get all diagnostics for this translation unit.
pub fn TranslationUnit::diagnostics(
  self : TranslationUnit,
) -> Array[Diagnostic] {
  let n = self.num_diagnostics()
  let result : Array[Diagnostic] = []
  for i = 0U; i < n; i = i + 1 {
    result.push(self.diagnostic(i))
  }
  result
}

///|
/// Dispose of the translation unit.
pub fn TranslationUnit::dispose(self : TranslationUnit) -> Unit {
  libclang_disposeTranslationUnit(self.raw)
}

///|
/// A diagnostic message from clang.
pub(all) struct Diagnostic {
  raw : CXDiagnostic
}

///|
/// Format the diagnostic for display.
pub fn Diagnostic::format(self : Diagnostic) -> String {
  let options = CXDiagnostic_DisplaySourceLocation |
    CXDiagnostic_DisplaySourceRanges |
    CXDiagnostic_DisplayOption |
    CXDiagnostic_DisplayCategoryName
  let cxstring = libclang_formatDiagnostic(self.raw, options)
  let result = cxstring_to_string(cxstring)
  libclang_disposeString(cxstring)
  result
}

///|
/// Dispose of the diagnostic.
pub fn Diagnostic::dispose(self : Diagnostic) -> Unit {
  libclang_disposeDiagnostic(self.raw)
}

///|
impl Show for Diagnostic with output(self, logger) {
  logger.write_string(self.format())
}
