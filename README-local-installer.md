# NeoFit compatible local installer for Keenetic

This folder contains a local, PC-hosted compatible installer/feed for NeoFit on Keenetic + Entware.

This repository is not the original NeoFit project. NeoFit is maintained by its upstream author `pegakmop`; this kit only provides installer/feed packaging and sing-box 1.13.x compatibility helpers. See `NOTICE.md`.

Goal:

- The router downloads packages from your PC, not from public custom feeds.
- NeoFit can be installed from a local folder over HTTP.
- `sing-box-go` can be pinned to a chosen local version.
- A helper script can migrate NeoFit-generated sing-box configs for sing-box 1.13+.

Important limitation:

The public `pegakmop/neofit` repository does not include the Go backend source code, only README and HTML pages. Because of that, this kit does not rebuild NeoFit itself. It mirrors selected third-party `.ipk` package artifacts locally and adds compatibility scripts for the new sing-box config format.

## Layout

```text
local-feed/
  install-neofit-local.sh
  release/keenetic/aarch64-k3.10/*.ipk
  scripts/nf-sb13-fix
tools/
  make_packages_index.py
serve-local-feed.ps1
```

## How to use

### Option A: HTTP feed

```powershell
python .\tools\make_packages_index.py
```

2. Start local HTTP server on the PC:

```powershell
.\serve-local-feed.ps1
```

3. On the router, run the installer. Replace `PC_IP` with your PC address in the same LAN:

```sh
BASE_URL=http://PC_IP:8000 sh -c "$(wget -O- http://PC_IP:8000/install-neofit-local.sh)"
```

If `curl` exists on the router, this also works:

```sh
BASE_URL=http://PC_IP:8000 sh -c "$(curl -fsSL http://PC_IP:8000/install-neofit-local.sh)"
```

### Option B: Uploaded local feed

Use this when `wget`/`curl` on a fresh Entware install is broken or when you want zero package downloads from the router.

1. Upload the whole `local-feed` folder to:

```text
/opt/tmp/neofit-local-feed
```

2. Upload `local-feed/install-neofit-local.sh` to:

```text
/opt/tmp/install-neofit-local.sh
```

3. Run:

```sh
LOCAL_FEED_DIR=/opt/tmp/neofit-local-feed /opt/tmp/install-neofit-local.sh
```

In this mode the installer uses local `.ipk` files with `opkg --nodeps`, so OPKG does not fetch packages from Entware/custom feeds during this NeoFit install. Base Entware libraries must already be present.

## Sing-Box 1.13 compatibility

NeoFit may generate old sing-box config fields such as `sniff` inside inbound objects. sing-box 1.13 removed those fields.

This kit installs two helpers:

```sh
/opt/bin/nf-sb13-fix
/opt/bin/nf-sb13-watch
```

`nf-sb13-watch` runs as `/opt/etc/init.d/S98nf-sb13-watch` and automatically repairs `/opt/etc/sing-box/config.json` after NeoFit saves an old-format config, then restarts sing-box.

Manual repair is still available:

```sh
nf-sb13-fix && /opt/etc/init.d/S99sing-box restart
```

## Notes

- The current prepared feed is for `aarch64-k3.10`, matching your router.
- For `mipsel` or `mips`, add the corresponding `.ipk` files to `local-feed/release/keenetic/mipselsf-k3.4` or `local-feed/release/keenetic/mipssf-k3.4` and rerun the index builder.
- The installer installs local `.ipk` files directly, so the router does not need to fetch NeoFit from public custom repositories.
- Rights to NeoFit, sing-box, Xray, Entware, and package artifacts remain with their respective upstream authors and maintainers.
