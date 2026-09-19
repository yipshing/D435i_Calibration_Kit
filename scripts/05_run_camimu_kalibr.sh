#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
load_ros
source "${KALIBR_SETUP}"
bag="${1:-}"
camchain="${2:-}"
imu_yaml="${3:-}"
if [[ ! -f "${bag}" || ! -f "${camchain}" || ! -f "${imu_yaml}" ]]; then
  echo "Usage: $0 CAMIMU_BAG CAMCHAIN_YAML IMU_YAML" >&2
  exit 2
fi
cd "$(dirname -- "${bag}")"
exec rosrun kalibr kalibr_calibrate_imu_camera \
  --bag "${bag}" --cam "${camchain}" --imu "${imu_yaml}" \
  --target "${TARGET_YAML}" --show-extraction
