# Simple helper Makefile to build a dev image and verify Go CLI runs
# Does not alter existing autotools/C++ build; adds convenience targets.

IMAGE_NAME ?= unified-wifi-mesh-5669:dev

# PUBLIC_INTERFACE
verify-go:
	@which go >/dev/null 2>&1 || (echo "go not found on PATH"; exit 1)
	@go version
	@echo "Running rdkb-cli help to verify it compiles/starts..."
	cd src/rdkb-cli && GO111MODULE=on go run . --help >/dev/null || (echo "rdkb-cli failed to run"; exit 1)
	@echo "Go toolchain and rdkb-cli verified."

# PUBLIC_INTERFACE
docker-build:
	@docker build -t $(IMAGE_NAME) .

# PUBLIC_INTERFACE
docker-verify:
	@docker run --rm -it $(IMAGE_NAME) bash -lc "go version && cd /app/src/rdkb-cli && GO111MODULE=on go run . --help >/dev/null && echo 'Verified inside container.'"
