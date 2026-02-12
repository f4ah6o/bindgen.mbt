///|
/// Code generator module - generates MoonBit FFI bindings from IR.

///|
/// Configuration for code generation.
pub(all) struct CodegenConfig {
  /// Prefix to add to generated type names.
  type_prefix : String
  /// Whether to generate accessor functions for struct fields.
  generate_accessors : Bool
  /// Whether to generate opaque struct wrappers.
  use_opaque_pointers : Bool
}

///|
/// Create a default CodegenConfig.
pub fn CodegenConfig::default() -> CodegenConfig {
  { type_prefix: "", generate_accessors: true, use_opaque_pointers: true }
}

///|
/// Generate MoonBit bindings from a BindgenContext.
pub fn generate(ctx : @ir.BindgenContext, config : CodegenConfig) -> String {
  let builder = StringBuilder::new()

  // Generate header comment
  builder.write_string("///| Auto-generated MoonBit FFI bindings.\n")
  builder.write_string("///| Do not edit manually.\n\n")

  // Collect items by type for ordered generation
  let functions : Array[@ir.Function] = []
  let types : Array[(@ir.IrType, String?)] = [] // (type, name)
  let variables : Array[@ir.Variable] = []
  ctx.iter_items(fn(item) {
    match item.kind {
      @ir.Function(f) => functions.push(f)
      @ir.Type(t) => types.push((t, item.name))
      @ir.Var(v) => variables.push(v)
      @ir.Module(_) => () // Skip modules
    }
  })

  // Generate type definitions first
  for entry in types {
    let (ty, name) = entry
    generate_type(ctx, config, builder, ty, name)
  }

  // Generate function declarations
  for func in functions {
    generate_function(ctx, config, builder, func)
  }

  // Generate variable declarations (constants)
  for variable in variables {
    generate_variable(ctx, config, builder, variable)
  }
  builder.to_string()
}

///|
/// Generate a type definition.
fn generate_type(
  ctx : @ir.BindgenContext,
  config : CodegenConfig,
  builder : StringBuilder,
  ty : @ir.IrType,
  name : String?,
) -> Unit {
  match ty.kind {
    @ir.Comp(comp) => generate_comp_type(ctx, config, builder, comp, name)
    @ir.Enum(enum_info) => generate_enum_type(config, builder, enum_info, name)
    @ir.Alias(underlying_id) =>
      generate_alias_type(ctx, config, builder, underlying_id, name)
    _ => () // Other types don't need explicit declarations
  }
}

///|
/// Generate a compound type (struct/union).
fn generate_comp_type(
  ctx : @ir.BindgenContext,
  config : CodegenConfig,
  builder : StringBuilder,
  comp : @ir.CompInfo,
  name : String?,
) -> Unit {
  let type_name = match name {
    Some(n) => config.type_prefix + n
    None => return // Skip anonymous types
  }

  // For now, generate as opaque pointer wrapper
  if config.use_opaque_pointers {
    builder.write_string("///|\n")
    builder.write_string("/// Opaque pointer to ")
    builder.write_string(type_name)
    builder.write_string(".\n")
    builder.write_string("pub struct ")
    builder.write_string(type_name)
    builder.write_string("(Int64)\n\n")

    // Generate accessor functions if requested
    if config.generate_accessors && comp.fields.length() > 0 {
      for field in comp.fields {
        if field.name.is_empty() {
          continue
        }
        let field_type_str = type_id_to_moonbit(ctx, field.type_id)

        // Getter
        builder.write_string("///|\n")
        builder.write_string("/// Get the '")
        builder.write_string(field.name)
        builder.write_string("' field.\n")
        builder.write_string("pub fn ")
        builder.write_string(type_name)
        builder.write_string("::")
        builder.write_string(field.name)
        builder.write_string("(self : ")
        builder.write_string(type_name)
        builder.write_string(") -> ")
        builder.write_string(field_type_str)
        builder.write_string(" {\n")
        builder.write_string("  // TODO: Implement field access\n")
        builder.write_string("  abort(\"Not implemented\")\n")
        builder.write_string("}\n\n")
      }
    }
  } else {
    // Generate as a MoonBit struct with fields
    builder.write_string("///|\n")
    match comp.kind {
      @ir.Struct => builder.write_string("/// Struct ")
      @ir.Union => builder.write_string("/// Union ")
    }
    builder.write_string(type_name)
    builder.write_string(".\n")
    builder.write_string("pub(all) struct ")
    builder.write_string(type_name)
    builder.write_string(" {\n")
    for field in comp.fields {
      let field_name = if field.name.is_empty() {
        "_anon"
      } else {
        to_moonbit_identifier(field.name)
      }
      let field_type_str = type_id_to_moonbit(ctx, field.type_id)
      builder.write_string("  ")
      builder.write_string(field_name)
      builder.write_string(" : ")
      builder.write_string(field_type_str)
      builder.write_string("\n")
    }
    builder.write_string("}\n\n")
  }
}

///|
/// Generate an enum type.
fn generate_enum_type(
  config : CodegenConfig,
  builder : StringBuilder,
  enum_info : @ir.EnumInfo,
  name : String?,
) -> Unit {
  let type_name = match name {
    Some(n) => config.type_prefix + n
    None => return // Skip anonymous enums
  }

  // Generate as an enum with explicit values
  builder.write_string("///|\n")
  builder.write_string("/// Enum ")
  builder.write_string(type_name)
  builder.write_string(".\n")
  builder.write_string("pub(all) enum ")
  builder.write_string(type_name)
  builder.write_string(" {\n")
  for variant in enum_info.variants {
    let variant_name = to_moonbit_enum_variant(variant.name)
    builder.write_string("  ")
    builder.write_string(variant_name)
    builder.write_string("\n")
  }
  builder.write_string("} derive(Eq, Show)\n\n")

  // Generate to_int and from_int functions
  builder.write_string("///|\n")
  builder.write_string("/// Convert ")
  builder.write_string(type_name)
  builder.write_string(" to its integer value.\n")
  builder.write_string("pub fn ")
  builder.write_string(type_name)
  builder.write_string("::to_int(self : ")
  builder.write_string(type_name)
  builder.write_string(") -> Int {\n")
  builder.write_string("  match self {\n")
  for variant in enum_info.variants {
    let variant_name = to_moonbit_enum_variant(variant.name)
    builder.write_string("    ")
    builder.write_string(variant_name)
    builder.write_string(" => ")
    builder.write_string(variant.value.to_string())
    builder.write_string("\n")
  }
  builder.write_string("  }\n")
  builder.write_string("}\n\n")

  // Generate from_int
  builder.write_string("///|\n")
  builder.write_string("/// Create ")
  builder.write_string(type_name)
  builder.write_string(" from an integer value.\n")
  builder.write_string("pub fn ")
  builder.write_string(type_name)
  builder.write_string("::from_int(value : Int) -> ")
  builder.write_string(type_name)
  builder.write_string("? {\n")
  builder.write_string("  match value {\n")
  for variant in enum_info.variants {
    let variant_name = to_moonbit_enum_variant(variant.name)
    builder.write_string("    ")
    builder.write_string(variant.value.to_string())
    builder.write_string(" => Some(")
    builder.write_string(variant_name)
    builder.write_string(")\n")
  }
  builder.write_string("    _ => None\n")
  builder.write_string("  }\n")
  builder.write_string("}\n\n")
}

///|
/// Generate a type alias.
fn generate_alias_type(
  ctx : @ir.BindgenContext,
  config : CodegenConfig,
  builder : StringBuilder,
  underlying_id : @ir.TypeId,
  name : String?,
) -> Unit {
  let type_name = match name {
    Some(n) => config.type_prefix + n
    None => return
  }
  let underlying_str = type_id_to_moonbit(ctx, underlying_id)
  builder.write_string("///|\n")
  builder.write_string("/// Type alias for ")
  builder.write_string(type_name)
  builder.write_string(".\n")
  builder.write_string("pub typealias ")
  builder.write_string(type_name)
  builder.write_string(" = ")
  builder.write_string(underlying_str)
  builder.write_string("\n\n")
}

///|
/// Generate a function declaration.
fn generate_function(
  ctx : @ir.BindgenContext,
  config : CodegenConfig,
  builder : StringBuilder,
  func : @ir.Function,
) -> Unit {
  // Skip variadic functions (not supported by MoonBit FFI)
  if func.is_variadic {
    builder.write_string("// Skipped variadic function: ")
    builder.write_string(func.name)
    builder.write_string("\n\n")
    return
  }

  // Get the function signature
  let sig_type = ctx.get_type(func.signature)
  guard sig_type is Some(sig_ty) else { return }
  guard sig_ty.kind is @ir.Function(sig) else { return }
  let func_name = config.type_prefix + func.name
  let c_name = match func.mangled_name {
    Some(m) => m
    None => func.name
  }
  builder.write_string("///|\n")
  builder.write_string("extern \"C\" fn ")
  builder.write_string(func_name)
  builder.write_string("(")

  // Generate parameters
  let mut first = true
  let mut param_index = 0
  for arg in sig.args {
    if not(first) {
      builder.write_string(", ")
    }
    first = false
    let param_name = if arg.name.is_empty() {
      "arg" + param_index.to_string()
    } else {
      to_moonbit_identifier(arg.name)
    }
    let param_type = type_id_to_moonbit(ctx, arg.type_id)
    builder.write_string(param_name)
    builder.write_string(" : ")
    builder.write_string(param_type)
    param_index = param_index + 1
  }
  builder.write_string(")")

  // Return type
  let return_type = type_id_to_moonbit(ctx, sig.return_type)
  if return_type != "Unit" {
    builder.write_string(" -> ")
    builder.write_string(return_type)
  }
  builder.write_string(" = \"")
  builder.write_string(c_name)
  builder.write_string("\"\n\n")
}

///|
/// Generate a variable declaration.
fn generate_variable(
  ctx : @ir.BindgenContext,
  config : CodegenConfig,
  builder : StringBuilder,
  variable : @ir.Variable,
) -> Unit {
  let var_name = config.type_prefix + to_moonbit_identifier(variable.name)
  let var_type = type_id_to_moonbit(ctx, variable.type_id)

  // Generate as a constant if we have a value, otherwise as extern
  match variable.value {
    Some(@ir.Int(v)) => {
      builder.write_string("///|\n")
      builder.write_string("pub let ")
      builder.write_string(var_name)
      builder.write_string(" : ")
      builder.write_string(var_type)
      builder.write_string(" = ")
      builder.write_string(v.to_string())
      builder.write_string("\n\n")
    }
    Some(@ir.UInt(v)) => {
      builder.write_string("///|\n")
      builder.write_string("pub let ")
      builder.write_string(var_name)
      builder.write_string(" : ")
      builder.write_string(var_type)
      builder.write_string(" = ")
      builder.write_string(v.to_string())
      builder.write_string("\n\n")
    }
    Some(@ir.Float(v)) => {
      builder.write_string("///|\n")
      builder.write_string("pub let ")
      builder.write_string(var_name)
      builder.write_string(" : ")
      builder.write_string(var_type)
      builder.write_string(" = ")
      builder.write_string(v.to_string())
      builder.write_string("\n\n")
    }
    Some(@ir.String(v)) => {
      builder.write_string("///|\n")
      builder.write_string("pub let ")
      builder.write_string(var_name)
      builder.write_string(" : ")
      builder.write_string(var_type)
      builder.write_string(" = \"")
      builder.write_string(escape_string(v))
      builder.write_string("\"\n\n")
    }
    None => {
      // External variable - generate as extern or comment
      builder.write_string("// External variable: ")
      builder.write_string(var_name)
      builder.write_string(" : ")
      builder.write_string(var_type)
      builder.write_string("\n\n")
    }
  }
}

///|
/// Convert an IR TypeId to a MoonBit type string.
fn type_id_to_moonbit(ctx : @ir.BindgenContext, type_id : @ir.TypeId) -> String {
  match ctx.get_type(type_id) {
    Some(ty) => ir_type_to_moonbit(ctx, ty)
    None => "Unit" // Fallback for unknown types
  }
}

///|
/// Convert an IR type to a MoonBit type string.
fn ir_type_to_moonbit(ctx : @ir.BindgenContext, ty : @ir.IrType) -> String {
  match ty.kind {
    @ir.Void => "Unit"
    @ir.NullPtr => "Int64" // Represent as pointer-sized int
    @ir.Int(int_kind) => int_kind_to_moonbit(int_kind)
    @ir.Float(float_kind) => float_kind_to_moonbit(float_kind)
    @ir.Pointer(_) => "Int64" // All pointers as Int64
    @ir.Array(_, _) => "Int64" // Arrays decay to pointers
    @ir.Function(_) => "Int64" // Function pointers as Int64
    @ir.Comp(_) =>
      match ty.name {
        Some(n) => n
        None => "Int64" // Anonymous struct as opaque pointer
      }
    @ir.Enum(_) =>
      match ty.name {
        Some(n) => n
        None => "Int" // Anonymous enum as Int
      }
    @ir.Alias(underlying_id) => type_id_to_moonbit(ctx, underlying_id)
    @ir.Opaque => "Int64"
  }
}

///|
/// Convert an IntKind to MoonBit type.
fn int_kind_to_moonbit(kind : @ir.IntKind) -> String {
  match kind {
    @ir.Bool => "Bool"
    @ir.Char | @ir.SChar => "Int" // signed char
    @ir.UChar => "UInt"
    @ir.Short => "Int"
    @ir.UShort => "UInt"
    @ir.Int => "Int"
    @ir.UInt => "UInt"
    @ir.Long => "Int64" // long is 64-bit on most modern platforms
    @ir.ULong => "UInt64"
    @ir.LongLong => "Int64"
    @ir.ULongLong => "UInt64"
    @ir.Int128 => "Int64" // No 128-bit type in MoonBit, use 64-bit
    @ir.UInt128 => "UInt64"
    @ir.Custom(bits, signed) =>
      if bits <= 32 {
        if signed {
          "Int"
        } else {
          "UInt"
        }
      } else if signed {
        "Int64"
      } else {
        "UInt64"
      }
  }
}

///|
/// Convert a FloatKind to MoonBit type.
fn float_kind_to_moonbit(kind : @ir.FloatKind) -> String {
  match kind {
    @ir.Float => "Float"
    @ir.Double => "Double"
    @ir.LongDouble => "Double" // No long double in MoonBit
    @ir.Float128 => "Double" // No 128-bit float in MoonBit
  }
}

///|
/// Convert a C identifier to a valid MoonBit identifier.
fn to_moonbit_identifier(name : String) -> String {
  // MoonBit identifiers must start with lowercase letter
  // and cannot be keywords
  if name.is_empty() {
    return "_"
  }

  // Check if it's a MoonBit keyword
  let keywords = [
    "fn", "let", "mut", "if", "else", "match", "while", "for", "break", "continue",
    "return", "struct", "enum", "type", "trait", "impl", "pub", "priv", "test", "true",
    "false", "as", "is", "not", "and", "or",
  ]
  for kw in keywords {
    if name == kw {
      return name + "_"
    }
  }

  // Ensure first character is lowercase
  let bytes = @utf8.encode(name)
  if bytes.length() > 0 {
    let first = bytes[0]
    if first >= 65 && first <= 90 {
      // Uppercase A-Z, convert to lowercase
      let lower_first = Bytes::make(1, (first.to_int() + 32).to_byte())
      let rest = if bytes.length() > 1 { (name[1:] catch { _ => "" }).to_string() } else { "" }
      return lower_first.to_unchecked_string() + rest
    }
  }
  name
}

///|
/// Convert a C enum constant name to MoonBit enum variant.
fn to_moonbit_enum_variant(name : String) -> String {
  // MoonBit enum variants must start with uppercase
  if name.is_empty() {
    return "Unknown"
  }
  let bytes = @utf8.encode(name)
  let first = bytes[0]
  if first >= 97 && first <= 122 {
    // Lowercase a-z, convert to uppercase
    let upper_first = Bytes::make(1, (first.to_int() - 32).to_byte())
    let rest = if bytes.length() > 1 { (name[1:] catch { _ => "" }).to_string() } else { "" }
    return upper_first.to_unchecked_string() + rest
  }

  // If starts with underscore or digit, prefix with "V_"
  if first == 95 || (first >= 48 && first <= 57) {
    return "V" + name
  }
  name
}

///|
/// Escape a string for MoonBit string literal.
fn escape_string(s : String) -> String {
  let builder = StringBuilder::new()
  let bytes = @utf8.encode(s)
  for i = 0; i < bytes.length(); i = i + 1 {
    let b = bytes[i]
    match b {
      b'\\' => builder.write_string("\\\\")
      b'"' => builder.write_string("\\\"")
      b'\n' => builder.write_string("\\n")
      b'\r' => builder.write_string("\\r")
      b'\t' => builder.write_string("\\t")
      _ => {
        let chars = Bytes::make(1, b)
        builder.write_string(chars.to_unchecked_string())
      }
    }
  }
  builder.to_string()
}
