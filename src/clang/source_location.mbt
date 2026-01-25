///|
/// High-level wrapper around CXSourceLocation.
/// Identifies a specific source location within a translation unit.
pub(all) struct SourceLocation {
  raw : CXSourceLocation
}

///|
/// Create a SourceLocation from raw.
pub fn SourceLocation::from_raw(raw : CXSourceLocation) -> SourceLocation {
  { raw, }
}

///|
/// Get the file, line, and column information.
pub fn SourceLocation::presumed_location(
  self : SourceLocation,
) -> PresumedLocation {
  // CXString is a newtype over Int64, initialize with 0
  let filename_out : FixedArray[CXString] = [CXString(0L)]
  let line_out : FixedArray[UInt] = [0]
  let column_out : FixedArray[UInt] = [0]
  libclang_getPresumedLocation(self.raw, filename_out, line_out, column_out)
  let filename = cxstring_to_string(filename_out[0])
  libclang_disposeString(filename_out[0])
  { filename, line: line_out[0], column: column_out[0] }
}

///|
/// Determine if this location is in a system header.
pub fn SourceLocation::is_in_system_header(self : SourceLocation) -> Bool {
  libclang_Location_isInSystemHeader(self.raw) != 0
}

///|
/// Presumed source location (file, line, column).
pub(all) struct PresumedLocation {
  filename : String
  line : UInt
  column : UInt
} derive(Eq, Show, ToJson)

///|
impl Show for SourceLocation with output(self, logger) {
  let loc = self.presumed_location()
  logger.write_string(loc.filename)
  logger.write_string(":")
  logger.write_string(loc.line.to_string())
  logger.write_string(":")
  logger.write_string(loc.column.to_string())
}

///|
/// High-level wrapper around CXSourceRange.
pub(all) struct SourceRange {
  raw : CXSourceRange
}

///|
impl Show for SourceRange with output(self, logger) {
  logger.write_string("SourceRange { ... }")
}
