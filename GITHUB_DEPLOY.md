# Publish NeoFit local feed to GitHub

This project can be published to GitHub so Keenetic downloads the installer and packages from GitHub instead of your PC.

Recommended simple layout:

- Push this whole `Neo_fit` folder to a GitHub repository.
- Use raw GitHub URLs with `BASE_URL=https://raw.githubusercontent.com/<USER>/<REPO>/main/local-feed`.

Example installer command on the router:

```sh
BASE_URL=https://raw.githubusercontent.com/<USER>/<REPO>/main/local-feed sh -c "$(wget -O- https://raw.githubusercontent.com/<USER>/<REPO>/main/local-feed/install-neofit-local.sh)"
```

If `wget` is broken on a fresh Entware install, upload the feed over SSH and run local mode:

```sh
LOCAL_FEED_DIR=/opt/tmp/neofit-local-feed /opt/tmp/install-neofit-local.sh
```

## Create the repository locally

Run from this folder:

```powershell
git init
git add README-local-installer.md GITHUB_DEPLOY.md serve-local-feed.ps1 tools local-feed
git commit -m "Add NeoFit Keenetic local feed"
git branch -M main
git remote add origin https://github.com/<USER>/<REPO>.git
git push -u origin main
```

## GitHub Pages option

GitHub Pages also works well. Publish the **contents of `local-feed/`** as the website root. Then the router command becomes:

```sh
BASE_URL=https://<USER>.github.io/<REPO> sh -c "$(wget -O- https://<USER>.github.io/<REPO>/install-neofit-local.sh)"
```

This has cleaner URLs and works like a normal OPKG feed:

```text
https://<USER>.github.io/<REPO>/release/keenetic/aarch64-k3.10/Packages.gz
```

## Important notes

- Current prepared packages are for `aarch64-k3.10`.
- `mipsel` and `mips` folders currently contain empty package indexes.
- `sing-box-go` is pinned to `1.13.4`.
- `nf-sb13-watch` is installed to automatically repair old NeoFit sing-box configs after saving.
- GitHub individual file limit is 100 MB; current `.ipk` files are below that.
