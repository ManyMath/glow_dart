#!/bin/bash
#
# Build the Rust static library for macOS targets.
# Called by the CocoaPods script_phase in glow.podspec.
#
# Environment variables set by Xcode/CocoaPods:
#   CONFIGURATION       - Debug or Release
#   ARCHS               - Space-separated list of architectures (arm64, x86_64)
#   ONLY_ACTIVE_ARCH    - YES or NO
#   NATIVE_ARCH_ACTUAL  - The native architecture of the build machine
#   PODS_TARGET_SRCROOT - Path to the pod's source root (macos/)
#

set -e

RUST_DIR="${PODS_TARGET_SRCROOT}/../rust"
LIB_NAME="libflutter_opengl_rust.a"

# Determine Cargo profile
if [ "$CONFIGURATION" = "Release" ]; then
    CARGO_PROFILE="release"
    CARGO_FLAGS="--release"
else
    CARGO_PROFILE="debug"
    CARGO_FLAGS=""
fi

# For macOS, always build both architectures for a universal binary.
# When ONLY_ACTIVE_ARCH=YES (debug builds), build just the host arch.
if [ "$ONLY_ACTIVE_ARCH" = "YES" ]; then
    # Debug: build only for the host architecture
    RUST_TARGETS=""
    for ARCH in $ARCHS; do
        case "$ARCH" in
            arm64)  RUST_TARGETS="$RUST_TARGETS aarch64-apple-darwin" ;;
            x86_64) RUST_TARGETS="$RUST_TARGETS x86_64-apple-darwin" ;;
        esac
    done
else
    # Release: build universal binary (arm64 + x86_64)
    RUST_TARGETS="aarch64-apple-darwin x86_64-apple-darwin"
fi

if [ -z "$RUST_TARGETS" ]; then
    echo "error: no supported architectures found in ARCHS=$ARCHS"
    exit 1
fi

# Require provisioned Rust targets; build scripts never install shared SDKs
BUILT_LIBS=""
for TARGET in $RUST_TARGETS; do
    if ! rustup target list --installed | grep -Fxq "$TARGET"; then
        echo "error: provision Rust target $TARGET before building Glow" >&2
        exit 1
    fi
    cargo build --locked $CARGO_FLAGS --target "$TARGET" --manifest-path "$RUST_DIR/Cargo.toml"
    BUILT_LIBS="$BUILT_LIBS $RUST_DIR/target/$TARGET/$CARGO_PROFILE/$LIB_NAME"
done

# Create a universal (fat) library if multiple architectures, otherwise just copy
OUTPUT_DIR="$RUST_DIR/target/macos-universal/$CONFIGURATION"
mkdir -p "$OUTPUT_DIR"

LIB_COUNT=$(echo $BUILT_LIBS | wc -w | tr -d ' ')
if [ "$LIB_COUNT" -gt 1 ]; then
    lipo -create $BUILT_LIBS -output "$OUTPUT_DIR/$LIB_NAME"
else
    cp $BUILT_LIBS "$OUTPUT_DIR/$LIB_NAME"
fi

echo "Rust library built: $OUTPUT_DIR/$LIB_NAME"
