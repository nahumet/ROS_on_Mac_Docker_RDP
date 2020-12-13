# ROS on M1 Mac Docker (ARM64)
 This docker file makes the container of ROS Noetic on Ubuntu 20.04 LTS for M1 Mac (ARM64)
## Limitation
 Rviz and Gazebo don't work. (because of OpenGL Problems)
## How to use
1. Install docker developer preview for M1 Mac
2. Install XQuartz
2. excute ./launch_container.sh setup
3. Usually use ./launch_container.sh
4. If you want to commit docker container please use ./launch_container.sh commit
