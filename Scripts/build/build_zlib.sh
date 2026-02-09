#!/usr/bin/env bash
set -euo pipefail

# build_zlib.sh — robust iOS/macOS arm64 build
# zlib does NOT support --host/--build; cross-compile via flags

# load canonical env
PLATFORM="${1:-ios}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh" "$PLATFORM"

SRC="$SOURCES_DIR/zlib-1.3.1"
BUILD="$SRC/build-$PLATFORM"
LOG="$LOGS_DIR/build_zlib_$PLATFORM.log"

echo "Logs: $LOG"
mkdir -p "$BUILD"
cd "$BUILD"

echo "========================================" | tee "$LOG"
echo "Building zlib ($PLATFORM)" | tee -a "$LOG"
echo "Source: $SRC" | tee -a "$LOG"
echo "Build dir: $BUILD" | tee -a "$LOG"
echo "Prefix: $PREFIX" | tee -a "$LOG"
echo "CFLAGS: $CFLAGS" | tee -a "$LOG"
echo "CPPFLAGS: $CPPFLAGS" | tee -a "$LOG"
echo "LDFLAGS: $LDFLAGS" | tee -a "$LOG"
echo "========================================" | tee -a "$LOG"

# configure: only prefix and static
echo "Configuring zlib..." | tee -a "$LOG"
"$SRC/configure" \
    --prefix="$PREFIX" \
    --static \
    >> "$LOG" 2>&1

echo "Compiling zlib..." | tee -a "$LOG"
make -j$(sysctl -n hw.ncpu) >> "$LOG" 2>&1

echo "Installing zlib..." | tee -a "$LOG"
make install >> "$LOG" 2>&1

echo "========================================" | tee -a "$LOG"
echo "zlib ($PLATFORM) SUCCESS!" | tee -a "$LOG"
echo "Installed to: $PREFIX" | tee -a "$LOG"
echo "Check $LOG for full logs" | tee -a "$LOG"
echo "========================================" | tee -a "$LOG"

