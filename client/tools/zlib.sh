#!/bin/bash

#compile zlib for use with emscripten

set -x
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./emscripten-env.sh
source "$SCRIPT_DIR/emscripten-env.sh"

CORE_COUNT=$(nproc --all)
PREFIX=$(realpath build/zlib-wasm)

cd build
rm -rf zlib
git clone -b v1.3.1 --depth=1 https://github.com/madler/zlib
cd zlib

"$EMCONFIGURE" ./configure --static
"$EMMAKE" make -j$CORE_COUNT

rm -rf $PREFIX
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
cp -r *.h $PREFIX/include
cp -r *.a $PREFIX/lib

cd ../../
