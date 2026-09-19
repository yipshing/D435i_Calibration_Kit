#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
load_ros
require_topic "${CAM0_TOPIC}"
require_topic "${CAM1_TOPIC}"
run_dir="$(new_dir stereo_static)"
bag="${run_dir}/stereo_static.bag"
echo "Recording stereo static data to ${bag}"
echo "Stop with Ctrl+C after approximately 2–4 minutes."
rosbag record --lz4 -O "${bag}" "${CAM0_TOPIC}" "${CAM1_TOPIC}" 2>&1 | tee "${run_dir}/record.log"
rosbag info "${bag}" > "${run_dir}/rosbag_info.txt"
echo "Completed: ${run_dir}"
