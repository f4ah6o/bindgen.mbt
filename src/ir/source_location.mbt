///|
/// A source location (from clang).
pub(all) struct SourceLocation {
  /// The file path.
  file : String
  /// The line number (1-based).
  line : UInt
  /// The column number (1-based).
  column : UInt
} derive(Eq, Show, ToJson)

///|
/// Create a new SourceLocation.
pub fn SourceLocation::new(
  file : String,
  line : UInt,
  column : UInt,
) -> SourceLocation {
  { file, line, column }
}
