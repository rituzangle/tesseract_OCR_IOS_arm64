#!/usr/bin/env bash
set -euo pipefail

##########################################################################
# Orchestrator: Build all dependencies for Tesseract OCR (iOS + macOS)
# Usage: Scripts/build/build_all.sh
# Notes:
#   - Builds all vendored dependencies
#   - Builds Tesseract OCR
#   - Creates XCFramework
#   - Writes build manifest
##########################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROOT="$PROJECT_ROOT/Root"
SOURCES_DIR="$PROJECT_ROOT/Sources"
OUTPUT="$PROJECT_ROOT/Output"
LOGS_DIR="$PROJECT_ROOT/Logs"
BUILD_ARTIFACTS_DIR="$PROJECT_ROOT/Build_Artifacts"
LOG="$LOGS_DIR/build_all.log"

mkdir -p "$LOGS_DIR" "$OUTPUT" "$BUILD_ARTIFACTS_DIR" "$ROOT/ios_arm64" "$ROOT/macos_arm64"
rm -f "$LOG"  # Clean old log

# Master log capture
exec > >(tee -a "$LOG") 2>&1

echo "=========================================="
echo "Build started: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo "Project root: $PROJECT_ROOT"
echo "Logs: $LOG"
echo "=========================================="

# Clean previous artifacts
echo "🧹 Cleaning previous artifacts..."
rm -rf "$OUTPUT" "$BUILD_ARTIFACTS_DIR"
mkdir -p "$OUTPUT" "$BUILD_ARTIFACTS_DIR"

#################################################
# Build function per platform
#################################################
build_for_platform() {
    local PLATFORM="$1"   # ios or macos
    local PREFIX="$ROOT/${PLATFORM}_arm64"  # consistent root for libraries

    echo ""
    echo "=========================================="
    echo " Building for $PLATFORM"
    echo " Prefix: $PREFIX"
    echo "=========================================="

    # Ensure clean build directory
    mkdir -p "$PREFIX"

    # Source environment + dependencies
    source "$SCRIPT_DIR/env.sh" "$PLATFORM"
    source "$SCRIPT_DIR/build_zlib.sh"
    source "$SCRIPT_DIR/build_libjpeg.sh"
    source "$SCRIPT_DIR/build_libpng.sh"
    source "$SCRIPT_DIR/build_libtiff.sh"
    source "$SCRIPT_DIR/build_leptonica.sh"
    source "$SCRIPT_DIR/build_tesseract.sh"

    echo "✅ Build complete for $PLATFORM"
    echo ""
}

########################################
# Build iOS first
########################################
build_for_platform ios
export IOS_ROOT="$ROOT/ios_arm64"

########################################
# Build macOS next
########################################
build_for_platform macos
export MAC_ROOT="$ROOT/macos_arm64"

########################################
# Create XCFramework
########################################
echo ""
echo "=========================================="
echo " 🍏 Creating XCFramework..."
echo "=========================================="
bash "$SCRIPT_DIR/make_xcframework.sh" "$IOS_ROOT" "$MAC_ROOT"

########################################
# Write build manifest
########################################
MANIFEST="$BUILD_ARTIFACTS_DIR/build_manifest.json"
echo ""
echo "Writing build manifest to $MANIFEST"

cat > "$MANIFEST" <<EOF
{
  "project": "tesseract-ios",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "ios_root": "$IOS_ROOT",
  "macos_root": "$MAC_ROOT",
  "xcframework": "Output/Tesseract.xcframework",
  "ios_lib": "Output/Tesseract.xcframework/ios-arm64/libtesseract.a",
  "macos_lib": "Output/Tesseract.xcframework/macos-arm64/libtesseract.a",
  "required_symbols": [
    "TessBaseAPICreate",
    "TessBaseAPIInit3",
    "TessVersion"
  ]
}
EOF

echo ""
echo "########################################"
echo "Summary:"
echo "🟢 ALL DONE — SAFE TO INTEGRATE"
echo "Next steps:"
echo "1. Copy Output/Tesseract.xcframework → OCR Xcode project Frameworks/"
echo "2. Set 'Do Not Embed'"
echo "3. Import <tesseract/baseapi.h>"
echo "########################################"
