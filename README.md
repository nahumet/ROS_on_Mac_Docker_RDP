# ROS on Mac Docker with xrdp(ETH ROS Image)
 This docker file makes the container of ROS Noetic on Ubuntu 20.04 LTS for  Mac https://github.com/ETHZ-RobotX/SuperMegaBot

## How to use
1. Install Docker Desktop
2. Install XQuartz (optional to run through X, currently with version 2.8 broken)
2. execute "./launch_container.sh setup"
3. Usually use "./launch_container.sh"
4. If you want to commit the docker container, please use "./launch_container.sh commit"
5. If you want to use ROS with GUI, please use "./launch_container.sh xrdp" and use Parallels Client(access to 127.0.0.1).(Don't use Microsoft Remote Desktop)
