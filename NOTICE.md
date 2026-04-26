# Notice and Attribution

This repository is a helper installer/feed for Keenetic + Entware setups.
It is not the original NeoFit project and does not claim ownership of NeoFit,
sing-box, Xray, Entware, Keenetic, or their trademarks.

## Upstream projects and third-party packages

- NeoFit is maintained by `pegakmop`.
- The original public NeoFit materials are available at:
  `https://github.com/pegakmop/neofit`
- The public Keenetic package feed layout used as a reference is available at:
  `https://github.com/pegakmop/release`
- sing-box is a separate upstream project:
  `https://github.com/SagerNet/sing-box`
- Xray-core is a separate upstream project:
  `https://github.com/XTLS/Xray-core`
- Entware packages and base system components belong to their respective
  upstream maintainers.

## What this repository adds

This repository adds:

- a one-command installer wrapper;
- a local/GitHub-hosted OPKG feed layout;
- compatibility helper scripts for NeoFit-generated sing-box configs on
  sing-box 1.13.x;
- documentation for Keenetic installation and verification.

## Important note about redistribution

Some files in `local-feed/release/keenetic/` are third-party `.ipk` package
artifacts. Their redistribution is governed by the licenses and terms of their
respective upstream projects and package maintainers.

If an upstream author asks to remove or change mirrored package artifacts, this
repository should be updated accordingly.
