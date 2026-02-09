#!/usr/bin/env bash

# Scripts/build/build_libjpeg.sh
# Builds libjpeg-turbo for iOS and macOS correctly
# Prevents Catalyst contamination
# Fully debug-safe and deterministic

set -euo pipefail

########################################
# Platform
########################################
PLATFORM="${1:-ios}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh" "$PLATFORM"

########################################
# Paths
########################################

SRC="$SOURCES_DIR/libjpeg-turbo-3.0.1"
BUILD="$SRC/$BUILD_DIR_SUFFIX"
LOG="$LOGS_DIR/build_libjpeg_$PLATFORM.log"

mkdir -p "$BUILD"
rm -rf "$BUILD"/*
cd "$BUILD"

########################################
# Header
########################################

echo "==================================" | tee "$LOG"
echo "Building libjpeg-turbo ($PLATFORM)" | tee -a "$LOG"
echo "Source: $SRC" | tee -a "$LOG"
echo "Build:  $BUILD" | tee -a "$LOG"
echo "Prefix: $PREFIX" | tee -a "$LOG"
echo "SDK:    $SDK_PATH" | tee -a "$LOG"
echo "==================================" | tee -a "$LOG"

echo " Setting Platform-specific CMake config and flags" | tee -a "$LOG"
echo "----------------------------------" | tee -a "$LOG"
if [[ "$PLATFORM" == "ios" ]]; then

    CMAKE_SYSTEM_NAME="iOS"
    DEPLOYMENT_TARGET="$MIN_IOS"

elif [[ "$PLATFORM" == "macos" ]]; then

    CMAKE_SYSTEM_NAME="Darwin"
    DEPLOYMENT_TARGET="$MIN_MACOS"

else
    echo "Unknown platform: $PLATFORM" | tee -a "$LOG"
    exit 1
fi

########################################
# Configure
########################################

echo "Configuring CMake..." | tee -a "$LOG"

cmake "$SRC" \
  -DCMAKE_SYSTEM_NAME="$CMAKE_SYSTEM_NAME" \
  -DCMAKE_SYSTEM_PROCESSOR="$ARCH" \
  -DCMAKE_OSX_ARCHITECTURES="$ARCH" \
  -DCMAKE_OSX_SYSROOT="$SDK_PATH" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
  -DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DENABLE_SHARED=OFF \
  -DENABLE_STATIC=ON \
  -DWITH_SIMD=OFF \
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
# Verify
########################################

if [ -f "$PREFIX/lib/libjpeg.a" ]; then

    echo "" | tee -a "$LOG"
    echo "libjpeg-turbo SUCCESS ($PLATFORM)" | tee -a "$LOG"
    echo "Installed to $PREFIX" | tee -a "$LOG"

else

    echo "" | tee -a "$LOG"
    echo "libjpeg-turbo FAILED ($PLATFORM)" | tee -a "$LOG"
    exit 1

fi

########################################
# Architecture verification (critical)
########################################

echo "" | tee -a "$LOG"
echo "Verifying architecture..." | tee -a "$LOG"

file "$PREFIX/lib/libjpeg.a" | tee -a "$LOG"

echo "" | tee -a "$LOG"
echo "==================================" | tee -a "$LOG"
echo "libjpeg-turbo build complete for $PLATFORM" | tee -a "$LOG"
echo "==================================" | tee -a "$LOG"
