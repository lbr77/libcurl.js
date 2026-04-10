#!/bin/bash

#compile nghttp2 for use with emscripten

set -x
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./emscripten-env.sh
source "$SCRIPT_DIR/emscripten-env.sh"

CORE_COUNT=$(nproc --all)
PREFIX=$(realpath build/nghttp2-wasm)

cd build
rm -rf nghttp2
git clone -b v1.68.0 --depth=1 https://github.com/nghttp2/nghttp2
cd nghttp2

rm -rf $PREFIX
mkdir -p $PREFIX

autoreconf -fi
"$EMCONFIGURE" ./configure --host i686-linux --enable-static --disable-shared --enable-lib-only --prefix=$PREFIX
"$EMMAKE" make -j$CORE_COUNT
make install

cd ../../
