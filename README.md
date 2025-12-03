The documentation is available in Unified-Wifi-Mesh file under docs directory

Running the rdkb-cli (no Go at runtime)
- Build once (during CI or locally where Go is available):
  cd src/rdkb-cli
  go build -o bin/rdkb-cli .

- Then start the CLI/web dashboard without needing the Go toolchain:
  ./run-rdkb-cli.sh

If you cannot build during CI and Go is present at runtime, the launcher will try to build on first run. If neither a binary nor Go is available, the launcher prints build instructions and exits gracefully so container startup does not fail.
