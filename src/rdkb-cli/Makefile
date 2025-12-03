# Minimal helper Makefile to build the rdkb-cli binary.
# This does not alter the autotools C++ build; it's a local convenience for the Go CLI.

BIN_DIR := bin
BIN := $(BIN_DIR)/rdkb-cli

.PHONY: all build clean run

all: build

build:
	mkdir -p $(BIN_DIR)
	CGO_ENABLED=1 GO111MODULE=on go build -o $(BIN) .

run: build
	./$(BIN)

clean:
	rm -rf $(BIN_DIR)
