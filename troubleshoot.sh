#!/bin/bash

echo "please reboot before saying yes to anything here!"

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

ask_q "Is make px4_sitl broken?"

if [ "$answer" = 1 ]; then
    sed -i '$d' ~/PX4-Autopilot/Tools/setup/requirements.txt
    sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
fi