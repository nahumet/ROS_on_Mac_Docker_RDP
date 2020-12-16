# ROS on M1 Mac Docker with xrdp(ARM64)
 This docker file makes the container of ROS Noetic and ROS2 Foxy on Ubuntu 20.04 LTS for M1 Mac (ARM64) based on https://github.com/yama07/docker-ubuntu-lxde/tree/master/xrdp
## Limitation
 Some errors happen
## How to use
1. Install docker developer preview for M1 Mac
2. Install XQuartz
2. excute "./launch_container.sh setup"
3. Usually use "./launch_container.sh"
4. If you want to commit docker container, please use "./launch_container.sh commit"
5. If you want to use ROS with GUI, please use "./launch_container.sh xrdp" and use Parallels Client(access to 127.0.0.1).(Don't use Microsoft Remote Desktop)
