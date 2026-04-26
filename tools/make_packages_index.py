#!/usr/bin/env python3
"""Build OPKG Packages and Packages.gz indexes for the local NeoFit feed."""

from __future__ import annotations

import gzip
import hashlib
import io
import os
import tarfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FEED_ROOT = ROOT / "local-feed"
ARCH_DIRS = [
    FEED_ROOT / "release" / "keenetic" / "aarch64-k3.10",
    FEED_ROOT / "release" / "keenetic" / "mipselsf-k3.4",
    FEED_ROOT / "release" / "keenetic" / "mipssf-k3.4",
]


def read_ar_members(path: Path) -> dict[str, bytes]:
    data = path.read_bytes()
    if not data.startswith(b"!<arch>\n"):
        raise ValueError(f"{path.name}: not an ar/ipk archive")
    offset = 8
    members: dict[str, bytes] = {}
    while offset + 60 <= len(data):
        header = data[offset : offset + 60]
        offset += 60
        name = header[:16].decode("utf-8", "replace").strip()
        size = int(header[48:58].decode("ascii").strip())
        body = data[offset : offset + size]
        offset += size
        if offset % 2:
            offset += 1
        name = name.rstrip("/")
        members[name] = body
    return members


def extract_control(ipk: Path) -> str:
    raw = ipk.read_bytes()
    if raw.startswith(b"!<arch>\n"):
        members = read_ar_members(ipk)
    else:
        members = {}
        with tarfile.open(ipk, mode="r:*") as outer:
            for member in outer.getmembers():
                if member.isfile():
                    members[member.name.lstrip("./")] = outer.extractfile(member).read()
    control_blob = members.get("control.tar.gz")
    if control_blob is None:
        raise ValueError(f"{ipk.name}: control.tar.gz not found")
    with tarfile.open(fileobj=io.BytesIO(control_blob), mode="r:gz") as tar:
        member = tar.getmember("./control")
        return tar.extractfile(member).read().decode("utf-8", "replace")


def package_entry(ipk: Path, base: Path) -> str:
    control = extract_control(ipk).strip()
    rel = ipk.relative_to(base).as_posix()
    data = ipk.read_bytes()
    sha256 = hashlib.sha256(data).hexdigest()
    return f"{control}\nFilename: {rel}\nSize: {len(data)}\nSHA256sum: {sha256}\n"


def build_index(arch_dir: Path) -> None:
    arch_dir.mkdir(parents=True, exist_ok=True)
    packages = []
    for ipk in sorted(arch_dir.glob("*.ipk")):
        try:
            packages.append(package_entry(ipk, arch_dir))
        except Exception as exc:
            print(f"skip {ipk}: {exc}")
    content = "\n".join(packages)
    (arch_dir / "Packages").write_text(content, encoding="utf-8", newline="\n")
    with gzip.open(arch_dir / "Packages.gz", "wb") as fh:
        fh.write(content.encode("utf-8"))
    print(f"{arch_dir}: {len(packages)} package(s)")


def main() -> None:
    (FEED_ROOT / "scripts").mkdir(parents=True, exist_ok=True)
    for arch_dir in ARCH_DIRS:
        build_index(arch_dir)


if __name__ == "__main__":
    main()
