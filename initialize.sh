#!/bin/bash

echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source ~/.bashrc
catkin init
catkin build
echo "source $PWD/devel/setup.bash" >> ~/.bashrc
chmod +x src/nodeexamples/scripts/pong.py
