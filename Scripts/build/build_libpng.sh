#!/usr/bin/env bash

# Scripts/build/build_libpng.sh
#!/usr/bin/env bash

set -euo pipefail

PLATFORM="${1:-ios}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh" "$PLATFORM"

SRC="$SOURCES_DIR/libpng-1.6.43"
BUILD="$SRC/build-$PLATFORM"
LOG="$LOGS_DIR/build_libpng_$PLATFORM.log"

ROOT="$ROOT_DIR/${PLATFORM}_$ARCH" # Root/ios_arm64 | Root/macos_arm64

HOST_TRIPLE="aarch64-apple-ios"
BUILD_TRIPLE="aarch64-apple-darwin"

echo "=================================="   |tee "$LOG"
echo "Building libpng ($PLATFORM)"          |tee -a "$LOG"
echo "=================================="   |tee -a "$LOG"
echo "build in config.log is at:  Sources/libpng-1.6.43/build-ios/config.log" |tee -a "$LOG"

rm -rf "$BUILD"
if [ ! -d "$PREFIX" ]; then
    echo "Removing existing prefix directory: $PREFIX" |tee -a "$LOG"
    rm -rf "$PREFIX"
fi
mkdir -p "$BUILD"

cd "$BUILD"

# Force cross compile mode (CRITICAL FOR iOS)
# Without this, libpng's configure will try to run a test executable, which will fail on iOS and cause the build to break.
export cross_compiling=yes
export ac_cv_func_malloc_0_nonnull=yes
export ac_cv_func_realloc_0_nonnull=yes
export ac_cv_func_memcmp_working=yes
export ac_cv_have_decl_strerror=yes

#ensure zlib visible
export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"

echo "Running configure…" |tee -a "$LOG"
mkdir -p "$BUILD"
cd "$BUILD"

"$SRC/configure" \
  --host="$HOST_TRIPLE" \
  --build="$BUILD_TRIPLE" \
  --prefix="$PREFIX" \
  --enable-static \
  --disable-shared \
  --disable-dependency-tracking \
  CFLAGS="$CFLAGS" \
  CPPFLAGS="$CPPFLAGS" \
  LDFLAGS="$LDFLAGS" \
  >> "$LOG" 2>&1

echo "Running make…"
make -j$(sysctl -n hw.ncpu) >> "$LOG" 2>&1

echo "Running make install…"
make install >> "$LOG" 2>&1

echo "=================================="
echo "libpng SUCCESS ($PLATFORM)"
echo "Installed to $PREFIX"
echo "=========================================" |tee -a "$LOG"
