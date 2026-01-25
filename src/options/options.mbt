///|
/// Parser options.
pub(all) struct BindgenOptions {
  /// Input header file.
  input_header : String
  /// Output file (optional).
  output : String?
  /// Additional include paths.
  include_paths : Array[String]
  /// Additional clang arguments.
  clang_args : Array[String]
  /// Whether to generate JSON output instead of MoonBit.
  json_output : Bool
  /// Whether to derive Show for generated types.
  derive_show : Bool
  /// Whether to derive Eq for generated types.
  derive_eq : Bool
}

///|
/// Create default BindgenOptions.
pub fn BindgenOptions::new(input_header : String) -> BindgenOptions {
  {
    input_header,
    output: None,
    include_paths: [],
    clang_args: [],
    json_output: false,
    derive_show: true,
    derive_eq: true,
  }
}

///|
/// Builder pattern for BindgenOptions.
pub fn BindgenOptions::with_output(
  self : BindgenOptions,
  output : String,
) -> BindgenOptions {
  { ..self, output: Some(output) }
}

///|
pub fn BindgenOptions::with_include_path(
  self : BindgenOptions,
  path : String,
) -> BindgenOptions {
  let paths = self.include_paths.copy()
  paths.push(path)
  { ..self, include_paths: paths }
}

///|
pub fn BindgenOptions::with_clang_arg(
  self : BindgenOptions,
  arg : String,
) -> BindgenOptions {
  let args = self.clang_args.copy()
  args.push(arg)
  { ..self, clang_args: args }
}

///|
pub fn BindgenOptions::with_json_output(
  self : BindgenOptions,
  json : Bool,
) -> BindgenOptions {
  { ..self, json_output: json }
}
