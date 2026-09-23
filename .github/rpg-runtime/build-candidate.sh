#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
output=${1:?absolute empty output directory is required}
python3 "$root/.github/rpg-runtime/candidate_descriptor.py" prepare "$output"
mkdir -p "$root/.retrom-build"
work=$(mktemp -d "$root/.retrom-build/retrom-samcoupe.XXXXXX")
trap 'rm -rf "$work"' EXIT INT TERM
mkdir -p "$work/raw" "$work/work"
source_digest=$(python3 "$root/.github/rpg-runtime/candidate_descriptor.py" digest "$output")
python3 "$root/.github/rpg-runtime/candidate_descriptor.py" paths "$output" > "$work/all-paths"
python3 - "$work/all-paths" "$work/source-paths" <<'PY'
import sys
from pathlib import Path

paths = Path(sys.argv[1]).read_bytes().split(b'\0')
excluded = {
    b'Resource/atom.rom', b'Resource/atomlite.rom', b'Resource/samcoupe.rom',
    b'Resource/sp0256-al2.bin',
    b'wasm/deploy/atom.rom', b'wasm/deploy/atomlite.rom', b'wasm/deploy/samcoupe.rom',
    b'wasm/deploy/samcoupeweb.data', b'wasm/deploy/samcoupeweb.js',
    b'wasm/deploy/samcoupeweb.wasm',
}
Path(sys.argv[2]).write_bytes(b'\0'.join(path for path in paths if path and path not in excluded) + b'\0')
PY
tar -C "$root" --null --verbatim-files-from -T "$work/source-paths" \
  --mtime='@0' --owner=0 --group=0 --numeric-owner \
  --mode='u+rwX,go+rX,go-w' -cf "$work/source.tar"

export RETROM_HOST_UID="$(id -u)" RETROM_HOST_GID="$(id -g)"
if ! docker run --rm --platform linux/amd64 --hostname retrom-samcoupe \
  --env RETROM_HOST_UID --env RETROM_HOST_GID \
  --volume "$work/source.tar:/source.tar:ro" \
  --volume "$root/.github/rpg-runtime:/recipe:ro" \
  --volume "$work/work:/work" \
  --volume "$work/raw:/output" \
  emscripten/emsdk@sha256:af45409f3199d88db4b1b03af0098532c8fb33a375ac257463eeb0a622870d06 \
  /recipe/build-in-container.sh >"$work/build.log" 2>&1; then
  tail -200 "$work/build.log" >&2
  exit 1
fi
test "$source_digest" = "$(python3 "$root/.github/rpg-runtime/candidate_descriptor.py" digest "$output")"
test "$(find "$work/raw" -maxdepth 1 -type f | wc -l)" -eq 3
tar -C "$work/raw" --mtime='@0' --owner=0 --group=0 --numeric-owner \
  --mode='u+rwX,go+rX,go-w' -cf "$work/web.tar" \
  samcoupeweb.js samcoupeweb.wasm samcoupeweb.data
gzip -n -c "$work/web.tar" > "$output/samcoupeweb-wasm.data"
install -m 0644 "$root/License.txt" "$output/LICENSE"
gzip -n -c "$work/source.tar" > "$output/source.tar.gz"
python3 "$root/.github/rpg-runtime/candidate_descriptor.py" finalize "$output" --core-id samcoupeweb
