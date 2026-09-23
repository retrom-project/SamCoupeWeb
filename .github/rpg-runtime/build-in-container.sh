#!/usr/bin/env bash
set -euo pipefail
trap 'chown -R "${RETROM_HOST_UID}:${RETROM_HOST_GID}" /work /output' EXIT
mkdir -p /work/source /work/build
tar -xf /source.tar -C /work/source
emcmake cmake -S /work/source/wasm -B /work/build \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_BACKEND=sdl -DRETROM_BROWSER_CANDIDATE=ON
cmake --build /work/build --parallel 2
install -m 0644 /work/build/samcoupeweb.js /output/samcoupeweb.js
install -m 0644 /work/build/samcoupeweb.wasm /output/samcoupeweb.wasm
install -m 0644 /work/build/samcoupeweb.data /output/samcoupeweb.data
