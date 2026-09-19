#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
source "${KIT_ROOT}/config/calibration.env"
load_ros() {
  source /opt/ros/noetic/setup.bash
  [[ -f "${REALSENSE_SETUP}" ]] && source "${REALSENSE_SETUP}"
}
timestamp() { date '+%Y%m%d_%H%M%S'; }
new_dir() {
  local path="${DATA_ROOT}/${1}_$(timestamp)"
  mkdir -p "${path}"
  printf '%s\n' "${path}"
}
require_topic() {
  rostopic info "$1" >/dev/null || {
    echo "[ERROR] Required topic is unavailable: $1" >&2
    exit 1
  }
}
