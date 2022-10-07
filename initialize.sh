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

    ask_q "would you like the Desktop edition is ROS (not recommended)"

    # install ROS
    if [ "$answer" = 1 ]; then
        sudo apt install ros-melodic-desktop
    else
        sudo apt install ros-melodic-ros-base
    fi

    apt search ros-melodic

    # set up environment variables
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
    source ~/.bashrc

    source /opt/ros/melodic/setup.bash
fi

# if catkin is not found as a command, install it
if ! [ -x "$(command -v catkin)" ]; then
    sudo apt-get install ros-kinetic-catkin python-catkin-tools
fi

# the actual set up script
echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source ~/.bashrc
catkin init
catkin build
echo "source $PWD/devel/setup.bash" >> ~/.bashrc
chmod +x src/nodeexamples/scripts/pong.py
