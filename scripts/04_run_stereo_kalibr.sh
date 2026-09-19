#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
load_ros
source "${KALIBR_SETUP}"
bag="${1:-}"
[[ -f "${bag}" ]] || { echo "Usage: $0 /absolute/path/to/stereo_static.bag" >&2; exit 2; }
[[ -f "${TARGET_YAML}" ]] || { echo "Missing target: ${TARGET_YAML}" >&2; exit 1; }
cd "$(dirname -- "${bag}")"
exec rosrun kalibr kalibr_calibrate_cameras \
  --bag "${bag}" --topics "${CAM0_TOPIC}" "${CAM1_TOPIC}" \
  --models pinhole-radtan pinhole-radtan --target "${TARGET_YAML}" \
  --bag-freq 4.0 --show-extraction
