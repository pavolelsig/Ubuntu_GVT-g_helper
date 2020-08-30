#!/bin/sh


#Making sure this script runs with elevated privileges
if [ $(id -u) -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi


GPU=
MAX=0
UUID=\"`uuidgen`\"
VIRT_USER=`logname`

#Finding the Intel GPU and choosing the one with highest weight value
for i in $(find /sys/devices/pci* -name 'mdev_supported_types'); do
for y in $(find $i -name 'description'); do
WEIGHT=`cat $y | tail -1 | cut -d ' ' -f 2`
if [ $WEIGHT -gt $MAX ]; then
GPU=`echo $y | cut -d '/' -f 1-7`

#Saving the uuid for future optional verification by the user
echo "ls $GPU/devices" > check_gpu.sh
chmod +x check_gpu.sh
chown $VIRT_USER check_gpu.sh

fi
done

done


echo "	<hostdev mode='subsystem' type='mdev' managed='no' model='vfio-pci' display='off'>" > virsh.txt
echo "	<source>" >> virsh.txt

echo "	<address uuid=$UUID/>" >> virsh.txt
echo "</source>" >> virsh.txt
echo "</hostdev>" >> virsh.txt

#Identifying user to set permissions
echo 
echo "User: $VIRT_USER will be using Looking Glass on this PC. "
echo "If that's correct, press (y) otherwise press (n) and you will be able to specify the user."
echo 
echo "y/n?"
read USER_YN


#Allowing the user to manually edit the Looking Glass user
if [ $USER_YN = 'n' ] || [ $USER_YN = 'N' ]
	then
USER_YN='n'
		while [ '$USER_YN' = "n" ]; do
			echo "Enter the new username: "
			read VIRT_USER


			echo "Is $VIRT_USER correct (y/n)?"
			read USER_YN
		done
fi
echo User $VIRT_USER selected. Press any key to continue:
read ANY_KEY


#Initializing virtual GPU on every startup
echo "echo $UUID > $GPU/create" >> gvt_pe.sh

# Looking Glass requirements: /dev/shm/looking_glass needs to be created on startup
echo "touch /dev/shm/looking-glass && chown $VIRT_USER:kvm /dev/shm/looking-glass && chmod 660 /dev/shm/looking-glass" >> gvt_pe.sh

#Create a systemd service to initialize the GPU on startup
cp gvt_pe.service /etc/systemd/system/gvt_pe.service
chmod 644 /etc/systemd/system/gvt_pe.service

mv gvt_pe.sh /usr/bin/gvt_pe.sh

systemctl enable gvt_pe.service

systemctl start gvt_pe.service

chown $VIRT_USER virsh.txt


