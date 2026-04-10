#!/bin/bash

#compile mbedtls for use with emscripten

set -x
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./emscripten-env.sh
source "$SCRIPT_DIR/emscripten-env.sh"

CORE_COUNT=$(nproc --all)
PREFIX=$(realpath build/mbedtls-wasm)
rm -rf $PREFIX
mkdir -p $PREFIX

cd build
rm -rf mbedtls
git clone -b mbedtls-3.6.5 --recursive --depth=1 https://github.com/Mbed-TLS/mbedtls mbedtls
cd mbedtls

"$EMMAKE" make -C library CFLAGS="-O3" -j$CORE_COUNT

mkdir -p "$PREFIX/include"
mkdir -p "$PREFIX/lib"
cp -r include/mbedtls "$PREFIX/include"
cp -r include/psa "$PREFIX/include"
cp library/libmbedcrypto.a "$PREFIX/lib"
cp library/libmbedx509.a "$PREFIX/lib"
cp library/libmbedtls.a "$PREFIX/lib"

cd ../../
