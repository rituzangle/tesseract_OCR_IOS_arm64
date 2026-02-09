#!/usr/bin/env bash
set -euo pipefail

# Scripts/build/build_leptonica.sh
# The most important dependency before Tesseract because Leptonica is the engine Tesseract actually uses to do all the image processing.
# Leptonica handles:
# 	•	image loading
# 	•	preprocessing
# 	•	binarization
# 	•	scaling
# 	•	noise removal
# Tesseract is essentially a recognizer layered on top of Leptonica.

########################################
# Platform
########################################
PLATFORM="${1:-ios}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh" "$PLATFORM"

########################################
# Paths
########################################

SRC="$SOURCES_DIR/leptonica-1.84.1"
BUILD="$SRC/$BUILD_DIR_SUFFIX"
LOG="$LOGS_DIR/build_leptonica_$PLATFORM.log"

mkdir -p "$BUILD"
rm -rf "$BUILD"/*
cd "$BUILD"

########################################
# Header
########################################

echo "==================================" | tee "$LOG"
echo "Building leptonica ($PLATFORM)" | tee -a "$LOG"
echo "Source: $SRC" | tee -a "$LOG"
echo "Build:  $BUILD" | tee -a "$LOG"
echo "Prefix: $PREFIX" | tee -a "$LOG"
echo "==================================" | tee -a "$LOG"

# ==============================
# Apple-specific autotools overrides
# ==============================
echo ""| tee -a "$LOG"

if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "macos" ]]; then
    echo "Applying Apple cross-compile overrides..." | tee -a "$LOG"

    # Endian & malloc detection
    export ac_cv_c_bigendian=no
    export ac_cv_func_malloc_0_nonnull=yes
    export ac_cv_func_realloc_0_nonnull=yes
    export ac_cv_func_mmap_fixed_mapped=no
    export ac_cv_have_decl_malloc=yes
    export ac_cv_have_decl_realloc=yes

    # Avoid Linux-specific -lrt
    export ac_cv_lib_rt_clock_gettime=no

    # Disable linking against pthreads library detection hack if present
    export ac_cv_func_pthread_create=yes

    # Prevent pkg-config from finding any system librt
    export LDFLAGS="${LDFLAGS//-lrt/}"

    # For completeness: disable Linux-specific features
    export ac_cv_header_sys_shm_h=no
    export ac_cv_header_sys_sem_h=no
    export ac_cv_header_sys_ipc_h=no
fi

########################################
# Configure
########################################
# Leptonica 1.84.x: Unlike older versions, it no longer ships with a pre-generated configure. make it.
if [ ! -f "$SRC/configure" ]; then
    echo "Generating configure script with autogen.sh..." | tee -a "$LOG"
    (cd "$SRC" && ./autogen.sh) >> "$LOG" 2>&1
fi
echo "Running configure..." | tee -a "$LOG"

(    echo "Constraining pkg-config to project prefix for Leptonica build..." | tee -a "$LOG"
    export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"

    "$SRC/configure" \
      --build="$BUILD_TRIPLE" \
      --host="$HOST_TRIPLE" \
      --prefix="$PREFIX" \
      --enable-static \
      --disable-shared \
      --disable-programs \
      --without-giflib \
      --without-libwebp \
      --without-libopenjpeg \
      >> "$LOG" 2>&1

    echo "Building..." | tee -a "$LOG"
    make -j$(sysctl -n hw.ncpu) >> "$LOG" 2>&1

    echo "Installing..." | tee -a "$LOG"
    make install >> "$LOG" 2>&1
)

########################################
# Success
########################################

echo "leptonica SUCCESS ($PLATFORM)" | tee -a "$LOG"
echo "Installed to $PREFIX"

echo "==================================" | tee -a "$LOG"
