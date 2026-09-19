#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
load_ros
require_topic "${IMU_TOPIC}"

run_dir="$(new_dir imu_static_3h)"
allan_dir="${run_dir}/allan"
input_dir="${allan_dir}/input"
mkdir -p "${allan_dir}" "${input_dir}"
bag="${run_dir}/imu_static_3h.bag"
cooked="${input_dir}/imu_static_3h_cooked.bag"
echo "Recording for exactly 3 hours to ${bag}"
echo "Keep the camera and USB cable completely still."

set +e
timeout --signal=INT --kill-after=60s 3h \
  rosbag record --lz4 -O "${bag}" "${IMU_TOPIC}" 2>&1 | tee "${run_dir}/record.log"
record_status=${PIPESTATUS[0]}
set -e

[[ -f "${bag}" ]] || { echo "[ERROR] IMU bag was not created." >&2; exit 1; }
rosbag info "${bag}" | tee "${run_dir}/rosbag_info.txt"

allan_pkg="${ALLAN_SETUP%/devel/setup.bash}/src/allan_variance_ros"
python3 "${allan_pkg}/scripts/cookbag.py" --input "${bag}" --output "${cooked}" \
  2>&1 | tee "${allan_dir}/cookbag.log"
(
  source "${ALLAN_SETUP}"
  cd "${allan_dir}"
  rosrun allan_variance_ros allan_variance "${input_dir}" "${ALLAN_CONFIG}"
) 2>&1 | tee "${allan_dir}/allan_variance.log"

[[ -f "${allan_dir}/allan_variance.csv" ]] || {
  echo "[ERROR] Allan variance CSV was not generated." >&2
  exit 1
}
(
  cd "${allan_dir}"
  python3 "${allan_pkg}/scripts/analysis.py" \
    --data "${allan_dir}/allan_variance.csv" \
    --config "${ALLAN_CONFIG}" \
    --output "${allan_dir}/imu.yaml"
) 2>&1 | tee "${allan_dir}/analysis.log"

printf 'record_exit_status=%s\ncompleted=%s\n' "${record_status}" "$(date --iso-8601=seconds)" \
  > "${run_dir}/completion.txt"
echo "Completed: ${run_dir}"
