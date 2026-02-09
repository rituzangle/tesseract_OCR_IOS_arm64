#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#####################################################
# Scripts/build/make_xcframework.sh
# Combines iOS + macOS builds into one XCFramework
# Usage:
#   ./make_xcframework.sh <iOS_ROOT> <MAC_ROOT>
#####################################################

PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROOT="$PROJECT_ROOT/Root"

IOS_ROOT="$ROOT/ios_arm64" # "${1:?iOS root required}"
MAC_ROOT="$ROOT/macos_arm64" # "${2:?macOS root required}"

IOS_LIB="$IOS_ROOT/lib"
MAC_LIB="$MAC_ROOT/lib"

OUTPUT_DIR="$PROJECT_ROOT/Output"
XCFRAMEWORK_DIR="$OUTPUT_DIR/Tesseract.xcframework"

LOG_DIR="$(dirname "$0")/../Logs"
LOG="$LOG_DIR/make_xcframework.log"

# # Suppress specific path from output
# echo "IOS_ROOT: ${IOS_ROOT/#\/Users\/mommy\/Projects\/tesseractOCR_552\//}"
# echo "MAC_ROOT: ${MAC_ROOT/#\/Users\/mommy\/Projects\/tesseractOCR_552\//}"

mkdir -p "$LOG_DIR"

# Define color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Print messages with LED icons
# echo -e "${GREEN}🟢 Green LED: This is a successful message.${RESET}"
# echo -e "${RED}🔴 Red LED: This is an error message.${RESET}"

echo "==================================" | tee "$LOG"
echo "Creating universal XCFramework"   | tee -a "$LOG"
echo "iOS root:   $IOS_ROOT"            | tee -a "$LOG"
echo "macOS root: $MAC_ROOT"         | tee -a "$LOG"
echo "IOS_LIB: $IOS_LIB"            | tee -a "$LOG"
echo "MAC_LIB: $MAC_LIB"            | tee -a "$LOG"
echo "Logs:       $LOG"             | tee -a "$LOG"
echo "==================================" | tee -a "$LOG"

# Remove old XCFramework
if [[ -d "$XCFRAMEWORK_DIR" ]]; then
    echo "Removing existing XCFramework at $XCFRAMEWORK_DIR" | tee -a "$LOG"
    mv "$XCFRAMEWORK_DIR" "$XCFRAMEWORK_DIR-$(date +%s)" 2>/dev/null || true
fi
mkdir -p "$XCFRAMEWORK_DIR" "$OUTPUT_DIR"

# Function to validate libraries exist
 #LIBS=("libtesseract.a" "libleptonica.a" "libpng.a" "libjpeg.a" "libtiff.a" "libz.a")

for LIB in libtesseract.a libleptonica.a libpng.a libjpeg.a libtiff.a libz.a; do
    [[ -f "$IOS_ROOT/lib/$LIB" ]] || { echo "❌ ERROR: Missing $LIB in $IOS_ROOT/lib for iOS"; exit 1; }
    [[ -f "$MAC_ROOT/lib/$LIB" ]] || { echo "❌ ERROR: Missing $LIB in $MAC_ROOT/lib for macOS"; exit 1; }
done
echo "✅ All required libraries found. Proceeding to create XCFramework..." | tee -a "$LOG"
echo "iOS libs: $(ls -m "$IOS_ROOT/lib")"   | tee -a "$LOG"
echo "macOS libs: $(ls -m "$MAC_ROOT/lib")" | tee -a "$LOG"
echo "----------------------------------------" | tee -a "$LOG"
# Build XCFramework
xcodebuild -create-xcframework \
    -library "$IOS_ROOT/lib/libtesseract.a" -headers "$IOS_ROOT/include" \
    -library "$MAC_ROOT/lib/libtesseract.a" -headers "$MAC_ROOT/include" \
    -output "$XCFRAMEWORK_DIR" \
    2>&1 | tee -a "$LOG"

echo "========================================"
echo "🟢 XCFramework created successfully!."
echo "Path: $XCFRAMEWORK_DIR"
echo "Next steps:"
echo "1. Copy Tesseract.xcframework → Xcode project Frameworks/"
echo "2. Set 'Do Not Embed'"
echo "3. Import <tesseract/baseapi.h>"
echo "========================================" | tee -a "$LOG"
