#!/usr/bin/env bash
# Scripts/build/env.sh
# Canonical Apple cross-compile environment
# Supports:
#   ios     → arm64 device
#   macos   → arm64 Apple Silicon
# Usage:
#   source Scripts/build/env.sh ios

set -euo pipefail

########################################
# Resolve project root
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

export PROJECT_ROOT
export SOURCES_DIR="$PROJECT_ROOT/Sources"
export ROOT_DIR="$PROJECT_ROOT/Root"
export LOGS_DIR="$PROJECT_ROOT/Logs"
export OUTPUT_DIR="$PROJECT_ROOT/Output"

mkdir -p "$ROOT_DIR" "$LOGS_DIR" "$OUTPUT_DIR"

# Start clean log
LOG="$LOGS_DIR/env_setup.log"
rm -f "$LOG"
echo "Logs will be written to: $LOG" | tee -a "$LOG"
echo "========================================" | tee -a "$LOG"
echo "Setting up build environment" | tee -a "$LOG"

########################################
# Platform selection
########################################
PLATFORM="${1:-ios}"

ARCH="arm64"
CANONICAL_ARCH="aarch64"
MIN_IOS="15.0"
MIN_MACOS="15.0"

########################################
# Canonical triples & build dirs
########################################
case "$PLATFORM" in
    ios)
        SDK="iphoneos"
        HOST_TRIPLE="aarch64-apple-ios"
        BUILD_TRIPLE="aarch64-apple-darwin"
        PREFIX="$ROOT_DIR/ios_arm64"
        MIN_FLAG="-miphoneos-version-min=$MIN_IOS"
        BUILD_DIR_SUFFIX="build-ios"
        ;;
    macos)
        SDK="macosx"
        HOST_TRIPLE="aarch64-apple-darwin"
        BUILD_TRIPLE="aarch64-apple-darwin"
        PREFIX="$ROOT_DIR/macos_arm64"
        MIN_FLAG="-mmacosx-version-min=$MIN_MACOS"
        BUILD_DIR_SUFFIX="build-macos"
        ;;
    *)
        echo "Unknown platform: $PLATFORM" | tee -a "$LOG"
        exit 1
        ;;
esac

export PLATFORM ARCH CANONICAL_ARCH HOST_TRIPLE BUILD_TRIPLE PREFIX MIN_FLAG BUILD_DIR_SUFFIX

########################################
# Ensure prefix exists
########################################
if [ ! -d "$PREFIX" ]; then
    mkdir -p "$PREFIX"
    echo "Created PREFIX directory: $PREFIX" | tee -a "$LOG"
fi

########################################
# SDK path
########################################
SDK_PATH="$(xcrun --sdk "$SDK" --show-sdk-path)"
export SDK_PATH

########################################
# Toolchain
########################################
export CC="$(xcrun --sdk "$SDK" -f clang)"
export CXX="$(xcrun --sdk "$SDK" -f clang++)"
export AR="$(xcrun --sdk "$SDK" -f ar)"
export RANLIB="$(xcrun --sdk "$SDK" -f ranlib)"
export STRIP="$(xcrun --sdk "$SDK" -f strip)"

########################################
# Compiler & linker flags
########################################
COMMON_FLAGS="-arch $ARCH -isysroot $SDK_PATH $MIN_FLAG -O2 -fPIC"

export CFLAGS="$COMMON_FLAGS"
export CXXFLAGS="$COMMON_FLAGS"
export CPPFLAGS="-I$PREFIX/include -isysroot $SDK_PATH"
export LDFLAGS="-L$PREFIX/lib -isysroot $SDK_PATH $MIN_FLAG"

echo "Compiler and linker flags set" | tee -a "$LOG"

########################################
# Autotools default flags
########################################
export COMMON_CONFIG_FLAGS="--build=$BUILD_TRIPLE --host=$HOST_TRIPLE --prefix=$PREFIX --enable-static --disable-shared --disable-dependency-tracking"

########################################
# Debug info
########################################
echo "" | tee -a "$LOG"
echo "========================================" | tee -a "$LOG"
echo "Build Environment:" | tee -a "$LOG"
echo "Platform:   $PLATFORM" | tee -a "$LOG"
echo "SDK:        $SDK" | tee -a "$LOG"
echo "SDK_PATH:   $SDK_PATH" | tee -a "$LOG"
echo "Host:       $HOST_TRIPLE" | tee -a "$LOG"
echo "Build:      $BUILD_TRIPLE" | tee -a "$LOG"
echo "Arch:       $ARCH ($CANONICAL_ARCH)" | tee -a "$LOG"
echo "Prefix:     $PREFIX" | tee -a "$LOG"
echo "Build Dir:  $BUILD_DIR_SUFFIX" | tee -a "$LOG"
echo "Min OS Flag:$MIN_FLAG" | tee -a "$LOG"
echo "Common CFLAGS: $CFLAGS" | tee -a "$LOG"
echo "Common LDFLAGS: $LDFLAGS" | tee -a "$LOG"
echo "Autotools flags: $COMMON_CONFIG_FLAGS" | tee -a "$LOG"
echo "========================================" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# BUILD_TRIPLE means: “the machine performing the build”
# HOST_TRIPLE means: “the machine we are building for”
# “the machine that will run the compiled code” we are building.
# platform       HOST_TRIPLE
# macOS        aarch64-apple-darwin
# iOS           aarch64-apple-ios
# BUILD_TRIPLE=aarch64-apple-darwin means we are building on an Apple Silicon machine, and HOST_TRIPLE=aarch64-apple-ios means we are building for iOS on arm64 devices.
# For iOS, the build machine is arm64 ~ Apple Silicon), but we are building for arm64, so the host triple is aarch64-apple-ios and the build triple is aarch64-apple-darwin (or x86_64-apple-darwin if running on Intel).

# Final architecture model (correct mental model)
# env.sh defines:
#   HOST_TRIPLE
#   BUILD_TRIPLE
#   PREFIX
#   SDK
#   FLAGS

# Golden rule for ALL scripts
# Every configure must use:
# --host="$HOST_TRIPLE"
# --build="$BUILD_TRIPLE"
