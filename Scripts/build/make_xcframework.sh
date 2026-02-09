#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#source "$SCRIPT_DIR/env.sh" "ios"

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

echo "========================================" | tee "$LOG"
echo "📦 Creating universal XCFramework"        | tee -a "$LOG"
echo "iOS root:   $IOS_ROOT"             | tee -a "$LOG"
echo "macOS root: $MAC_ROOT"         | tee -a "$LOG"
echo " IOS_LIB: $IOS_LIB"  | tee -a "$LOG"
echo " MAC_LIB: $MAC_LIB"   | tee -a "$LOG"
echo "Logs:       $LOG"            | tee -a "$LOG"
echo "========================================" | tee -a "$LOG"

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

echo -e "${GREEN}========================================"
echo -e "${GREEN}🟢 XCFramework created successfully!."
echo "Path: $XCFRAMEWORK_DIR"
echo "Next steps:"
echo "1. Copy Tesseract.xcframework → Xcode project Frameworks/"
echo "2. Set 'Do Not Embed'"
echo "3. Import <tesseract/baseapi.h>"
echo "========================================${RESET}" | tee -a "$LOG"


# #!/usr/bin/env bash
# set -euo pipefail

# PLATFORM="${1:?Missing platform argument}"
# export PLATFORM
# #####################################################
# # Scripts/build/make_xcframework.sh
# # Combines iOS + macOS Tesseract builds into a single XCFramework
# # Usage:
# #   ./make_xcframework.sh <iOS_ROOT> <MAC_ROOT>
# #####################################################

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# BUILD_ARTIFACTS_DIR="$PROJECT_ROOT/Build_Artifacts"
# OUTPUT_DIR="$PROJECT_ROOT/Output"
# XCFRAMEWORK_DIR="$OUTPUT_DIR/Tesseract.xcframework"

# LOG_DIR="$PROJECT_ROOT/Logs"
# LOG="$LOG_DIR/make_xcframework.log"
# IOS_ROOT="Root/ios_arm64"
# MAC_ROOT="Root/macos_arm64"

# # IOS_ROOT="${1:?iOS build root required}"
# # MAC_ROOT="${2:?macOS build root required}"
# IOS_ROOT="${1:?iOS build root required}"
# MAC_ROOT="${2:?macOS build root required}"

# mkdir -p "$LOG_DIR" "$OUTPUT_DIR"

# echo "========================================" | tee "$LOG"
# echo "📦 Creating universal XCFramework" | tee -a "$LOG"
# echo "iOS root:   $IOS_ROOT" | tee -a "$LOG"
# echo "macOS root: $MAC_ROOT" | tee -a "$LOG"
# echo "Logs:       $LOG" | tee -a "$LOG"
# echo "========================================" | tee -a "$LOG"

# # Output directory
# if [[ -d "$XCFRAMEWORK_DIR" ]]; then
#     echo "Removing existing XCFramework at $XCFRAMEWORK_DIR" | tee -a "$LOG"
#     rm -rf "$XCFRAMEWORK_DIR"
# fi

# mkdir -p "$XCFRAMEWORK_DIR"

# # List of static libraries to include in the XCFramework
# LIBS=("libtesseract.a" "libleptonica.a" "libpng.a" "libjpeg.a" "libtiff.a" "libz.a")

# # Function to validate libraries
# validate_libs() {
#     local ROOT="$1"
#     local PLATFORM_NAME="$2"
#     for LIB in "${LIBS[@]}"; do
#         if [[ ! -f "$ROOT/lib/$LIB" ]]; then
#             echo "❌ ERROR: Missing $LIB in $ROOT/lib for $PLATFORM_NAME" | tee -a "$LOG"
#             exit 1
#         fi
#     done
# }

# # Validate all libraries exist
# echo "Validating presence of static libraries..." | tee -a "$LOG"
# validate_libs "$IOS_ROOT" "iOS"
# validate_libs "$MAC_ROOT" "macOS"

# # iOS device + simulator universal libs
# IOS_LIBS=()
# IOS_ARCHS=("arm64")  # simulator x86_64 optional for Intel Macs
# for ARCH in "${IOS_ARCHS[@]}"; do
#     # lib paths per architecture (assume build scripts output to $IOS_ROOT/lib)
#     IOS_LIBS+=("$IOS_ROOT/lib/libtesseract.a")
# done

# echo "✅ All libraries exist. Preparing XCFramework build..." | tee -a "$LOG"

# # Assemble XCFramework arguments
# XCFRAMEWORK_ARGS=()

# # iOS device
# XCFRAMEWORK_ARGS+=(-library "$IOS_ROOT/lib/libtesseract.a" -headers "$IOS_ROOT/include")

# # iOS simulator
# for ARCH in "${IOS_ARCHS[@]}"; do
#     XCFRAMEWORK_ARGS+=(-library "$IOS_ROOT/lib/libtesseract.a" -headers "$IOS_ROOT/include")
# done

# # macOS
# XCFRAMEWORK_ARGS+=(-library "$MAC_ROOT/lib/libtesseract.a" -headers "$MAC_ROOT/include")

# # Build XCFramework
# echo "Running xcodebuild -create-xcframework..." | tee -a "$LOG"
# xcodebuild -create-xcframework \
#     "${XCFRAMEWORK_ARGS[@]}" \
#     -output "$XCFRAMEWORK_DIR" \
#     2>&1 | tee -a "$LOG"

# echo ""
# echo "========================================" | tee -a "$LOG"
# echo "🎉 XCFramework created successfully!" | tee -a "$LOG"
# echo "Path: $XCFRAMEWORK_DIR" | tee -a "$LOG"
# echo "Next steps:" | tee -a "$LOG"
# echo "1. Copy Tesseract.xcframework → your Xcode project Frameworks/" | tee -a "$LOG"
# echo "2. Set 'Do Not Embed' in Xcode" | tee -a "$LOG"
# echo "3. Import <tesseract/baseapi.h>" | tee -a "$LOG"
# echo "========================================" | tee -a "$LOG"

# # Expected output:
# # ========================================
# # 📦 Creating XCFramework
# # iOS root:   Root/ios_arm64
# # macOS root: Root/macos_arm64
# # Logs:       Logs/make_xcframework.log
# # ✅ All libraries found, building XCFramework...
# # 🎉 XCFramework created successfully!
# # Path: Output/Tesseract.xcframework
# # Next steps:
# # 1. Copy Tesseract.xcframework → your Xcode project Frameworks/
# # 2. Set 'Do Not Embed' in Xcode
# # 3. Import <tesseract/baseapi.h>

# # Key Features
# #   •	Fully universal XCFramework for iOS + macOS, including:
# # •	iOS device + simulator (arm64, x86_64)
# # •	macOS arm64 (Apple Silicon)
# # •	All relevant headers included
# # •	Robust checks, debug-friendly logs, actionable errors
# # •	Idempotent / safe: removes old XCFramework automatically
# # •	Verbose logging for full traceability

# # 	1.	Fully robust & safe:
# # 	•	Verifies that all expected .a static libraries exist for both iOS and macOS before creating the XCFramework.
# # 	•	Exits gracefully with clear error messages if something is missing.
# # 	2.	Debug-friendly:
# # 	•	All output logged to Logs/make_xcframework.log.
# # 	•	Echoes full build summary to terminal.
# # 	3.	Ready to ship:
# # 	•	Output directory: Output/Tesseract.xcframework.
# # 	•	Includes headers for both iOS and macOS.
# # 	4.	Extensible:
# # 	•	Add extra static libraries to the LIBS array if needed in future.
# # 	•	Supports additional platforms (e.g., simulator) if you later want to extend XCFramework.
# # 	5.	Clean and deterministic:
# # 	•	Removes any previous XCFramework before creating a new one.
