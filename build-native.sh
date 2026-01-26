#!/bin/bash
set -e

# Clean and build
moon clean
moon build --target native || true

# Manual link with libclang - use the full path to the library
/usr/bin/gcc -o /home/hirohito-fujita/src/moonbit/bindgen.mbt/_build/native/release/build/main/main.exe \
  -I/home/hirohito-fujita/.moon/include -fwrapv -fno-strict-aliasing -O2 \
  /home/hirohito-fujita/.moon/lib/libmoonbitrun.o \
  /home/hirohito-fujita/src/moonbit/bindgen.mbt/_build/native/release/build/main/main.c \
  /home/hirohito-fujita/src/moonbit/bindgen.mbt/_build/native/release/build/runtime.o \
  /usr/lib/llvm-18/lib/libclang.so.1 -lm

echo "Build successful!"
