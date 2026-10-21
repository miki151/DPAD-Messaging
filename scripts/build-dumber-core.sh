#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
ndk="${ANDROID_NDK_HOME:-${ANDROID_HOME:-$HOME/Android/Sdk}/ndk/30.0.16248370}"
toolchain="$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin"
# Override for other supported Android ABIs; the initial device build is ARM64.
target="${DUMBER_RUST_TARGET:-aarch64-linux-android}"
case "$target" in
 aarch64-linux-android) abi=arm64-v8a; compiler=aarch64-linux-android23 ;;
 armv7-linux-androideabi) abi=armeabi-v7a; compiler=armv7a-linux-androideabi23 ;;
 x86_64-linux-android) abi=x86_64; compiler=x86_64-linux-android23 ;;
 *) echo "Unsupported target: $target" >&2; exit 1 ;;
esac
suffix="${target//-/_}"
export "CARGO_TARGET_${suffix^^}_LINKER=$toolchain/$compiler-clang"
export "CC_$suffix=$toolchain/$compiler-clang"
export "CXX_$suffix=$toolchain/$compiler-clang++"
export "AR_$suffix=$toolchain/llvm-ar"
cargo build --locked --release --manifest-path vendor/dumber-chat-core/Cargo.toml --target "$target"
mkdir -p "app/src/main/jniLibs/$abi"
cp "${CARGO_TARGET_DIR:-vendor/dumber-chat-core/target}/$target/release/libdumber_chat_core.so" "app/src/main/jniLibs/$abi/"
"$toolchain/llvm-strip" --strip-unneeded "app/src/main/jniLibs/$abi/libdumber_chat_core.so"
