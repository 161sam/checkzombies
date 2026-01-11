#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# checkzombies installer (GitHub Releases) – checksum verified
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/scripts/install.sh | sudo bash
#   curl -fsSL .../install.sh | sudo bash -s -- --version v1.0.0 --method deb
#
# Options:
#   --version vX.Y.Z   Pin release tag (default: latest)
#   --method single|deb  Install method (default: single)
#   --prefix /usr/local  Prefix for single-file install (default: /usr/local)
#   --bin-dir /usr/local/bin Override binary dir
#   --dry-run          Don't write, just print actions

REPO="${REPO:-${GITHUB_REPOSITORY:-}}"
if [[ -z "${REPO}" ]]; then
  # Try to infer from origin if running from a checkout, otherwise require env
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    origin="$(git remote get-url origin 2>/dev/null || true)"
    # supports https://github.com/owner/repo(.git) and git@github.com:owner/repo(.git)
    REPO="$(echo "$origin" | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')"
  fi
fi

if [[ -z "${REPO}" ]]; then
  echo "ERROR: Unable to determine GitHub repo. Set REPO=owner/repo" >&2
  exit 1
fi

TAG="latest"
METHOD="single"
PREFIX="/usr/local"
BIN_DIR=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      TAG="${2:-}"; shift 2 ;;
    --method)
      METHOD="${2:-}"; shift 2 ;;
    --prefix)
      PREFIX="${2:-}"; shift 2 ;;
    --bin-dir)
      BIN_DIR="${2:-}"; shift 2 ;;
    --dry-run)
      DRY_RUN=1; shift ;;
    -h|--help)
      cat <<EOF
checkzombies install.sh
Repo: ${REPO}

Options:
  --version vX.Y.Z       Pin release tag (default: latest)
  --method single|deb    Install method (default: single)
  --prefix /usr/local    Prefix for single install (default: /usr/local)
  --bin-dir <dir>        Override bin dir (default: <prefix>/bin)
  --dry-run              Print actions only
EOF
      exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 1 ;;
  esac
done

if [[ -z "$BIN_DIR" ]]; then
  BIN_DIR="${PREFIX}/bin"
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  if [[ "$METHOD" == "deb" && "$(id -u)" -ne 0 ]]; then
    echo "ERROR: --method deb requires root (sudo) to install packages." >&2
    exit 1
  fi
  if [[ "$METHOD" == "single" && "$(id -u)" -ne 0 ]]; then
    if [[ ! -w "$BIN_DIR" ]]; then
      echo "ERROR: ${BIN_DIR} is not writable. Use sudo or set --prefix/--bin-dir." >&2
      exit 1
    fi
  fi
fi

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing command: $1" >&2; exit 1; }; }
need_cmd curl
need_cmd sha256sum
need_cmd install
need_cmd uname

tmp="$(mktemp -d)"
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

api_base="https://api.github.com/repos/${REPO}/releases"
if [[ "${TAG}" == "latest" ]]; then
  rel_json="${tmp}/release.json"
  curl -fsSL "${api_base}/latest" -o "${rel_json}"
else
  rel_json="${tmp}/release.json"
  curl -fsSL "${api_base}/tags/${TAG}" -o "${rel_json}"
fi

asset_url() {
  local name="$1"
  # extract browser_download_url for asset by name
  python3 - <<PY 2>/dev/null || true
import json,sys
j=json.load(open("${rel_json}"))
for a in j.get("assets",[]):
  if a.get("name")==sys.argv[1]:
    print(a.get("browser_download_url",""))
    break
PY
}

# prefer python3 if present; otherwise fallback to grep/sed (less robust)
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required for robust GitHub release parsing." >&2
  echo "Install python3 or manually download assets from the release." >&2
  exit 1
fi

# Determine version from tag_name if needed (for deb filename)
tag_name="$(python3 - <<PY
import json
j=json.load(open("${rel_json}"))
print(j.get("tag_name",""))
PY
)"
ver="${tag_name#v}"

if [[ -z "$ver" || "$ver" == "$tag_name" && "$TAG" != "latest" ]]; then
  # If tag didn't start with v, still use it
  ver="$tag_name"
fi

# asset names
single_name="checkzombies"
sums_name="SHA256SUMS"

single_url="$(asset_url "$single_name")"
sums_url="$(asset_url "$sums_name")"

deb_name="$(python3 - <<PY
import json
j=json.load(open("${rel_json}"))
ver="${ver}"
for a in j.get("assets",[]):
  name=a.get("name","")
  if name.startswith(f"checkzombies_{ver}") and name.endswith("_all.deb"):
    print(name)
    break
PY
)"

deb_url="$(python3 - <<PY
import json
j=json.load(open("${rel_json}"))
target="${deb_name}"
for a in j.get("assets",[]):
  if a.get("name")==target:
    print(a.get("browser_download_url",""))
    break
PY
)"

if [[ -z "$sums_url" ]]; then
  echo "ERROR: SHA256SUMS asset not found in release (${tag_name})" >&2
  exit 1
fi

curl -fsSL "$sums_url" -o "${tmp}/SHA256SUMS"

verify_asset() {
  local fname="$1"
  (cd "$tmp" && sha256sum -c "SHA256SUMS" --ignore-missing | grep -E "^\Q${fname}\E: OK$" >/dev/null)
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    eval "$@"
  fi
}

if [[ "$METHOD" == "single" ]]; then
  if [[ -z "$single_url" ]]; then
    echo "ERROR: asset '${single_name}' not found in release (${tag_name})" >&2
    exit 1
  fi
  curl -fsSL "$single_url" -o "${tmp}/${single_name}"
  chmod +x "${tmp}/${single_name}"

  if ! verify_asset "${single_name}"; then
    echo "ERROR: checksum verification failed for ${single_name}" >&2
    exit 1
  fi

  run "install -d -m 0755 '${BIN_DIR}'"
  run "install -m 0755 '${tmp}/${single_name}' '${BIN_DIR}/checkzombies'"

  echo "Installed: ${BIN_DIR}/checkzombies"
  echo "Verify:   checkzombies --version"
  exit 0
fi

if [[ "$METHOD" == "deb" ]]; then
  need_cmd dpkg
  if [[ -z "$deb_name" || -z "$deb_url" ]]; then
    echo "ERROR: .deb asset not found in release (${tag_name})" >&2
    exit 1
  fi
  curl -fsSL "$deb_url" -o "${tmp}/${deb_name}"

  if ! verify_asset "${deb_name}"; then
    echo "ERROR: checksum verification failed for ${deb_name}" >&2
    exit 1
  fi

  run "dpkg -i '${tmp}/${deb_name}' || true"
  # attempt to fix deps if apt is available
  if command -v apt-get >/dev/null 2>&1; then
    run "apt-get -y -f install"
  fi

  echo "Installed via .deb."
  echo "Verify: checkzombies --version"
  exit 0
fi

echo "ERROR: unknown --method '${METHOD}' (use single|deb)" >&2
exit 1
