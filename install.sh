#!/bin/sh
set -u

# One-command GitHub installer entrypoint.
# It downloads the real installer from local-feed/ and points it to this repo feed.

REPO_RAW_BASE="${NEOFIT_BASE_URL:-https://raw.githubusercontent.com/clan122222/neo/main/local-feed}"
TMP_INSTALLER="/opt/tmp/install-neofit-github.sh"

ensure_download_tools() {
  if command -v opkg >/dev/null 2>&1; then
    echo "Preparing HTTPS download tools..."
    opkg update || true
    opkg install wget-ssl ca-certificates || opkg install curl ca-certificates || true
  fi
}

fetch() {
  url="$1"
  out="$2"
  rm -f "$out"
  if command -v wget >/dev/null 2>&1; then
    wget -O "$out" "$url"
  elif command -v curl >/dev/null 2>&1; then
    curl -fL -o "$out" "$url"
  else
    echo "ERROR: neither wget nor curl found in Entware."
    echo "Install wget/curl first or use the uploaded local-feed mode."
    exit 1
  fi
}

echo "NeoFit GitHub installer"
echo "Feed: $REPO_RAW_BASE"
mkdir -p /opt/tmp
ensure_download_tools
fetch "$REPO_RAW_BASE/install-neofit-local.sh" "$TMP_INSTALLER"
chmod +x "$TMP_INSTALLER"
BASE_URL="$REPO_RAW_BASE" "$TMP_INSTALLER"
