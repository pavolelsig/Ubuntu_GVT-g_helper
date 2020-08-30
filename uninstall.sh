#!/bin/bash

if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi

#Remove files related to Intel GPU passthrough



if [ -a grub_backup.txt ]
	then 
	mv grub_backup.txt /etc/default/grub
fi

if [ -a modules_backup.txt ]
	then 
	mv modules_backup.txt /etc/modules
fi

update-grub

update-initramfs -u

rm /etc/systemd/system/gvt_pe.service

rm /usr/bin/gvt_pe.sh


#Remove Scream Audio if present

if [ -a /usr/bin/scream ]
	then 
	rm /usr/bin/scream
fi


if [ -a /usr/bin/scream_audio.sh ]
	then 
	rm /usr/bin/scream_audio.sh
fi


if [ -a /home/$LOGNAME/.config/autostart/audio.sh.desktop ]
	then 
	rm /home/$LOGNAME/.config/autostart/audio.sh.desktop
fi

rm check_gpu.sh
