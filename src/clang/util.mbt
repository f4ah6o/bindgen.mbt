///|
/// Utility functions for string handling between MoonBit and C.

///|
/// Helper: copy bytes using C memcpy
#borrow(dest, src, n)
extern "C" fn native_memcpy_bytes(dest : Bytes, src : Bytes, n : Int) -> Int64 = "memcpy"

///|
/// Convert a MoonBit String to a null-terminated C string (Bytes).
pub fn string_to_cstring(s : String) -> Bytes {
  let utf8 = @utf8.encode(s)
  // Append null terminator - use length + 1 to include null byte
  let len = utf8.length()
  let result = Bytes::make(len + 1, b'\x00')
  // Copy utf8 bytes to result using memcpy
  if len > 0 {
    native_memcpy_bytes(result, utf8, len) |> ignore
  }
  result
}

///|
/// Convert a CXString to a MoonBit String.
pub fn cxstring_to_string(cxstring : CXString) -> String {
  let cstr_ptr = libclang_getCString(cxstring)
  if cstr_ptr == 0L {
    return ""
  }
  // Read bytes from the C string until null terminator
  read_cstring_from_ptr(cstr_ptr)
}

///|
/// Read a null-terminated C string from a pointer.
/// This is a native FFI helper.
extern "C" fn native_strlen(ptr : Int64) -> Int = "strlen"

///|
#borrow(dest, src, n)
extern "C" fn native_memcpy(dest : Bytes, src : Int64, n : Int) -> Int64 = "memcpy"

///|
/// Read a C string from a pointer into a MoonBit String.
fn read_cstring_from_ptr(ptr : Int64) -> String {
  if ptr == 0L {
    return ""
  }
  let len = native_strlen(ptr)
  if len == 0 {
    return ""
  }
  let bytes = Bytes::make(len, b'\x00')
  native_memcpy(bytes, ptr, len) |> ignore
  // Use try-catch for error handling
  @utf8.decode(bytes) catch {
    _ => ""
  }
}
