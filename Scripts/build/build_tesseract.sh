#!/usr/bin/env bash
set -euo pipefail

# Scripts/build/build_tesseract.sh
# Build Tesseract OCR for iOS and macOS
# This script will use your vendored libraries (zlib, libpng, libjpeg-turbo, libtiff, leptonica) and build Tesseract statically for iOS/macOS. It is fully debug-friendly and uses the canonical variables from your env.sh.

########################################
# Platform & Source env
########################################
PLATFORM="${1:-ios}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh" "$PLATFORM"

# Vendored libraries only
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"

# Cross-compile cache overrides for Apple
export ac_cv_lib_rt_clock_gettime=no
export ac_cv_func_malloc_0_nonnull=yes
export ac_cv_func_realloc_0_nonnull=yes
export ac_cv_c_bigendian=no
export ac_cv_func_mmap_fixed_mapped=no
# --- Apple cross-compile overrides
if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "macos" ]]; then
    export ac_cv_lib_rt_clock_gettime=no
    export ac_cv_lib_rt_time=no
    export ac_cv_lib_rt=no
    export LDFLAGS="${LDFLAGS//-lrt/}"
fi
########################################
# Paths
########################################
SRC="$SOURCES_DIR/tesseract-5.5.2"
BUILD="$SRC/$BUILD_DIR_SUFFIX"
LOG="$LOGS_DIR/build_tesseract_$PLATFORM.log"

mkdir -p "$BUILD"
rm -rf "$BUILD"/*
cd "$BUILD"

echo "==================================" | tee "$LOG"
echo "Building Tesseract ($PLATFORM)" | tee -a "$LOG"
echo "Source: $SRC" | tee -a "$LOG"
echo "Build:  $BUILD" | tee -a "$LOG"
echo "Prefix: $PREFIX" | tee -a "$LOG"
echo "==================================" | tee -a "$LOG"

# ==============================
# Apple-specific autotools overrides
# ==============================
if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "macos" ]]; then

    echo "Applying Apple cross-compile overrides..." | tee -a "$LOG"

    # Endian & malloc detection
    export ac_cv_c_bigendian=no
    export ac_cv_func_malloc_0_nonnull=yes
    export ac_cv_func_realloc_0_nonnull=yes
    export ac_cv_func_mmap_fixed_mapped=no
    export ac_cv_have_decl_malloc=yes
    export ac_cv_have_decl_realloc=yes

    # Avoid Linux-specific -lrt ~library 'rt' not found errors
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
# Configure flags
########################################

CONFIG_FLAGS="\
--build=$BUILD_TRIPLE \
--host=$HOST_TRIPLE \
--prefix=$PREFIX \
--enable-static \
--disable-shared \
--without-curl \
--without-graphics \
--disable-openmp \
--without-training-tools"

# Point Tesseract to vendored libraries
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export CPPFLAGS="-I$PREFIX/include -isysroot $SDK_PATH"
export LDFLAGS="-L$PREFIX/lib -isysroot $SDK_PATH"
# In build_tesseract.sh, before ./configure
export ac_cv_lib_rt_clock_gettime=no
# Apple fix: remove any -lrt that might sneak in
LDFLAGS="${LDFLAGS//-lrt/}"
export LDFLAGS
echo "Configuring Tesseract..." | tee -a "$LOG"
"$SRC/configure" $CONFIG_FLAGS >> "$LOG" 2>&1

echo "Patching Makefile to remove -lrt from LIBS variable..." | tee -a "$LOG"
sed -i.bak 's/-lrt//g' Makefile

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
echo "Tesseract SUCCESS ($PLATFORM)" | tee -a "$LOG"
echo "Installed to $PREFIX" | tee -a "$LOG"
echo "==================================" | tee -a "$LOG"

# # Notes
# 	1.	Vendored libraries only: No Homebrew, no fp.h errors, no system dependencies.
# 	2.	Cross-compiling safe: Uses HOST_TRIPLE and BUILD_TRIPLE from env.sh.
# 	3.	Static-only build: Perfect for XCFramework packaging.
# 	4.	Training tools disabled: Avoids ICU/other missing deps that stop the build.
# 	5.	Debug-friendly: Full tee -a $LOG output for each step.
