#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIT_SRC_DIR="${SCRIPT_DIR}/../packaging/systemd"
UNIT_DST_DIR="/etc/systemd/system"

usage() {
  cat <<'USAGE'
Usage: systemd_install.sh [--watch|--auto|--both|--uninstall]

Options:
  --watch     Install and enable checkzombies.service (--watch)
  --auto      Install and enable checkzombies.timer (--auto)
  --both      Install and enable both service and timer
  --uninstall Disable and remove installed unit files
  -h, --help  Show this help
USAGE
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing command: $1" >&2; exit 1; }
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: must be run as root" >&2
    exit 1
  fi
}

install_watch=0
install_auto=0
uninstall=0

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --watch)
      install_watch=1; shift ;;
    --auto)
      install_auto=1; shift ;;
    --both)
      install_watch=1; install_auto=1; shift ;;
    --uninstall)
      uninstall=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 1 ;;
  esac
done

if [[ "${uninstall}" -eq 1 ]] && { [[ "${install_watch}" -eq 1 ]] || [[ "${install_auto}" -eq 1 ]]; }; then
  echo "ERROR: --uninstall cannot be combined with install flags" >&2
  exit 1
fi

need_cmd systemctl
need_cmd install
require_root

if [[ ! -d "${UNIT_SRC_DIR}" ]]; then
  echo "ERROR: unit source directory not found: ${UNIT_SRC_DIR}" >&2
  exit 1
fi

install_unit() {
  local filename="$1"
  install -m 0644 "${UNIT_SRC_DIR}/${filename}" "${UNIT_DST_DIR}/${filename}"
}

if [[ "${uninstall}" -eq 1 ]]; then
  if [[ -f "${UNIT_DST_DIR}/checkzombies.service" ]]; then
    systemctl disable --now checkzombies.service >/dev/null 2>&1 || true # ignore missing/disabled units
    rm -f "${UNIT_DST_DIR}/checkzombies.service"
  fi

  if [[ -f "${UNIT_DST_DIR}/checkzombies-auto.service" ]]; then
    rm -f "${UNIT_DST_DIR}/checkzombies-auto.service"
  fi

  if [[ -f "${UNIT_DST_DIR}/checkzombies.timer" ]]; then
    systemctl disable --now checkzombies.timer >/dev/null 2>&1 || true # ignore missing/disabled units
    rm -f "${UNIT_DST_DIR}/checkzombies.timer"
  fi

  systemctl daemon-reload
  echo "Uninstalled checkzombies systemd units."
  exit 0
fi

if [[ "${install_watch}" -eq 0 && "${install_auto}" -eq 0 ]]; then
  usage
  exit 1
fi

if [[ "${install_watch}" -eq 1 ]]; then
  install_unit "checkzombies.service"
fi

if [[ "${install_auto}" -eq 1 ]]; then
  install_unit "checkzombies-auto.service"
  install_unit "checkzombies.timer"
fi

systemctl daemon-reload

if [[ "${install_watch}" -eq 1 ]]; then
  systemctl enable --now checkzombies.service
fi

if [[ "${install_auto}" -eq 1 ]]; then
  systemctl enable --now checkzombies.timer
fi

echo "Installed checkzombies systemd units."
