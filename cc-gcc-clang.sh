#!/bin/bash
# Wrapper script for gcc to link libclang
# This wrapper is used by MoonBit build system
exec /usr/bin/gcc "$@" -L/usr/lib/llvm-18/lib -lclang
