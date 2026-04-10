#!/bin/bash

set -euo pipefail

if [[ -n "${LIBCURL_WASM_EMSCRIPTEN_READY:-}" ]]; then
  return 0
fi

resolve_glob() {
  compgen -G "$1" | head -n 1
}

tool_runs() {
  "$1" "$2" >/dev/null 2>&1
}

resolve_tool() {
  local provided_path="$1"
  local fallback_name="$2"

  if [[ -n "$provided_path" ]]; then
    printf '%s\n' "$provided_path"
    return 0
  fi

  command -v "$fallback_name"
}

EMSDK_DIR="${EMSDK:-}"
if [[ -z "$EMSDK_DIR" && -n "${EMSDK_ENV:-}" ]]; then
  EMSDK_DIR="$(cd "$(dirname "$EMSDK_ENV")" && pwd)"
fi

if [[ -n "$EMSDK_DIR" ]]; then
  CANDIDATE_EMSDK_NODE="${EMSDK_NODE:-$(resolve_glob "$EMSDK_DIR/node/*/bin/node" || true)}"

  if [[ -n "$CANDIDATE_EMSDK_NODE" ]] && tool_runs "$CANDIDATE_EMSDK_NODE" --version; then
    export EMSDK="$EMSDK_DIR"
    export PATH="$EMSDK_DIR:$EMSDK_DIR/upstream/emscripten:$PATH"

    if [[ -z "${EMSDK_NODE:-}" ]]; then
      EMSDK_NODE="$CANDIDATE_EMSDK_NODE"
      export EMSDK_NODE
    fi

    if [[ -z "${EMSDK_PYTHON:-}" ]]; then
      EMSDK_PYTHON="$(resolve_glob "$EMSDK_DIR/python/*/bin/python3" || true)"
      export EMSDK_PYTHON
    fi

    if [[ -z "${SSL_CERT_FILE:-}" ]]; then
      SSL_CERT_FILE="$(resolve_glob "$EMSDK_DIR/python/*/lib/python*/site-packages/certifi/cacert.pem" || true)"
      export SSL_CERT_FILE
    fi
  fi
fi

EMCC="$(resolve_tool "${EMCC:-}" emcc)"
EMSCRIPTEN_BIN_DIR="$(cd "$(dirname "$EMCC")" && pwd)"
EMXX="$(resolve_tool "${EMXX:-}" em++ || true)"
EMAR="$(resolve_tool "${EMAR:-}" emar || true)"
EMRANLIB="$(resolve_tool "${EMRANLIB:-}" emranlib || true)"
EMNM="$(resolve_tool "${EMNM:-}" emnm || true)"
EMMAKE="$(resolve_tool "${EMMAKE:-}" emmake)"
EMCONFIGURE="$(resolve_tool "${EMCONFIGURE:-}" emconfigure)"
EMCMAKE="$(resolve_tool "${EMCMAKE:-}" emcmake)"

export PATH="$EMSCRIPTEN_BIN_DIR:$PATH"
export EMSCRIPTEN_BIN_DIR
export EMCC
export EMXX
export EMAR
export EMRANLIB
export EMNM
export EMMAKE
export EMCONFIGURE
export EMCMAKE
export LIBCURL_WASM_EMSCRIPTEN_READY=1
