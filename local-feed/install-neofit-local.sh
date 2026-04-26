#!/bin/sh
set -u

BASE_URL="${BASE_URL:-${1:-}}"
LOCAL_FEED_DIR="${LOCAL_FEED_DIR:-}"
if [ -z "$BASE_URL" ] && [ -z "$LOCAL_FEED_DIR" ]; then
  echo "Usage over HTTP: BASE_URL=http://PC_IP:8000 sh -c \"\$(wget -O- http://PC_IP:8000/install-neofit-local.sh)\""
  echo "Usage from uploaded files: LOCAL_FEED_DIR=/opt/tmp/neofit-local-feed /opt/tmp/install-neofit-local.sh"
  exit 1
fi

[ -n "$BASE_URL" ] && BASE_URL="${BASE_URL%/}"
TMP_DIR="/opt/tmp/neofit-local-install"
mkdir -p "$TMP_DIR" /opt/etc/opkg
OPKG_INSTALL_FLAGS="--force-downgrade"
[ -n "$LOCAL_FEED_DIR" ] && OPKG_INSTALL_FLAGS="--force-downgrade --nodeps"

if [ ! -f /opt/etc/entware_release ]; then
  echo "Entware release file not found: /opt/etc/entware_release"
  exit 1
fi

ARCH="$(grep '^arch=' /opt/etc/entware_release | cut -d= -f2)"
case "$ARCH" in
  aarch64) FEED_ARCH="aarch64-k3.10" ;;
  mipsel) FEED_ARCH="mipselsf-k3.4" ;;
  mips) FEED_ARCH="mipssf-k3.4" ;;
  *)
    echo "Unsupported Entware arch: $ARCH"
    exit 1
    ;;
esac

FEED_URL=""
[ -n "$BASE_URL" ] && FEED_URL="$BASE_URL/release/keenetic/$FEED_ARCH"
LOCAL_ARCH_DIR=""
if [ -n "$LOCAL_FEED_DIR" ]; then
  LOCAL_ARCH_DIR="$LOCAL_FEED_DIR/release/keenetic/$FEED_ARCH"
  echo "Using uploaded NeoFit feed: $LOCAL_ARCH_DIR"
else
  echo "Using local NeoFit feed: $FEED_URL"
fi

fetch() {
  url="$1"
  out="$2"
  rm -f "$out"
  if [ -x /opt/libexec/wget-ssl ]; then
    /opt/libexec/wget-ssl -O "$out" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$out" "$url"
  elif command -v curl >/dev/null 2>&1; then
    curl -fL -o "$out" "$url"
  else
    echo "Neither wget nor curl found"
    return 1
  fi
}

install_first_match() {
  pattern="$1"
  package_name="$2"
  list_file="$TMP_DIR/Packages"
  file_name="$(awk -v pkg="$package_name" -v pat="$pattern" '
    $1 == "Package:" && $2 == pkg { in_pkg=1; next }
    in_pkg && $1 == "Filename:" && $2 ~ pat { print $2; exit }
    NF == 0 { in_pkg=0 }
  ' "$list_file")"
  if [ -z "$file_name" ]; then
    echo "Package not found in local feed: $package_name / $pattern"
    return 1
  fi
  local_file="$TMP_DIR/$(basename "$file_name")"
  if [ -n "$LOCAL_ARCH_DIR" ]; then
    cp "$LOCAL_ARCH_DIR/$file_name" "$local_file"
  else
    fetch "$FEED_URL/$file_name" "$local_file"
  fi
  opkg install $OPKG_INSTALL_FLAGS "$local_file"
}

install_optional_match() {
  pattern="$1"
  package_name="$2"
  install_first_match "$pattern" "$package_name" || echo "Optional package skipped: $package_name"
}

if [ -n "$LOCAL_ARCH_DIR" ]; then
  cp "$LOCAL_ARCH_DIR/Packages" "$TMP_DIR/Packages"
else
  fetch "$FEED_URL/Packages" "$TMP_DIR/Packages"
fi

echo "Installing local NeoFit packages..."
install_optional_match "ca-bundle_.*\\.ipk" "ca-bundle"
install_optional_match "xray-core_.*\\.ipk" "xray-core"
install_optional_match "xray_.*\\.ipk" "xray"
install_first_match "sing-box-go_.*\\.ipk" "sing-box-go" || exit 1
opkg flag hold sing-box-go 2>&1 || true
install_first_match "neofit_.*\\.ipk" "neofit" || exit 1

echo "Installing local compatibility helper..."
if [ -n "$LOCAL_FEED_DIR" ]; then
  cp "$LOCAL_FEED_DIR/scripts/nf-sb13-fix" /opt/bin/nf-sb13-fix
else
  fetch "$BASE_URL/scripts/nf-sb13-fix" /opt/bin/nf-sb13-fix
fi
chmod +x /opt/bin/nf-sb13-fix
if [ -n "$LOCAL_FEED_DIR" ]; then
  cp "$LOCAL_FEED_DIR/scripts/nf-sb13-watch" /opt/bin/nf-sb13-watch
else
  fetch "$BASE_URL/scripts/nf-sb13-watch" /opt/bin/nf-sb13-watch
fi
chmod +x /opt/bin/nf-sb13-watch
if [ -n "$LOCAL_FEED_DIR" ]; then
  cp "$LOCAL_FEED_DIR/scripts/S98nf-sb13-watch" /opt/etc/init.d/S98nf-sb13-watch
else
  fetch "$BASE_URL/scripts/S98nf-sb13-watch" /opt/etc/init.d/S98nf-sb13-watch
fi
chmod +x /opt/etc/init.d/S98nf-sb13-watch

echo "Writing local feed file for future manual installs..."
if [ -f /opt/etc/opkg/neofit.conf ]; then
  cp /opt/etc/opkg/neofit.conf "/opt/etc/opkg/neofit.conf.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
fi
if [ -n "$FEED_URL" ]; then
  echo "src/gz local-neofit $FEED_URL" > /opt/etc/opkg/neofit.conf
else
  echo "# local-neofit feed installed from uploaded files: $LOCAL_ARCH_DIR" > /opt/etc/opkg/neofit.conf
fi

echo "Trying sing-box 1.13 config migration..."
/opt/bin/nf-sb13-fix || true

if [ ! -f /opt/etc/xray/config.json ]; then
  echo "Creating default Xray config..."
  mkdir -p /opt/etc/xray
  cat > /opt/etc/xray/config.json <<'EOF'
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "proxy0",
      "protocol": "socks",
      "listen": "0.0.0.0",
      "port": 2080,
      "settings": {
        "auth": "noauth",
        "udp": true
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom"
    }
  ],
  "routing": {
    "rules": []
  }
}
EOF
fi

echo "Restarting services..."
/opt/etc/init.d/S99sing-box restart 2>&1 || true
/opt/etc/init.d/S98nf-sb13-watch restart 2>&1 || true
/opt/etc/init.d/S24xray restart 2>&1 || true
/opt/etc/init.d/S69neofit restart 2>&1 || true

echo "Status:"
/opt/etc/init.d/S99sing-box status 2>&1 || true
/opt/etc/init.d/S98nf-sb13-watch status 2>&1 || true
/opt/etc/init.d/S24xray status 2>&1 || true
/opt/etc/init.d/S69neofit status 2>&1 || true

echo "Installed versions:"
opkg list-installed 2>/dev/null | grep -E '^(neofit|sing-box-go|xray|xray-core)' || true
sing-box version 2>&1 | head -n 5 || true

echo "Done."
