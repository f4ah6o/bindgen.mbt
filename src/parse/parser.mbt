///|
/// Parser module - converts clang AST to our IR.

///|
/// Parse error type.
pub suberror ParseError {
  ParseError(String)
}

///|
/// Parse a C/C++ header file and return the bindgen context.
pub fn parse_header(
  header_path : String,
  clang_args : Array[String],
) -> @ir.BindgenContext raise ParseError {
  let index = @clang.Index::new(exclude_pch=false, display_diagnostics=true)
  let tu = index.parse_file(header_path, args=clang_args)
  guard tu is Some(tu) else {
    raise ParseError("Failed to parse translation unit: \{header_path}")
  }

  // Check for parsing errors
  let diags = tu.diagnostics()
  // Check severity via format - if format contains "error:" it's an error
  let has_errors = diags.iter().any(fn(d) { d.format().contains("error:") })
  if has_errors {
    let mut msg = "Parsing errors:\n"
    for diag in diags {
      let formatted = diag.format()
      if formatted.contains("error:") {
        msg = msg + "  " + formatted + "\n"
      }
    }
    raise ParseError(msg)
  }

  // Create the context and parse the AST
  let ctx = @ir.BindgenContext::new()
  let cursor = tu.cursor()
  parse_cursor(ctx, cursor, @ir.ItemId::new(0UL)) // root module
  ctx
}

///|
/// Parse a cursor and add items to the context.
fn parse_cursor(
  ctx : @ir.BindgenContext,
  cursor : @clang.Cursor,
  parent : @ir.ItemId,
) -> Unit {
  cursor.visit_children(fn(child, _parent) {
    // Skip cursors from system headers
    let loc = child.location()
    if loc.is_in_system_header() {
      return @clang.VisitResult::Continue
    }
    match child.kind() {
      @clang.StructDecl => parse_struct(ctx, child, parent) |> ignore
      @clang.UnionDecl => parse_union(ctx, child, parent) |> ignore
      @clang.EnumDecl => parse_enum(ctx, child, parent) |> ignore
      @clang.FunctionDecl => parse_function(ctx, child, parent) |> ignore
      @clang.TypedefDecl => parse_typedef(ctx, child, parent) |> ignore
      @clang.VarDecl => parse_var(ctx, child, parent) |> ignore
      _ => ()
    }
    @clang.VisitResult::Continue
  })
  |> ignore
}

///|
/// Parse a struct declaration.
fn parse_struct(
  ctx : @ir.BindgenContext,
  cursor : @clang.Cursor,
  parent : @ir.ItemId,
) -> @ir.ItemId {
  let name = cursor.spelling()
  let item_id = ctx.next_item_id()
  let type_id = ctx.next_type_id()

  // Parse fields
  let fields : Array[@ir.Field] = []
  cursor.visit_children(fn(child, _) {
    if child.kind() == @clang.FieldDecl {
      let field_name = child.spelling()
      let field_type_id = parse_type(ctx, child.cursor_type())
      fields.push(@ir.Field::new(field_name, field_type_id))
    }
    @clang.VisitResult::Continue
  })
  |> ignore
  let comp = @ir.CompInfo::new(@ir.Struct, fields~)
  let ty = @ir.IrType::new(
    @ir.Comp(comp),
    name=if name.is_empty() { None } else { Some(name) },
  )
  ctx.add_type(type_id, ty)
  let item = @ir.Item::new(
    item_id,
    @ir.Type(ty),
    name=if name.is_empty() { None } else { Some(name) },
    parent=Some(parent),
  )
  ctx.add_item(item)
  item_id
}

///|
/// Parse a union declaration.
fn parse_union(
  ctx : @ir.BindgenContext,
  cursor : @clang.Cursor,
  parent : @ir.ItemId,
) -> @ir.ItemId {
  let name = cursor.spelling()
  let item_id = ctx.next_item_id()
  let type_id = ctx.next_type_id()

  // Parse fields
  let fields : Array[@ir.Field] = []
  cursor.visit_children(fn(child, _) {
    if child.kind() == @clang.FieldDecl {
      let field_name = child.spelling()
      let field_type_id = parse_type(ctx, child.cursor_type())
      fields.push(@ir.Field::new(field_name, field_type_id))
    }
    @clang.VisitResult::Continue
  })
  |> ignore
  let comp = @ir.CompInfo::new(@ir.Union, fields~)
  let ty = @ir.IrType::new(
    @ir.Comp(comp),
    name=if name.is_empty() { None } else { Some(name) },
  )
  ctx.add_type(type_id, ty)
  let item = @ir.Item::new(
    item_id,
    @ir.Type(ty),
    name=if name.is_empty() { None } else { Some(name) },
    parent=Some(parent),
  )
  ctx.add_item(item)
  item_id
}

///|
/// Parse an enum declaration.
fn parse_enum(
  ctx : @ir.BindgenContext,
  cursor : @clang.Cursor,
  parent : @ir.ItemId,
) -> @ir.ItemId {
  let name = cursor.spelling()
  let item_id = ctx.next_item_id()
  let type_id = ctx.next_type_id()

  // Parse variants
  let variants : Array[@ir.EnumVariant] = []
  cursor.visit_children(fn(child, _) {
    if child.kind() == @clang.EnumConstantDecl {
      let variant_name = child.spelling()
      let value = child.enum_constant_value()
      variants.push(@ir.EnumVariant::new(variant_name, value))
    }
    @clang.VisitResult::Continue
  })
  |> ignore
  let enum_info = @ir.EnumInfo::new(variants)
  let ty = @ir.IrType::new(
    @ir.Enum(enum_info),
    name=if name.is_empty() { None } else { Some(name) },
  )
  ctx.add_type(type_id, ty)
  let item = @ir.Item::new(
    item_id,
    @ir.Type(ty),
    name=if name.is_empty() { None } else { Some(name) },
    parent=Some(parent),
  )
  ctx.add_item(item)
  item_id
}

///|
/// Parse a function declaration.
fn parse_function(
  ctx : @ir.BindgenContext,
  cursor : @clang.Cursor,
  parent : @ir.ItemId,
) -> @ir.ItemId {
  let name = cursor.spelling()
  let item_id = ctx.next_item_id()
  let sig_type_id = ctx.next_type_id()

  // Parse return type
  let result_type = cursor.result_type()
  let return_type_id = parse_type(ctx, result_type)

  // Parse arguments
  let args : Array[@ir.FunctionArg] = []
  let param_cursors = cursor.arguments()
  for param in param_cursors {
    let param_name = param.spelling()
    let param_type = param.cursor_type()
    let param_type_id = parse_type(ctx, param_type)
    args.push(@ir.FunctionArg::new(param_name, param_type_id))
  }

  // Check if function is variadic via its type
  let func_type = cursor.cursor_type()
  let is_variadic = func_type.is_variadic()
  let sig = @ir.FunctionSig::new(return_type_id, args, is_variadic~)
  let sig_ty = @ir.IrType::new(@ir.Function(sig))
  ctx.add_type(sig_type_id, sig_ty)
  let func = @ir.Function::new(name, sig_type_id, is_variadic~)
  let item = @ir.Item::new(
    item_id,
    @ir.Function(func),
    name=Some(name),
    parent=Some(parent),
  )
  ctx.add_item(item)
  item_id
}

///|
/// Parse a typedef declaration.
fn parse_typedef(
  ctx : @ir.BindgenContext,
  cursor : @clang.Cursor,
  parent : @ir.ItemId,
) -> @ir.ItemId {
  let name = cursor.spelling()
  let item_id = ctx.next_item_id()
  let type_id = ctx.next_type_id()

  // Get the underlying type
  let underlying = cursor.typedef_underlying_type()
  let underlying_type_id = parse_type(ctx, underlying)
  let ty = @ir.IrType::new(@ir.Alias(underlying_type_id), name=Some(name))
  ctx.add_type(type_id, ty)
  let item = @ir.Item::new(
    item_id,
    @ir.Type(ty),
    name=Some(name),
    parent=Some(parent),
  )
  ctx.add_item(item)
  item_id
}

///|
/// Parse a variable declaration.
fn parse_var(
  ctx : @ir.BindgenContext,
  cursor : @clang.Cursor,
  parent : @ir.ItemId,
) -> @ir.ItemId {
  let name = cursor.spelling()
  let item_id = ctx.next_item_id()
  let var_type = cursor.cursor_type()
  let type_id = parse_type(ctx, var_type)
  let is_const = var_type.is_const_qualified()
  let variable = @ir.Variable::new(name, type_id, is_const~)
  let item = @ir.Item::new(
    item_id,
    @ir.Var(variable),
    name=Some(name),
    parent=Some(parent),
  )
  ctx.add_item(item)
  item_id
}

///|
/// Parse a clang type to an IR TypeId.
fn parse_type(ctx : @ir.BindgenContext, ty : @clang.Type) -> @ir.TypeId {
  let type_id = ctx.next_type_id()
  let kind = ty.kind()
  let ir_kind : @ir.IrTypeKind = match kind {
    @clang.Void => @ir.Void
    @clang.Bool => @ir.Int(@ir.Bool)
    @clang.Char_U | @clang.Char_S => @ir.Int(@ir.Char)
    @clang.UChar => @ir.Int(@ir.UChar)
    @clang.SChar => @ir.Int(@ir.SChar)
    @clang.UShort => @ir.Int(@ir.UShort)
    @clang.Short => @ir.Int(@ir.Short)
    @clang.UInt => @ir.Int(@ir.UInt)
    @clang.Int => @ir.Int(@ir.Int)
    @clang.ULong => @ir.Int(@ir.ULong)
    @clang.Long => @ir.Int(@ir.Long)
    @clang.ULongLong => @ir.Int(@ir.ULongLong)
    @clang.LongLong => @ir.Int(@ir.LongLong)
    @clang.Float => @ir.Float(@ir.Float)
    @clang.Double => @ir.Float(@ir.Double)
    @clang.LongDouble => @ir.Float(@ir.LongDouble)
    @clang.Pointer => {
      let pointee = ty.pointee_type()
      let pointee_id = parse_type(ctx, pointee)
      @ir.Pointer(pointee_id)
    }
    @clang.ConstantArray => {
      let elem = ty.array_element_type()
      let elem_id = parse_type(ctx, elem)
      let size = ty.array_size()
      @ir.Array(elem_id, Some(size))
    }
    @clang.IncompleteArray => {
      let elem = ty.array_element_type()
      let elem_id = parse_type(ctx, elem)
      @ir.Array(elem_id, None)
    }
    _ => @ir.Opaque
  } // For types we don't handle yet
  let ir_type = @ir.IrType::new(ir_kind, is_const=ty.is_const_qualified())
  ctx.add_type(type_id, ir_type)
  type_id
}
