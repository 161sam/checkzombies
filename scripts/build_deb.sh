#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

version="${1:-}"
out_deb="${2:-}"

if [[ -z "$version" || -z "$out_deb" ]]; then
  echo "Usage: $0 <version> <out_deb>" >&2
  exit 1
fi

name="checkzombies"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="${root}/dist/_debroot"
mkdir -p "${work}"

rm -rf "${work:?}/"*
mkdir -p "${work}/DEBIAN"
mkdir -p "${work}/usr/bin"
mkdir -p "${work}/usr/share/man/man1"
mkdir -p "${work}/usr/share/doc/${name}"

install -m 0755 "${root}/bin/checkzombies" "${work}/usr/bin/checkzombies"

# manpage: gzip -n for reproducibility (no timestamps)
if [[ -f "${root}/man/man1/checkzombies.1" ]]; then
  gzip -n -c "${root}/man/man1/checkzombies.1" > "${work}/usr/share/man/man1/checkzombies.1.gz"
fi

# docs
if [[ -f "${root}/README.md" ]]; then
  install -m 0644 "${root}/README.md" "${work}/usr/share/doc/${name}/README.md"
fi
if [[ -f "${root}/LICENSE" ]]; then
  install -m 0644 "${root}/LICENSE" "${work}/usr/share/doc/${name}/LICENSE"
fi
cat > "${work}/usr/share/doc/${name}/copyright" <<EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: ${name}
Source: https://github.com/${GITHUB_REPOSITORY:-<owner>/<repo>}

Files: *
Copyright: 2026
License: MIT
EOF

# control (Architecture all, bash only)
cat > "${work}/DEBIAN/control" <<EOF
Package: ${name}
Version: ${version}
Section: admin
Priority: optional
Architecture: all
Maintainer: ${DEB_MAINTAINER:-CheckZombies Maintainers}
Depends: bash (>= 4.0), procps
Recommends: systemd
Description: Zombie Process Manager (find & cleanup zombie processes)
 checkzombies finds zombie processes, shows PID/PPID/service info, and offers
 safe cleanup flows with standardized signal escalation.
EOF

# simple postinst: update man db if present
cat > "${work}/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
if command -v mandb >/dev/null 2>&1; then
  mandb -q || true
fi
exit 0
EOF
chmod 0755 "${work}/DEBIAN/postinst"

# dpkg-deb build
mkdir -p "$(dirname "$out_deb")"
dpkg-deb --build --root-owner-group "${work}" "${out_deb}"
echo "Built ${out_deb}"
