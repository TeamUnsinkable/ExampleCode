#!/bin/bash

# functions
answer=0
ask_q () {
counter=1
while [ true ]; do
	read -rp "$1 (y/n)" answer
	echo ""
	case "$answer" in
		[Yy]*)
			answer=1
			break;;
		[Nn]*)
			answer=0
			break;;
		*)
			if [ $counter -gt 3 ];then
			echo -e "you're doing this deliberately now... please stop...\n"
			else
			echo -e "please answer yes or no\n"
			let counter++
			fi
	esac
done
}

# let's have this script install everything to make our lives easier

# redundancy checks
if [ $(basename "$PWD") != "ExampleCode" ]; then
    echo "you need to be in the 'Example Code' directory"
    echo "sorry"
    exit
fi

exampleDir=$PWD

if [ $(whoami) = root ]; then
    echo "you are smart to run this as root but I don't want things to break"
    echo "you will have to run this as a regular admin"
    exit
else
echo "you may have to run commands as root, so be prepared to enter your password"
read
fi

ask_q "would you like to do installs for ROS and other dependencies?"

# this installs ROS and other dependencies
# instructions for ROS installation http://wiki.ros.org/melodic/Installation/Ubuntu
# commands are litterally copied and pasted from there
if [ "$answer" = "1" ]; then

    testVar=0

    # tests repositories
    if [ -z "$(grep -v ^"#" /etc/apt/sources.list | grep restricted)" ]; then
        testVar=1
    elif [ -z "$(grep -v ^"#" /etc/apt/sources.list | grep universe)" ]; then
        testVar=1
    elif [ -z "$(grep -v ^"#" /etc/apt/sources.list | grep multiverse)" ]; then
        testVar=1
    fi

    if [ "$testVar" = "1" ]; then
        echo "you don't have good repositories"
        echo "go fix it!"
        exit
    fi

    # install curl if not installed
    if ! [ -x "$(command -v curl)" ]; then
        sudo apt install curl
    fi

    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

    # update everything (my take a while)
    sudo apt update
    sudo apt upgrade

    # install github if not installed
    if ! [ -x "$(command -v git)" ]; then
        sudo apt install git-all
    fi

    # install visual studio code if not installed (yeah we can do that)
    if ! [ -x "$(command -v code)" ]; then
        if ! [ -x "$(command -v snap)" ]; then
            sudo apt install snap
        fi
        sudo snap install code --classic
    fi

    ask_q "would you like the full ROS install? (only reccomended if you will be using the Gazebo sim)"

    # install ROS
    if [ "$answer" = 1 ]; then
        sudo apt install ros-melodic-desktop-full
    else
        sudo apt install ros-melodic-ros-base
    fi

    apt search ros-melodic

    # set up environment variables
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
    source ~/.bashrc

    
fi

# if catkin is not found as a command, install it
if ! [ -x "$(command -v catkin)" ]; then
    sudo apt-get install ros-melodic-catkin python-catkin-tools
fi

ask_q "would you like to install the PX4 autopilot dependancies?"

if [ "$answer" = 1 ]; then
    cd
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive
    bash ./PX4-Autopilot/Tools/setup/ubuntu.sh
    cd $exampleDir
fi

# # ask to set up the underwater vehicle simulator 
# ask_q "would you like to install the Gazebo Underwater Simulator?"

# if [ "$answer" = 1 ]; then
#     sudo apt-get update
#     sudo apt install ros-melodic-uuv-simulator

#     # missing models bugfix

#     git clone https://github.com/uuvsimulator/uuv_simulator.git
#     cd uuv_simulator/uuv_assistants
#     sudo cp -r ./templates/ /opt/ros/melodic/share/uuv_assistants/
#     cd ../..
#     rm -r -d -f uuv_simulator
#     cd $exampleDir
# fi

ask_q "Have you built the catkin environment yet?"

if [ "$answer" = 0 ]; then
    # the actual set up script
    source ~/.bashrc
    catkin init
    catkin build
    echo "source $PWD/devel/setup.bash" >> ~/.bashrc
    chmod +x src/nodeexamples/scripts/pong.py
    chmod +x troubleshoot.sh
fi

