#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
load_ros
for topic in "${CAM0_TOPIC}" "${CAM1_TOPIC}" "${IMU_TOPIC}"; do
  require_topic "${topic}"
  echo "===== ${topic} ====="
  timeout 8s rostopic hz "${topic}" || true
done
