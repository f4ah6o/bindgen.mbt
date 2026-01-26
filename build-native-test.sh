#!/bin/bash
set -e

# Create a wrapper for tcc that uses gcc
mkdir -p /tmp/moonbit-wrapper
cat > /tmp/moonbit-wrapper/tcc << 'TCC_EOF'
#!/bin/bash
# tcc wrapper that uses gcc with libclang
exec /usr/bin/gcc "$@" -L/usr/lib/llvm-18/lib /usr/lib/llvm-18/lib/libclang.so.1
TCC_EOF
chmod +x /tmp/moonbit-wrapper/tcc

# Add wrapper to PATH
export PATH="/tmp/moonbit-wrapper:$PATH"

echo "Using tcc wrapper: $(which tcc)"

# Clean and build tests
moon clean
moon test --target native 2>&1
