# syntax=docker/dockerfile:1.6

# Base image with build essentials; choose a stable Debian for C++ and Go toolchains
FROM debian:bookworm-slim

# Configure non-interactive apt
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools, curl, git, and ca-certificates for fetching Go toolchain and building C++ parts
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      make \
      cmake \
      pkg-config \
      git \
      ca-certificates \
      curl \
      bash \
      openssl \
    && rm -rf /var/lib/apt/lists/*

# Install Go via official tarball for predictable version; keep it cache-friendly.
# You can adjust GOVERSION if needed; default to 1.22.x which supports go.mod in repo.
ARG GOVERSION=1.22.7
ARG GOOS=linux
ARG GOARCH=amd64
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) GOARCH=amd64 ;; \
      arm64) GOARCH=arm64 ;; \
      armhf) GOARCH=armv6l ;; \
      armel) GOARCH=armv6l ;; \
      i386) GOARCH=386 ;; \
      ppc64el) GOARCH=ppc64le ;; \
      s390x) GOARCH=s390x ;; \
      *) echo "Unsupported architecture: $arch" && exit 1 ;; \
    esac; \
    curl -fsSL "https://go.dev/dl/go${GOVERSION}.${GOOS}-${GOARCH}.tar.gz" -o /tmp/go.tgz; \
    tar -C /usr/local -xzf /tmp/go.tgz; \
    rm -f /tmp/go.tgz; \
    go version

# Set workdir and copy the repository (use .dockerignore to narrow copy if needed)
WORKDIR /app
COPY . /app

# Pre-download Go modules for CLIs to leverage Docker layer caching
# rdkb-cli
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    if [ -f /app/src/rdkb-cli/go.mod ]; then \
      cd /app/src/rdkb-cli && go mod download; \
    fi

# fynecli (optional; exists in repo)
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    if [ -f /app/src/fynecli/go.mod ]; then \
      cd /app/src/fynecli && go mod download || true; \
    fi

# Default command prints versions and help to validate environment
CMD ["/bin/bash", "-lc", "echo 'Go toolchain:' && go version && echo 'Verify rdkb-cli:' && cd /app/src/rdkb-cli && GO111MODULE=on go run . --help || true"]
