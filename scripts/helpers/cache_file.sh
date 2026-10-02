#!/usr/bin/env bash

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <target-file> <url> <sha256> [extract-dir]"
  exit 1
fi

TARGET="$1"
URL="$2"
SHA256="$3"
EXTRACT_DIR="$4"

TARGET_DIR="$(dirname "$TARGET")"
FILENAME="$(basename "$TARGET")"
DOWNLOAD_RETRIES="${DOWNLOAD_RETRIES:-5}"
DOWNLOAD_RETRY_DELAY="${DOWNLOAD_RETRY_DELAY:-5}"

set -e
mkdir -p "$TARGET_DIR"

if [[ ! -f "$TARGET" ]]; then
  echo ">> Downloading $FILENAME..."
  attempt=1
  while true; do
    rm -f "$TARGET"
    if wget --timeout=30 -O "$TARGET" "$URL"; then
      break
    fi

    if (( attempt >= DOWNLOAD_RETRIES )); then
      echo "[!] Failed to download $FILENAME after $DOWNLOAD_RETRIES attempts"
      exit 1
    fi

    echo "[!] Download failed for $FILENAME (attempt $attempt/$DOWNLOAD_RETRIES), retrying in ${DOWNLOAD_RETRY_DELAY}s..."
    attempt=$((attempt + 1))
    sleep "$DOWNLOAD_RETRY_DELAY"
  done
fi

echo ">> Verifying $TARGET checksum..."
if ! echo "$SHA256  $TARGET" | sha256sum --check --status; then
  echo "[!] SHA256 checksum mismatch for $FILENAME"
  exit 1
fi

if [[ -z "$EXTRACT_DIR" ]]; then
  exit 0
fi

rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"

case "$FILENAME" in
  *.tar.gz)
    echo ">> Extracting $FILENAME..."
    tar -xzf "$TARGET" -C "$EXTRACT_DIR"
    ;;

  *.tar.xz)
    echo ">> Extracting $FILENAME..."
    tar -xJf "$TARGET" -C "$EXTRACT_DIR"
    ;;

  *.zip)
    echo ">> Extracting $FILENAME..."
    unzip -o "$TARGET" -d "$EXTRACT_DIR"
    ;;

  *)
    ;;
esac
