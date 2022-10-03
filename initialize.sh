#!/bin/bash

catkin init
catkin build
echo 'source ~/ExampleCode/devel/setup.bash' >> ~/.bashrc
chmod -x src/nodeexamples/scripts/pong.py