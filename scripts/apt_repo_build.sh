#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Builds a minimal signed APT repo inside docs/apt
# Requires: dpkg-scanpackages, apt-ftparchive, gpg

version="${1:-}"
deb_path="${2:-}"          # dist/checkzombies_<ver>_all.deb
apt_root="${3:-docs/apt}"  # output root (published by Pages)

if [[ -z "$version" || -z "$deb_path" ]]; then
  echo "Usage: $0 <version> <deb_path> [apt_root]" >&2
  exit 1
fi

command -v dpkg-scanpackages >/dev/null 2>&1 || { echo "Missing dpkg-scanpackages" >&2; exit 1; }
command -v apt-ftparchive    >/dev/null 2>&1 || { echo "Missing apt-ftparchive" >&2; exit 1; }
command -v gpg               >/dev/null 2>&1 || { echo "Missing gpg" >&2; exit 1; }

codename="${APT_CODENAME:-stable}"
component="main"
arch="all"

mkdir -p "${apt_root}/pool/${component}"
mkdir -p "${apt_root}/dists/${codename}/${component}/binary-${arch}"

cp -f "${deb_path}" "${apt_root}/pool/${component}/"

# Packages / Packages.gz
pushd "${apt_root}" >/dev/null
dpkg-scanpackages "pool/${component}" /dev/null > "dists/${codename}/${component}/binary-${arch}/Packages"
gzip -n -f "dists/${codename}/${component}/binary-${arch}/Packages"

# Release file
apt-ftparchive release "dists/${codename}" > "dists/${codename}/Release"

# Sign Release (Release.gpg + InRelease)
# Use GPG key from env:
#   APT_GPG_KEY_ID (fingerprint or keyid)
# If using gpg with imported private key in CI, it will sign non-interactively.

key_id="${APT_GPG_KEY_ID:-}"
if [[ -z "$key_id" ]]; then
  echo "ERROR: APT_GPG_KEY_ID is required for signing." >&2
  exit 1
fi

gpg --batch --yes --local-user "${key_id}" -abs -o "dists/${codename}/Release.gpg" "dists/${codename}/Release"
gpg --batch --yes --local-user "${key_id}" --clearsign -o "dists/${codename}/InRelease" "dists/${codename}/Release"
popd >/dev/null

echo "APT repo built at: ${apt_root}"
