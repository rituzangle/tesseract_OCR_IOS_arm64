#!/usr/bin/env bash
set -euo pipefail
# Scripts/build/build_libtiff.sh
# Build libtiff for iOS and macOS
# Usage:
# executed out of build_all.sh
# bash Scripts/build/build_libtiff.sh
# fully aligned with your current env.sh, cross-compile safe, and avoids all historic Apple/iOS pitfalls.

########################################
# Platform selection
########################################

PLATFORM="${1:-ios}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh" "$PLATFORM"

########################################
# Paths
########################################

SRC="$SOURCES_DIR/tiff-4.6.0"
BUILD="$SRC/$BUILD_DIR_SUFFIX"
LOG="$LOGS_DIR/build_libtiff_$PLATFORM.log"

mkdir -p "$BUILD"
rm -rf "$BUILD"/*
cd "$BUILD"

########################################
# Header
########################################

echo "==================================" | tee "$LOG"
echo "Building libtiff ($PLATFORM)" | tee -a "$LOG"
echo "Source: $SRC" | tee -a "$LOG"
echo "Build:  $BUILD" | tee -a "$LOG"
echo "Prefix: $PREFIX" | tee -a "$LOG"
echo "==================================" | tee -a "$LOG"

########################################
# Configure
########################################

echo "Running configure..." | tee -a "$LOG"

"$SRC/configure" \
  --build="$BUILD_TRIPLE" \
  --host="$HOST_TRIPLE" \
  --prefix="$PREFIX" \
  --enable-static \
  --disable-shared \
  --disable-tools \
  --disable-tests \
  --disable-contrib \
  --disable-docs \
  --without-x \
  >> "$LOG" 2>&1

########################################
# Build
########################################

echo "Building..." | tee -a "$LOG"

make -j$(sysctl -n hw.ncpu) >> "$LOG" 2>&1

########################################
# Install
########################################

echo "Installing..." | tee -a "$LOG"

make install >> "$LOG" 2>&1

########################################
# Success
########################################

echo "" | tee -a "$LOG"
echo "libtiff SUCCESS ($PLATFORM)" | tee -a "$LOG"
echo "Installed to $PREFIX"
echo "==================================" | tee -a "$LOG"

# Why these flags matter

# These prevent macOS-only components from breaking iOS builds:
# --disable-tools
# --disable-tests
# --disable-contrib
# --without-x

# They ensure:

# • static library only
# • no host execution required
# • clean cross-compile
