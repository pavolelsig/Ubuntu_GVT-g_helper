#!/bin/bash


THE_USER=`logname`

#Making sure this script runs with elevated privileges
if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi

#This script should only run if scream-master is present
if [ -a scream-master ]
	then 
		echo "Continuing with scream installation"
	else
		echo "Scream-master not found in this directory. Please move scream-master into this directory and try again."
		exit
fi

#Create autostart directory if not already present
#This will be used by gnome to start scream on machine startup
if ! [ -a /home/$THE_USER/.config/autostart ]
	then 
	mkdir /home/$THE_USER/.config/autostart
fi

chown $THE_USER /home/$THE_USER/.config/autostart

cp audio.sh.desktop /home/$THE_USER/.config/autostart/

chown $THE_USER /home/$THE_USER/.config/autostart/audio.sh.desktop

#This will be used to autostart scream and can be edited if different parameters are used
cp audio.sh /usr/bin/scream_audio.sh

#Installing required packages
apt install libpulse-dev make

#Compiling scream receiver
cd scream-master/Receivers/unix/

mkdir build

cd build

cmake ..

make

#Moving files to their expected locations
mv scream /usr/bin/scream

chmod +x /usr/bin/scream


chmod +x /usr/bin/scream_audio.sh

