#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
load_ros
run_id="${1:-run01}"
require_topic "${CAM0_TOPIC}"
require_topic "${CAM1_TOPIC}"
require_topic "${IMU_TOPIC}"
run_dir="$(new_dir "camimu_dynamic_${run_id}")"
bag="${run_dir}/camimu_dynamic.bag"
echo "Recording camera-IMU dynamic data to ${bag}"
echo "Move smoothly for approximately 60–120 seconds, then press Ctrl+C."
rosbag record --lz4 -O "${bag}" "${CAM0_TOPIC}" "${CAM1_TOPIC}" "${IMU_TOPIC}" 2>&1 | tee "${run_dir}/record.log"
rosbag info "${bag}" > "${run_dir}/rosbag_info.txt"
echo "Completed: ${run_dir}"
