#!/usr/bin/env bash
# Simple launcher for rdkb-cli that avoids relying on 'go run' at runtime.
# Priority:
# 1) If a compiled binary exists (bin/rdkb-cli), run it.
# 2) If 'go' toolchain is available, attempt to build then run the binary.
# 3) Otherwise, print a helpful message and exit gracefully.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BIN_DIR="${SCRIPT_DIR}/bin"
BIN_PATH="${BIN_DIR}/rdkb-cli"

mkdir -p "${BIN_DIR}"

if [[ -x "${BIN_PATH}" ]]; then
  echo "[rdkb-cli] Using prebuilt binary: ${BIN_PATH}"
  exec "${BIN_PATH}" "$@"
fi

if command -v go >/dev/null 2>&1; then
  echo "[rdkb-cli] 'go' found. Building binary..."
  # Build static-ish binary suitable for this environment
  cd "${SCRIPT_DIR}"
  # module path is in this directory; ensure modules are ready
  export CGO_ENABLED=1
  export GO111MODULE=on
  # Build the server binary
  go build -o "${BIN_PATH}" ./...
  echo "[rdkb-cli] Build complete. Starting ${BIN_PATH}"
  exec "${BIN_PATH}" "$@"
fi

cat >&2 <<'EOF'
[rdkb-cli] No Go toolchain detected and no prebuilt binary found.

To build the rdkb-cli once (recommended for CI/build):
  1) Ensure Go >= 1.19 and build essentials are available.
  2) From repository root:
       cd src/rdkb-cli
       go build -o bin/rdkb-cli

After that, start with:
  src/rdkb-cli/run-rdkb-cli.sh

Alternatively, integrate the binary build into your CI image so runtime does not require 'go run'.
EOF
exit 0
