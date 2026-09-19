# D435i Calibration Kit 2

本工具包用于在 Ubuntu 20.04 + ROS Noetic 环境下标定 Intel RealSense D435i。

所有新录制的 bag 和标定结果都会存放在：

```text
/home/yip/D435i_Calibration_Kit_2/calibration_data/
```

整个流程包含三个相互独立的数据集：

1. `stereo_static`：固定相机，移动 AprilGrid 标定板。
2. `camimu_dynamic`：保持 AprilGrid 在视野内，平滑移动相机。
3. `imu_static_3h`：让相机完全静止三小时。脚本会自动停止录制、处理 bag、运行 Allan 方差分析并生成 `imu.yaml`。

## 录制前准备

终端 1：

```bash
source /opt/ros/noetic/setup.bash
roscore
```

终端 2：

```bash
cd /home/yip/D435i_Calibration_Kit_2
./scripts/00_start_realsense.sh
```

每次录制前检查话题：

```bash
./scripts/00_check_topics.sh
```

## 1. 双目静态标定

固定 D435i。将 A4 AprilGrid 依次移动到画面中央、四个角、边缘、近距离和远距离位置，并以多个倾角移动约 2–4 分钟。

```bash
./scripts/01_record_stereo_static.sh
```

然后使用生成的 bag 运行 Kalibr：

```bash
./scripts/04_run_stereo_kalibr.sh /path/to/stereo_static.bag
```

## 2. 相机-IMU 动态标定

保持 AprilGrid 在视野内。平滑地沿三个轴进行平移和旋转，避免运动模糊和碰撞。

```bash
./scripts/02_record_camimu_dynamic.sh run01
./scripts/02_record_camimu_dynamic.sh run02
./scripts/02_record_camimu_dynamic.sh run03
```

然后运行：

```bash
./scripts/05_run_camimu_kalibr.sh /path/to/camimu_dynamic.bag /path/to/camchain.yaml /path/to/imu.yaml
```

## 3. 三小时静态 IMU Allan 标定

将相机放在稳定且无振动的表面上。录制期间不要触碰 USB 线缆或桌面。

```bash
./scripts/03_record_imu_static_3h.sh
```

此脚本会录制 `/camera/imu` 三小时，使用 `SIGINT` 关闭 rosbag，按时间戳重新整理 bag，离线运行 Allan 方差分析，并生成兼容 Kalibr 的 `imu.yaml`。所有输出都存放在同一个数据集目录中。

Allan 工具直接处理 bag，不需要使用 `rosbag play`。

AprilGrid 配置为 6×6、标签尺寸 24 mm、标称间隙 7.2 mm。使用前请确认打印的标定板。
