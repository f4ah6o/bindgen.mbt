///|
/// Main entry point for bindgen.mbt CLI.
fn main {
  let args = get_args()
  if args.length() < 2 {
    print_usage()
    return
  }

  // Parse command line arguments
  let mut input_file : String? = None
  let mut output_file : String? = None
  let clang_args : Array[String] = []
  let mut i = 1 // Skip program name
  while i < args.length() {
    let arg = args[i]
    if arg == "-h" || arg == "--help" {
      print_usage()
      return
    } else if arg == "-o" || arg == "--output" {
      i = i + 1
      if i < args.length() {
        output_file = Some(args[i])
      } else {
        println("Error: -o requires an argument")
        return
      }
    } else if arg == "-I" {
      i = i + 1
      if i < args.length() {
        clang_args.push("-I")
        clang_args.push(args[i])
      } else {
        println("Error: -I requires an argument")
        return
      }
    } else if arg.has_prefix("-I") {
      clang_args.push(arg)
    } else if arg.has_prefix("-D") {
      clang_args.push(arg)
    } else if arg.has_prefix("-") {
      // Pass through to clang
      clang_args.push(arg)
    } else {
      // Input file
      input_file = Some(arg)
    }
    i = i + 1
  }

  // Validate input
  guard input_file is Some(input) else {
    println("Error: No input header file specified")
    print_usage()
    return
  }

  // Parse the header
  println("Parsing: " + input)
  let ctx = @parse.parse_header(input, clang_args) catch {
    @parse.ParseError(msg) => {
      println("Parse error: " + msg)
      return
    }
  }
  println("Parsed \{ctx.item_count()} items, \{ctx.type_count()} types")

  // Generate bindings
  let config = @codegen.CodegenConfig::default()
  let output = @codegen.generate(ctx, config)

  // Write output
  match output_file {
    Some(path) => {
      // TODO: Write to file
      println("Writing to: " + path)
      println(output)
    }
    None => println(output)
  }
}

///|
/// Print usage information.
fn print_usage() -> Unit {
  println("bindgen.mbt - MoonBit FFI binding generator")
  println("")
  println("Usage: bindgen.mbt [options] <header.h>")
  println("")
  println("Options:")
  println("  -h, --help       Show this help message")
  println("  -o, --output     Output file (default: stdout)")
  println("  -I <path>        Add include path")
  println("  -D <macro>       Define a preprocessor macro")
  println("")
  println("Example:")
  println("  bindgen.mbt -o bindings.mbt mylib.h")
}

///|
/// Get command line arguments.
/// For now, returns a placeholder - actual implementation depends on platform.
fn get_args() -> Array[String] {
  // TODO: Implement actual argument retrieval via FFI
  // For testing, return a dummy array
  []
}
