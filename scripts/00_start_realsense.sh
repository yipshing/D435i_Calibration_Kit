#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
load_ros
camera_args=()
if [[ -n "${CAMERA_SERIAL}" ]]; then
  camera_args+=("serial_no:=${CAMERA_SERIAL}")
fi
exec roslaunch realsense2_camera rs_camera.launch "${camera_args[@]}" \
  enable_depth:=false enable_color:=false enable_pointcloud:=false \
  enable_infra1:=true enable_infra2:=true \
  infra_width:="${IMAGE_WIDTH}" infra_height:="${IMAGE_HEIGHT}" infra_fps:="${IMAGE_FPS}" \
  enable_gyro:=true enable_accel:=true \
  unite_imu_method:=linear_interpolation enable_sync:=false
