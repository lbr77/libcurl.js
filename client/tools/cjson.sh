#!/bin/bash

#compile cjson for use with emscripten

set -x
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./emscripten-env.sh
source "$SCRIPT_DIR/emscripten-env.sh"

CORE_COUNT=$(nproc --all)
PREFIX=$(realpath build/cjson-wasm)
mkdir -p $PREFIX

cd build
rm -rf cjson
git clone -b v1.7.19 --depth=1 https://github.com/DaveGamble/cJSON cjson
cd cjson

sed -i 's/-fstack-protector-strong//' Makefile
sed -i 's/-fstack-protector//' Makefile

"$EMMAKE" make CC="$EMCC" static
INCLUDE_FILES="cJSON.h cJSON_Utils.h"
LIB_FILES="libcjson.a libcjson_utils.a"

rm -rf $PREFIX
mkdir -p $PREFIX/include/cjson
mkdir -p $PREFIX/lib
cp $INCLUDE_FILES $PREFIX/include/cjson
cp $LIB_FILES $PREFIX/lib

cd ../../
