#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Scripts/download_and_untar.sh
#
# Downloads and extracts all source dependencies required to build
# Tesseract 5.5.2 for iOS and macOS.
# Usage:
#   bash Scripts/download_and_untar.sh
# Tesseract 5.5.2 is the last version compatible with leptonica 1.84.1, which is required for iOS support.
# rest of the dependencies versions chosen for compatibility and stability with Tesseract 5.5.2 and leptonica 1.84.1.
# Script is safe to run multiple times. Skips existing downloads.
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DOWNLOAD_DIR="$PROJECT_ROOT/Downloads"
SOURCE_DIR="$PROJECT_ROOT/Sources"

TESSERACT_VERSION="5.5.2"
LEPTONICA_VERSION="1.84.1"
LIBPNG_VERSION="1.6.43"
ZLIB_VERSION="1.3.1"
LIBJPEG_VERSION="3.0.1"
LIBTIFF_VERSION="4.6.0"

if [ ! -d "$DOWNLOAD_DIR" || ! -d "$SOURCE_DIR" ]; then
    mkdir -p "$DOWNLOAD_DIR"
    mkdir -p "$SOURCE_DIR"
fi

echo "========================================"
echo "Download directory: $DOWNLOAD_DIR"
echo "Source directory:   $SOURCE_DIR"
echo "========================================"

download_if_missing() {
    local url="$1"
    local output="$2"

    if [ -f "$output" ]; then
        echo "✓ Already downloaded: $(basename "$output")"
    else
        echo "↓ Downloading: $(basename "$output")"
        curl -L "$url" -o "$output"
    fi
}

###############################################################################
# Download
###############################################################################

download_if_missing \
"https://github.com/tesseract-ocr/tesseract/archive/refs/tags/${TESSERACT_VERSION}.tar.gz" \
"$DOWNLOAD_DIR/tesseract-${TESSERACT_VERSION}.tar.gz"

download_if_missing \
"https://github.com/DanBloomberg/leptonica/archive/refs/tags/${LEPTONICA_VERSION}.tar.gz" \
"$DOWNLOAD_DIR/leptonica-${LEPTONICA_VERSION}.tar.gz"

download_if_missing \
"https://download.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.gz" \
"$DOWNLOAD_DIR/libpng-${LIBPNG_VERSION}.tar.gz"

download_if_missing \
"https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz" \
"$DOWNLOAD_DIR/zlib-${ZLIB_VERSION}.tar.gz"

download_if_missing \
"https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz" \
"$DOWNLOAD_DIR/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz"

download_if_missing \
"https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz" \
"$DOWNLOAD_DIR/libtiff-${LIBTIFF_VERSION}.tar.gz"

##################################################################
# Extract
##################################################################

extract_if_missing() {
    local archive="$1"
    local target_dir="$2"

    if [ -d "$target_dir" ]; then
        echo "✓ Already extracted: $(basename "$target_dir")"
    else
        echo "→ Extracting: $(basename "$archive")"
        tar -zxf "$archive" -C "$SOURCE_DIR"
    fi
}

extract_if_missing \
"$DOWNLOAD_DIR/tesseract-${TESSERACT_VERSION}.tar.gz" \
"$SOURCE_DIR/tesseract-${TESSERACT_VERSION}"

extract_if_missing \
"$DOWNLOAD_DIR/leptonica-${LEPTONICA_VERSION}.tar.gz" \
"$SOURCE_DIR/leptonica-${LEPTONICA_VERSION}"

extract_if_missing \
"$DOWNLOAD_DIR/libpng-${LIBPNG_VERSION}.tar.gz" \
"$SOURCE_DIR/libpng-${LIBPNG_VERSION}"

extract_if_missing \
"$DOWNLOAD_DIR/zlib-${ZLIB_VERSION}.tar.gz" \
"$SOURCE_DIR/zlib-${ZLIB_VERSION}"

extract_if_missing \
"$DOWNLOAD_DIR/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz" \
"$SOURCE_DIR/libjpeg-turbo-${LIBJPEG_VERSION}"

extract_if_missing \
"$DOWNLOAD_DIR/libtiff-${LIBTIFF_VERSION}.tar.gz" \
"$SOURCE_DIR/tiff-${LIBTIFF_VERSION}"

#################################################################
# Done
#################################################################

echo ""
echo "========================================"
echo "All dependencies ready."
echo "You may now run:"
echo ""
echo "Scripts/build/build_all.sh"
echo "========================================"

echo " Check Downloads for packages and Sources directories for the extracted files in their respective folders."
