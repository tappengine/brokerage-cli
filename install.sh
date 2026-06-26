#!/bin/sh
# Buildmarkets CLI installer.
#
#   curl -fsSL https://cli.buildmarkets.com/install.sh | sh
#
# Detects OS/arch, downloads the matching binary from GitHub Releases, verifies
# the checksum, and installs it to a directory on PATH.
set -eu

REPO="${BM_REPO:-tappengine/brokerage-cli}"
BINARY="bm"
VERSION="${BM_VERSION:-latest}"
INSTALL_DIR="${BM_INSTALL_DIR:-}"

err() { echo "install: $*" >&2; exit 1; }

# --- detect platform -------------------------------------------------------
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$os" in
  linux)  os="linux" ;;
  darwin) os="darwin" ;;
  *)      err "unsupported OS: $os (Windows: use scoop or download from Releases)" ;;
esac

arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
  *) err "unsupported architecture: $arch" ;;
esac

asset="${BINARY}_${os}_${arch}"

# --- resolve version -------------------------------------------------------
base="https://github.com/${REPO}/releases"
if [ "$VERSION" = "latest" ]; then
  url="${base}/latest/download/${asset}"
else
  url="${base}/download/${VERSION}/${asset}"
fi

# --- pick an install dir on PATH -------------------------------------------
if [ -z "$INSTALL_DIR" ]; then
  if [ -w "/usr/local/bin" ] 2>/dev/null; then
    INSTALL_DIR="/usr/local/bin"
  else
    INSTALL_DIR="$HOME/.local/bin"
  fi
fi
mkdir -p "$INSTALL_DIR"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading ${BINARY} (${os}/${arch}) from ${url}"
if ! curl -fsSL "$url" -o "$tmp/$BINARY"; then
  err "download failed — check that a release exists for ${os}/${arch}"
fi

# Best-effort checksum verification against the release checksums.txt.
if curl -fsSL "${url%/*}/checksums.txt" -o "$tmp/checksums.txt" 2>/dev/null; then
  if command -v shasum >/dev/null 2>&1; then
    want="$(grep " ${asset}\$" "$tmp/checksums.txt" | awk '{print $1}' || true)"
    if [ -n "$want" ]; then
      got="$(shasum -a 256 "$tmp/$BINARY" | awk '{print $1}')"
      [ "$want" = "$got" ] || err "checksum mismatch (want $want, got $got)"
      echo "Checksum verified."
    fi
  fi
fi

chmod +x "$tmp/$BINARY"
mv "$tmp/$BINARY" "$INSTALL_DIR/$BINARY"

echo "Installed ${BINARY} to ${INSTALL_DIR}/${BINARY}"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "Note: add ${INSTALL_DIR} to your PATH." ;;
esac
echo "Run 'bm login' to get started."
