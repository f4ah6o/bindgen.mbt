///|
/// Raw FFI declarations for libclang.
/// These are low-level bindings that wrap the libclang C API.

// =============================================================================
// Opaque Types - represented as Int64 (pointer) in MoonBit
// =============================================================================

///|
/// Opaque pointer to a clang index - manages the translation units.
pub struct CXIndex(Int64)

///|
/// Opaque pointer to a translation unit - a parsed source file.
pub struct CXTranslationUnit(Int64)

///|
/// A string managed by libclang - represented as pointer.
pub struct CXString(Int64)

///|
/// Opaque diagnostic type.
pub struct CXDiagnostic(Int64)

// =============================================================================
// Value Types (passed by value in C)
// =============================================================================

///|
/// A cursor represents a reference to an element within the AST.
/// Cursors are the primary way to navigate the AST in libclang.
pub(all) struct CXCursor {
  kind : Int // CXCursorKind
  xdata : Int
  // data is 3 pointers - we represent as 3 Int64s for native
  data0 : Int64
  data1 : Int64
  data2 : Int64
} derive(Eq, Show, ToJson)

///|
/// A type in the clang type system.
pub(all) struct CXType {
  kind : Int // CXTypeKind
  data0 : Int64
  data1 : Int64
} derive(Eq, Show, ToJson)

///|
/// Identifies a specific source location within a translation unit.
pub(all) struct CXSourceLocation {
  ptr_data0 : Int64
  ptr_data1 : Int64
  int_data : UInt
} derive(Eq, Show, ToJson)

///|
/// Identifies a half-open character range in the source code.
pub(all) struct CXSourceRange {
  ptr_data0 : Int64
  ptr_data1 : Int64
  begin_int_data : UInt
  end_int_data : UInt
} derive(Eq, Show, ToJson)

// =============================================================================
// CXCursorKind constants
// =============================================================================

///|
/// Unexposed declaration
pub const CXCursor_UnexposedDecl : Int = 1

///|
/// Struct declaration
pub const CXCursor_StructDecl : Int = 2

///|
/// Union declaration
pub const CXCursor_UnionDecl : Int = 3

///|
/// Class declaration (C++)
pub const CXCursor_ClassDecl : Int = 4

///|
/// Enum declaration
pub const CXCursor_EnumDecl : Int = 5

///|
/// Field declaration
pub const CXCursor_FieldDecl : Int = 6

///|
/// Enum constant declaration
pub const CXCursor_EnumConstantDecl : Int = 7

///|
/// Function declaration
pub const CXCursor_FunctionDecl : Int = 8

///|
/// Variable declaration
pub const CXCursor_VarDecl : Int = 9

///|
/// Parameter declaration
pub const CXCursor_ParmDecl : Int = 10

///|
/// Typedef declaration
pub const CXCursor_TypedefDecl : Int = 20

///|
/// C++ method declaration
pub const CXCursor_CXXMethod : Int = 21

///|
/// Namespace (C++)
pub const CXCursor_Namespace : Int = 22

///|
/// C++ constructor
pub const CXCursor_Constructor : Int = 24

///|
/// C++ destructor
pub const CXCursor_Destructor : Int = 25

///|
/// C++ conversion function
pub const CXCursor_ConversionFunction : Int = 26

///|
/// C++ template type parameter
pub const CXCursor_TemplateTypeParameter : Int = 27

///|
/// C++ non-type template parameter
pub const CXCursor_NonTypeTemplateParameter : Int = 28

///|
/// C++ template template parameter
pub const CXCursor_TemplateTemplateParameter : Int = 29

///|
/// C++ function template
pub const CXCursor_FunctionTemplate : Int = 30

///|
/// C++ class template
pub const CXCursor_ClassTemplate : Int = 31

///|
/// C++ class template partial specialization
pub const CXCursor_ClassTemplatePartialSpecialization : Int = 32

///|
/// C++ namespace alias
pub const CXCursor_NamespaceAlias : Int = 33

///|
/// C++ using directive
pub const CXCursor_UsingDirective : Int = 34

///|
/// C++ using declaration
pub const CXCursor_UsingDeclaration : Int = 35

///|
/// C++ type alias declaration
pub const CXCursor_TypeAliasDecl : Int = 36

///|
/// Macro definition
pub const CXCursor_MacroDefinition : Int = 501

///|
/// Macro expansion
pub const CXCursor_MacroExpansion : Int = 502

///|
/// Inclusion directive
pub const CXCursor_InclusionDirective : Int = 503

///|
/// C++ base specifier
pub const CXCursor_CXXBaseSpecifier : Int = 44

///|
/// C++ access specifier
pub const CXCursor_CXXAccessSpecifier : Int = 39

// =============================================================================
// CXTypeKind constants
// =============================================================================

///|
/// Invalid type
pub const CXType_Invalid : Int = 0

///|
/// Unexposed type
pub const CXType_Unexposed : Int = 1

///|
/// void
pub const CXType_Void : Int = 2

///|
/// bool
pub const CXType_Bool : Int = 3

///|
/// char (C type)
pub const CXType_Char_U : Int = 4

///|
/// unsigned char
pub const CXType_UChar : Int = 5

///|
/// char16_t
pub const CXType_Char16 : Int = 6

///|
/// char32_t
pub const CXType_Char32 : Int = 7

///|
/// unsigned short
pub const CXType_UShort : Int = 8

///|
/// unsigned int
pub const CXType_UInt : Int = 9

///|
/// unsigned long
pub const CXType_ULong : Int = 10

///|
/// unsigned long long
pub const CXType_ULongLong : Int = 11

///|
/// __uint128
pub const CXType_UInt128 : Int = 12

///|
/// char (signed)
pub const CXType_Char_S : Int = 13

///|
/// signed char
pub const CXType_SChar : Int = 14

///|
/// wchar_t
pub const CXType_WChar : Int = 15

///|
/// short
pub const CXType_Short : Int = 16

///|
/// int
pub const CXType_Int : Int = 17

///|
/// long
pub const CXType_Long : Int = 18

///|
/// long long
pub const CXType_LongLong : Int = 19

///|
/// __int128
pub const CXType_Int128 : Int = 20

///|
/// float
pub const CXType_Float : Int = 21

///|
/// double
pub const CXType_Double : Int = 22

///|
/// long double
pub const CXType_LongDouble : Int = 23

///|
/// nullptr (C++11)
pub const CXType_NullPtr : Int = 24

///|
/// Pointer type
pub const CXType_Pointer : Int = 101

///|
/// Block pointer (Objective-C)
pub const CXType_BlockPointer : Int = 102

///|
/// L-value reference (C++)
pub const CXType_LValueReference : Int = 103

///|
/// R-value reference (C++)
pub const CXType_RValueReference : Int = 104

///|
/// Record (struct/union/class)
pub const CXType_Record : Int = 105

///|
/// Enum type
pub const CXType_Enum : Int = 106

///|
/// Typedef
pub const CXType_Typedef : Int = 107

///|
/// Function with no prototype
pub const CXType_FunctionNoProto : Int = 110

///|
/// Function with prototype
pub const CXType_FunctionProto : Int = 111

///|
/// Constant-size array
pub const CXType_ConstantArray : Int = 112

///|
/// C++ vector type
pub const CXType_Vector : Int = 113

///|
/// Incomplete array
pub const CXType_IncompleteArray : Int = 114

///|
/// Variable-size array
pub const CXType_VariableArray : Int = 115

///|
/// Dependent-size array
pub const CXType_DependentSizedArray : Int = 116

///|
/// Member pointer (C++)
pub const CXType_MemberPointer : Int = 117

///|
/// Elaborated type
pub const CXType_Elaborated : Int = 119

// =============================================================================
// CXChildVisitResult constants
// =============================================================================

///|
/// Terminates the cursor traversal
pub const CXChildVisit_Break : UInt = 0

///|
/// Continues the cursor traversal with the next sibling
pub const CXChildVisit_Continue : UInt = 1

///|
/// Recursively traverse the children of this cursor
pub const CXChildVisit_Recurse : UInt = 2

// =============================================================================
// TranslationUnit flags
// =============================================================================

///|
/// Skip function bodies
pub const CXTranslationUnit_SkipFunctionBodies : UInt = 0x40

///|
/// Keep going on errors
pub const CXTranslationUnit_KeepGoing : UInt = 0x200

///|
/// Include detailed preprocessing record
pub const CXTranslationUnit_DetailedPreprocessingRecord : UInt = 0x01

// =============================================================================
// Diagnostic display options
// =============================================================================

///|
/// Default diagnostic display options
pub const CXDiagnostic_DisplaySourceLocation : UInt = 0x01

///|
/// Display source ranges
pub const CXDiagnostic_DisplaySourceRanges : UInt = 0x02

///|
/// Display option
pub const CXDiagnostic_DisplayOption : UInt = 0x04

///|
/// Display category name
pub const CXDiagnostic_DisplayCategoryName : UInt = 0x20

// =============================================================================
// FFI Functions - Index Management
// =============================================================================

///|
/// Create a new CXIndex for parsing translation units.
/// excludeDeclarationsFromPCH: if non-zero, exclude declarations from PCH
/// displayDiagnostics: if non-zero, display diagnostics
#borrow(exclude_declarations_from_pch, display_diagnostics)
extern "C" fn libclang_createIndex(
  exclude_declarations_from_pch : Int,
  display_diagnostics : Int,
) -> CXIndex = "clang_createIndex"

///|
/// Dispose of the given CXIndex.
#borrow(index)
extern "C" fn libclang_disposeIndex(index : CXIndex) = "clang_disposeIndex"

// =============================================================================
// FFI Functions - Translation Unit Management
// =============================================================================

///|
/// Parse a source file to create a translation unit.
/// Returns null on failure.
#borrow(index, source_filename, command_line_args, num_command_line_args, unsaved_files, num_unsaved_files, options)
extern "C" fn libclang_parseTranslationUnit(
  index : CXIndex,
  source_filename : Bytes,
  command_line_args : FixedArray[Bytes],
  num_command_line_args : Int,
  unsaved_files : Int64, // nullptr - we don't use unsaved files
  num_unsaved_files : UInt,
  options : UInt,
) -> CXTranslationUnit = "clang_parseTranslationUnit"

///|
/// Dispose of the given translation unit.
#borrow(tu)
extern "C" fn libclang_disposeTranslationUnit(tu : CXTranslationUnit) = "clang_disposeTranslationUnit"

///|
/// Get the cursor representing the translation unit.
#borrow(tu)
extern "C" fn libclang_getTranslationUnitCursor(
  tu : CXTranslationUnit,
) -> CXCursor = "clang_getTranslationUnitCursor"

// =============================================================================
// FFI Functions - Cursor Operations
// =============================================================================

///|
/// Get the kind of the given cursor.
#borrow(cursor)
extern "C" fn libclang_getCursorKind(cursor : CXCursor) -> Int = "clang_getCursorKind"

///|
/// Determine if the cursor is null.
#borrow(cursor)
extern "C" fn libclang_Cursor_isNull(cursor : CXCursor) -> Int = "clang_Cursor_isNull"

///|
/// Determine if two cursors are equal.
#borrow(a, b)
extern "C" fn libclang_equalCursors(a : CXCursor, b : CXCursor) -> UInt = "clang_equalCursors"

///|
/// Get a hash value for a cursor.
#borrow(cursor)
extern "C" fn libclang_hashCursor(cursor : CXCursor) -> UInt = "clang_hashCursor"

///|
/// Get the spelling of the cursor (its name).
#borrow(cursor)
extern "C" fn libclang_getCursorSpelling(cursor : CXCursor) -> CXString = "clang_getCursorSpelling"

///|
/// Get the display name of the cursor.
#borrow(cursor)
extern "C" fn libclang_getCursorDisplayName(cursor : CXCursor) -> CXString = "clang_getCursorDisplayName"

///|
/// Get the type of the cursor.
#borrow(cursor)
extern "C" fn libclang_getCursorType(cursor : CXCursor) -> CXType = "clang_getCursorType"

///|
/// Get the result type of a function or method cursor.
#borrow(cursor)
extern "C" fn libclang_getCursorResultType(cursor : CXCursor) -> CXType = "clang_getCursorResultType"

///|
/// Get the semantic parent of a cursor.
#borrow(cursor)
extern "C" fn libclang_getCursorSemanticParent(cursor : CXCursor) -> CXCursor = "clang_getCursorSemanticParent"

///|
/// Get the lexical parent of a cursor.
#borrow(cursor)
extern "C" fn libclang_getCursorLexicalParent(cursor : CXCursor) -> CXCursor = "clang_getCursorLexicalParent"

///|
/// Get the location of the cursor.
#borrow(cursor)
extern "C" fn libclang_getCursorLocation(cursor : CXCursor) -> CXSourceLocation = "clang_getCursorLocation"

///|
/// Get the extent (source range) of the cursor.
#borrow(cursor)
extern "C" fn libclang_getCursorExtent(cursor : CXCursor) -> CXSourceRange = "clang_getCursorExtent"

///|
/// Get the canonical cursor for the given cursor.
#borrow(cursor)
extern "C" fn libclang_getCanonicalCursor(cursor : CXCursor) -> CXCursor = "clang_getCanonicalCursor"

///|
/// Get the cursor that represents the definition of the entity.
#borrow(cursor)
extern "C" fn libclang_getCursorDefinition(cursor : CXCursor) -> CXCursor = "clang_getCursorDefinition"

///|
/// Determine whether the cursor is a definition.
#borrow(cursor)
extern "C" fn libclang_isCursorDefinition(cursor : CXCursor) -> UInt = "clang_isCursorDefinition"

///|
/// Get number of arguments for a function cursor.
#borrow(cursor)
extern "C" fn libclang_Cursor_getNumArguments(cursor : CXCursor) -> Int = "clang_Cursor_getNumArguments"

///|
/// Get the argument cursor at the given index.
#borrow(cursor, i)
extern "C" fn libclang_Cursor_getArgument(
  cursor : CXCursor,
  i : UInt,
) -> CXCursor = "clang_Cursor_getArgument"

///|
/// Get the comment associated with the cursor.
#borrow(cursor)
extern "C" fn libclang_Cursor_getRawCommentText(cursor : CXCursor) -> CXString = "clang_Cursor_getRawCommentText"

///|
/// Get the brief comment associated with the cursor.
#borrow(cursor)
extern "C" fn libclang_Cursor_getBriefCommentText(
  cursor : CXCursor,
) -> CXString = "clang_Cursor_getBriefCommentText"

///|
/// For enum constant declarations, get the value.
#borrow(cursor)
extern "C" fn libclang_getEnumConstantDeclValue(cursor : CXCursor) -> Int64 = "clang_getEnumConstantDeclValue"

///|
/// For enum constant declarations, get the unsigned value.
#borrow(cursor)
extern "C" fn libclang_getEnumConstantDeclUnsignedValue(
  cursor : CXCursor,
) -> UInt64 = "clang_getEnumConstantDeclUnsignedValue"

///|
/// Get the integer type of an enum declaration.
#borrow(cursor)
extern "C" fn libclang_getEnumDeclIntegerType(cursor : CXCursor) -> CXType = "clang_getEnumDeclIntegerType"

///|
/// Get the bit width of a bit-field declaration.
#borrow(cursor)
extern "C" fn libclang_getFieldDeclBitWidth(cursor : CXCursor) -> Int = "clang_getFieldDeclBitWidth"

///|
/// Get the underlying type of a typedef.
#borrow(cursor)
extern "C" fn libclang_getTypedefDeclUnderlyingType(
  cursor : CXCursor,
) -> CXType = "clang_getTypedefDeclUnderlyingType"

///|
/// Determine whether the cursor represents an anonymous struct or union.
#borrow(cursor)
extern "C" fn libclang_Cursor_isAnonymous(cursor : CXCursor) -> UInt = "clang_Cursor_isAnonymous"

///|
/// Determine whether the cursor represents an anonymous record (unnamed field).
#borrow(cursor)
extern "C" fn libclang_Cursor_isAnonymousRecordDecl(cursor : CXCursor) -> UInt = "clang_Cursor_isAnonymousRecordDecl"

// =============================================================================
// FFI Functions - Type Operations
// =============================================================================

///|
/// Get the spelling of a type.
#borrow(ty)
extern "C" fn libclang_getTypeSpelling(ty : CXType) -> CXString = "clang_getTypeSpelling"

///|
/// Get the canonical type for a type.
#borrow(ty)
extern "C" fn libclang_getCanonicalType(ty : CXType) -> CXType = "clang_getCanonicalType"

///|
/// Determine whether a type is const-qualified.
#borrow(ty)
extern "C" fn libclang_isConstQualifiedType(ty : CXType) -> UInt = "clang_isConstQualifiedType"

///|
/// Determine whether a type is volatile-qualified.
#borrow(ty)
extern "C" fn libclang_isVolatileQualifiedType(ty : CXType) -> UInt = "clang_isVolatileQualifiedType"

///|
/// Get the pointee type of a pointer type.
#borrow(ty)
extern "C" fn libclang_getPointeeType(ty : CXType) -> CXType = "clang_getPointeeType"

///|
/// Get the type referred to by a typedef.
#borrow(ty)
extern "C" fn libclang_getTypedefName(ty : CXType) -> CXString = "clang_getTypedefName"

///|
/// Get the declaration cursor for a type.
#borrow(ty)
extern "C" fn libclang_getTypeDeclaration(ty : CXType) -> CXCursor = "clang_getTypeDeclaration"

///|
/// Get the size of a type in bytes.
#borrow(ty)
extern "C" fn libclang_Type_getSizeOf(ty : CXType) -> Int64 = "clang_Type_getSizeOf"

///|
/// Get the alignment of a type in bytes.
#borrow(ty)
extern "C" fn libclang_Type_getAlignOf(ty : CXType) -> Int64 = "clang_Type_getAlignOf"

///|
/// Get the offset of a field in bits.
#borrow(ty, field_name)
extern "C" fn libclang_Type_getOffsetOf(
  ty : CXType,
  field_name : Bytes,
) -> Int64 = "clang_Type_getOffsetOf"

///|
/// Get the element type of an array, complex, or vector type.
#borrow(ty)
extern "C" fn libclang_getArrayElementType(ty : CXType) -> CXType = "clang_getArrayElementType"

///|
/// Get the number of elements in an array.
#borrow(ty)
extern "C" fn libclang_getArraySize(ty : CXType) -> Int64 = "clang_getArraySize"

///|
/// Get the number of elements in a vector type.
#borrow(ty)
extern "C" fn libclang_getNumElements(ty : CXType) -> Int64 = "clang_getNumElements"

///|
/// Get the return type of a function type.
#borrow(ty)
extern "C" fn libclang_getResultType(ty : CXType) -> CXType = "clang_getResultType"

///|
/// Get the number of arguments for a function type.
#borrow(ty)
extern "C" fn libclang_getNumArgTypes(ty : CXType) -> Int = "clang_getNumArgTypes"

///|
/// Get the argument type at the given index.
#borrow(ty, i)
extern "C" fn libclang_getArgType(ty : CXType, i : UInt) -> CXType = "clang_getArgType"

///|
/// Determine if a function type is variadic.
#borrow(ty)
extern "C" fn libclang_isFunctionTypeVariadic(ty : CXType) -> UInt = "clang_isFunctionTypeVariadic"

///|
/// Get the named type of an elaborated type.
#borrow(ty)
extern "C" fn libclang_Type_getNamedType(ty : CXType) -> CXType = "clang_Type_getNamedType"

///|
/// Determine if two types are equal.
#borrow(a, b)
extern "C" fn libclang_equalTypes(a : CXType, b : CXType) -> UInt = "clang_equalTypes"

// =============================================================================
// FFI Functions - String Operations
// =============================================================================

///|
/// Get the C string from a CXString.
#borrow(string)
extern "C" fn libclang_getCString(string : CXString) -> Int64 = "clang_getCString"

///|
/// Dispose of a CXString.
#borrow(string)
extern "C" fn libclang_disposeString(string : CXString) = "clang_disposeString"

// =============================================================================
// FFI Functions - Source Location
// =============================================================================

///|
/// Get the file, line, column from a source location.
#borrow(location, filename, line, column)
extern "C" fn libclang_getPresumedLocation(
  location : CXSourceLocation,
  filename : FixedArray[CXString], // out parameter
  line : FixedArray[UInt], // out parameter
  column : FixedArray[UInt], // out parameter
) = "clang_getPresumedLocation"

///|
/// Determine if a source location is in a system header.
#borrow(location)
extern "C" fn libclang_Location_isInSystemHeader(
  location : CXSourceLocation,
) -> Int = "clang_Location_isInSystemHeader"

// =============================================================================
// FFI Functions - Traversal
// =============================================================================

///|
/// Visit the children of a cursor.
/// This is wrapped with a MoonBit-friendly interface in cursor.mbt.
#borrow(parent, visitor, client_data)
extern "C" fn libclang_visitChildren(
  parent : CXCursor,
  visitor : (CXCursor, CXCursor) -> UInt,
  client_data : Int64, // unused in our wrapper
) -> UInt = "clang_visitChildren"

// =============================================================================
// Diagnostics
// =============================================================================

///|
/// Get the number of diagnostics for a translation unit.
#borrow(tu)
extern "C" fn libclang_getNumDiagnostics(tu : CXTranslationUnit) -> UInt = "clang_getNumDiagnostics"

///|
/// Get a diagnostic at the given index.
#borrow(tu, index)
extern "C" fn libclang_getDiagnostic(
  tu : CXTranslationUnit,
  index : UInt,
) -> CXDiagnostic = "clang_getDiagnostic"

///|
/// Dispose of a diagnostic.
#borrow(diag)
extern "C" fn libclang_disposeDiagnostic(diag : CXDiagnostic) = "clang_disposeDiagnostic"

///|
/// Format a diagnostic for display.
#borrow(diag, options)
extern "C" fn libclang_formatDiagnostic(
  diag : CXDiagnostic,
  options : UInt,
) -> CXString = "clang_formatDiagnostic"
