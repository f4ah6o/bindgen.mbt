///|
/// High-level wrapper around CXCursor.
/// Cursors are the primary way to navigate the AST in libclang.
pub(all) struct Cursor {
  raw : CXCursor
}

///|
/// Create a Cursor from a raw CXCursor.
pub fn Cursor::from_raw(raw : CXCursor) -> Cursor {
  { raw, }
}

///|
/// Get the raw CXCursor.
pub fn Cursor::to_raw(self : Cursor) -> CXCursor {
  self.raw
}

///|
/// Check if the cursor is null.
pub fn Cursor::is_null(self : Cursor) -> Bool {
  libclang_Cursor_isNull(self.raw) != 0
}

///|
/// Get the kind of this cursor.
pub fn Cursor::kind(self : Cursor) -> CursorKind {
  CursorKind::from_raw(libclang_getCursorKind(self.raw))
}

///|
/// Get the spelling (name) of this cursor.
pub fn Cursor::spelling(self : Cursor) -> String {
  let cxstring = libclang_getCursorSpelling(self.raw)
  let result = cxstring_to_string(cxstring)
  libclang_disposeString(cxstring)
  result
}

///|
/// Get the display name of this cursor.
pub fn Cursor::display_name(self : Cursor) -> String {
  let cxstring = libclang_getCursorDisplayName(self.raw)
  let result = cxstring_to_string(cxstring)
  libclang_disposeString(cxstring)
  result
}

///|
/// Get the type of this cursor.
pub fn Cursor::cursor_type(self : Cursor) -> Type {
  let raw = libclang_getCursorType(self.raw)
  Type::from_raw(raw)
}

///|
/// Get the result type of a function or method cursor.
pub fn Cursor::result_type(self : Cursor) -> Type {
  let raw = libclang_getCursorResultType(self.raw)
  Type::from_raw(raw)
}

///|
/// Get the semantic parent of this cursor.
pub fn Cursor::semantic_parent(self : Cursor) -> Cursor {
  let raw = libclang_getCursorSemanticParent(self.raw)
  Cursor::from_raw(raw)
}

///|
/// Get the lexical parent of this cursor.
pub fn Cursor::lexical_parent(self : Cursor) -> Cursor {
  let raw = libclang_getCursorLexicalParent(self.raw)
  Cursor::from_raw(raw)
}

///|
/// Get the location of this cursor.
pub fn Cursor::location(self : Cursor) -> SourceLocation {
  let raw = libclang_getCursorLocation(self.raw)
  SourceLocation::from_raw(raw)
}

///|
/// Get the extent (source range) of this cursor.
pub fn Cursor::extent(self : Cursor) -> SourceRange {
  let raw = libclang_getCursorExtent(self.raw)
  { raw, }
}

///|
/// Get the canonical cursor for this cursor.
pub fn Cursor::canonical(self : Cursor) -> Cursor {
  let raw = libclang_getCanonicalCursor(self.raw)
  Cursor::from_raw(raw)
}

///|
/// Get the cursor that represents the definition of the entity.
pub fn Cursor::definition(self : Cursor) -> Cursor {
  let raw = libclang_getCursorDefinition(self.raw)
  Cursor::from_raw(raw)
}

///|
/// Determine whether this cursor is a definition.
pub fn Cursor::is_definition(self : Cursor) -> Bool {
  libclang_isCursorDefinition(self.raw) != 0
}

///|
/// Get the number of arguments for a function cursor.
pub fn Cursor::num_arguments(self : Cursor) -> Int {
  libclang_Cursor_getNumArguments(self.raw)
}

///|
/// Get the argument cursor at the given index.
pub fn Cursor::argument(self : Cursor, i : Int) -> Cursor {
  let raw = libclang_Cursor_getArgument(self.raw, i.reinterpret_as_uint())
  Cursor::from_raw(raw)
}

///|
/// Get all argument cursors for a function.
pub fn Cursor::arguments(self : Cursor) -> Array[Cursor] {
  let n = self.num_arguments()
  let result : Array[Cursor] = []
  for i = 0; i < n; i = i + 1 {
    result.push(self.argument(i))
  }
  result
}

///|
/// Get the raw comment text associated with this cursor.
pub fn Cursor::raw_comment(self : Cursor) -> String {
  let cxstring = libclang_Cursor_getRawCommentText(self.raw)
  let result = cxstring_to_string(cxstring)
  libclang_disposeString(cxstring)
  result
}

///|
/// Get the brief comment text associated with this cursor.
pub fn Cursor::brief_comment(self : Cursor) -> String {
  let cxstring = libclang_Cursor_getBriefCommentText(self.raw)
  let result = cxstring_to_string(cxstring)
  libclang_disposeString(cxstring)
  result
}

///|
/// For enum constant declarations, get the signed value.
pub fn Cursor::enum_constant_value(self : Cursor) -> Int64 {
  libclang_getEnumConstantDeclValue(self.raw)
}

///|
/// For enum constant declarations, get the unsigned value.
pub fn Cursor::enum_constant_unsigned_value(self : Cursor) -> UInt64 {
  libclang_getEnumConstantDeclUnsignedValue(self.raw)
}

///|
/// Get the integer type of an enum declaration.
pub fn Cursor::enum_integer_type(self : Cursor) -> Type {
  let raw = libclang_getEnumDeclIntegerType(self.raw)
  Type::from_raw(raw)
}

///|
/// Get the bit width of a bit-field declaration (-1 if not a bit-field).
pub fn Cursor::bitfield_width(self : Cursor) -> Int {
  libclang_getFieldDeclBitWidth(self.raw)
}

///|
/// Get the underlying type of a typedef.
pub fn Cursor::typedef_underlying_type(self : Cursor) -> Type {
  let raw = libclang_getTypedefDeclUnderlyingType(self.raw)
  Type::from_raw(raw)
}

///|
/// Determine whether this cursor represents an anonymous struct or union.
pub fn Cursor::is_anonymous(self : Cursor) -> Bool {
  libclang_Cursor_isAnonymous(self.raw) != 0
}

///|
/// Determine whether this cursor represents an anonymous record declaration.
pub fn Cursor::is_anonymous_record_decl(self : Cursor) -> Bool {
  libclang_Cursor_isAnonymousRecordDecl(self.raw) != 0
}

///|
/// Visit the children of this cursor.
/// The visitor callback receives (child, parent) and returns a VisitResult.
pub fn Cursor::visit_children(
  self : Cursor,
  visitor : (Cursor, Cursor) -> VisitResult,
) -> Bool {
  // Create a wrapper that converts between raw and high-level types
  let raw_visitor : (CXCursor, CXCursor) -> UInt = fn(child, parent) {
    let result = visitor(Cursor::from_raw(child), Cursor::from_raw(parent))
    result.to_raw()
  }
  let result = libclang_visitChildren(self.raw, raw_visitor, 0L)
  result == 0
}

///|
/// Collect all children of this cursor into an array.
pub fn Cursor::children(self : Cursor) -> Array[Cursor] {
  let result : Array[Cursor] = []
  self.visit_children(fn(child, _parent) {
    result.push(child)
    VisitResult::Continue
  })
  |> ignore
  result
}

///|
/// Hash function for cursor.
pub fn Cursor::hash_value(self : Cursor) -> UInt {
  libclang_hashCursor(self.raw)
}

///|
/// Check equality between cursors.
pub fn Cursor::equals(self : Cursor, other : Cursor) -> Bool {
  libclang_equalCursors(self.raw, other.raw) != 0
}

///|
impl Eq for Cursor with equal(self, other) {
  self.equals(other)
}

///|
impl Show for Cursor with output(self, logger) {
  let kind = self.kind()
  let spelling = self.spelling()
  logger.write_string("Cursor { kind: ")
  kind.output(logger)
  logger.write_string(", spelling: \"")
  logger.write_string(spelling)
  logger.write_string("\" }")
}

///|
impl Hash for Cursor with hash(self) {
  self.hash_value().reinterpret_as_int()
}

///|
impl Hash for Cursor with hash_combine(self, hasher) {
  hasher.combine_int(self.hash_value().reinterpret_as_int())
}

// =============================================================================
// CursorKind enum
// =============================================================================

///|
/// High-level enum representing cursor kinds.
pub(all) enum CursorKind {
  UnexposedDecl
  StructDecl
  UnionDecl
  ClassDecl
  EnumDecl
  FieldDecl
  EnumConstantDecl
  FunctionDecl
  VarDecl
  ParmDecl
  TypedefDecl
  CXXMethod
  Namespace
  Constructor
  Destructor
  ConversionFunction
  TemplateTypeParameter
  NonTypeTemplateParameter
  TemplateTemplateParameter
  FunctionTemplate
  ClassTemplate
  ClassTemplatePartialSpecialization
  NamespaceAlias
  UsingDirective
  UsingDeclaration
  TypeAliasDecl
  CXXBaseSpecifier
  CXXAccessSpecifier
  MacroDefinition
  MacroExpansion
  InclusionDirective
  Other(Int)
} derive(Eq, Show, ToJson)

///|
/// Convert from raw cursor kind integer.
pub fn CursorKind::from_raw(kind : Int) -> CursorKind {
  match kind {
    1 => UnexposedDecl
    2 => StructDecl
    3 => UnionDecl
    4 => ClassDecl
    5 => EnumDecl
    6 => FieldDecl
    7 => EnumConstantDecl
    8 => FunctionDecl
    9 => VarDecl
    10 => ParmDecl
    20 => TypedefDecl
    21 => CXXMethod
    22 => Namespace
    24 => Constructor
    25 => Destructor
    26 => ConversionFunction
    27 => TemplateTypeParameter
    28 => NonTypeTemplateParameter
    29 => TemplateTemplateParameter
    30 => FunctionTemplate
    31 => ClassTemplate
    32 => ClassTemplatePartialSpecialization
    33 => NamespaceAlias
    34 => UsingDirective
    35 => UsingDeclaration
    36 => TypeAliasDecl
    44 => CXXBaseSpecifier
    39 => CXXAccessSpecifier
    501 => MacroDefinition
    502 => MacroExpansion
    503 => InclusionDirective
    _ => Other(kind)
  }
}

///|
/// Convert to raw cursor kind integer.
pub fn CursorKind::to_raw(self : CursorKind) -> Int {
  match self {
    UnexposedDecl => 1
    StructDecl => 2
    UnionDecl => 3
    ClassDecl => 4
    EnumDecl => 5
    FieldDecl => 6
    EnumConstantDecl => 7
    FunctionDecl => 8
    VarDecl => 9
    ParmDecl => 10
    TypedefDecl => 20
    CXXMethod => 21
    Namespace => 22
    Constructor => 24
    Destructor => 25
    ConversionFunction => 26
    TemplateTypeParameter => 27
    NonTypeTemplateParameter => 28
    TemplateTemplateParameter => 29
    FunctionTemplate => 30
    ClassTemplate => 31
    ClassTemplatePartialSpecialization => 32
    NamespaceAlias => 33
    UsingDirective => 34
    UsingDeclaration => 35
    TypeAliasDecl => 36
    CXXBaseSpecifier => 44
    CXXAccessSpecifier => 39
    MacroDefinition => 501
    MacroExpansion => 502
    InclusionDirective => 503
    Other(k) => k
  }
}

// =============================================================================
// VisitResult enum
// =============================================================================

///|
/// Result returned from a cursor visitor callback.
pub(all) enum VisitResult {
  /// Terminates the cursor traversal
  Break
  /// Continues with the next sibling
  Continue
  /// Recursively traverse children
  Recurse
} derive(Eq, Show)

///|
/// Convert to raw integer.
pub fn VisitResult::to_raw(self : VisitResult) -> UInt {
  match self {
    Break => CXChildVisit_Break
    Continue => CXChildVisit_Continue
    Recurse => CXChildVisit_Recurse
  }
}
