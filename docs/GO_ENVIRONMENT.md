# Go Toolchain Environment

This repository includes Go-based CLIs such as `src/rdkb-cli` and `src/fynecli`. The container image and devcontainer are configured to install a recent Go toolchain and build essentials.

## Quick verification (host with Go installed)
- Ensure `go` is on `PATH`:
  go version

- Verify the RDKB CLI compiles and prints help:
  cd src/rdkb-cli
  GO111MODULE=on go run . --help

- Run the RDKB CLI as server:
  cd src/rdkb-cli
  GO111MODULE=on go run . --host 0.0.0.0 --port 3001

## Docker-based workflow

Build the image:
  make docker-build

Verify Go and the CLI inside the container:
  make docker-verify

The container's default `CMD` prints the Go version and rdkb-cli help to confirm the toolchain is present.

## Notes
- Go module downloads are cached in Docker layers for faster rebuilds.
- The image installs required build tools for the C++ components without changing the existing autotools/cmake setup.
