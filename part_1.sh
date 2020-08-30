#!/bin/bash

#Making sure this script runs with elevated privileges
if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi

#Making all necessary parts executable
chmod +x part_2.sh part_3_optional.sh

#Creating a GRUB variable equal to current content of grub cmdline. 
GRUB=`cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX_DEFAULT" | rev | cut -c 2- | rev`


#Creating a grub backup for the uninstallation script and making uninstall.sh executable
cat /etc/default/grub > grub_backup.txt
chmod +x uninstall.sh

#After the backup has been created, add intel_iommu=on kvm.ignore_msrs=1 i915.enable_gvt=1
# to GRUB variable
GRUB+=" intel_iommu=on i915.enable_gvt=1 kvm.ignore_msrs=1\""
sed -i -e "s|^GRUB_CMDLINE_LINUX_DEFAULT.*|${GRUB}|" /etc/default/grub

#User verification of new grub and prompt to manually edit it
echo 
echo "Grub was modified to look like this: "
echo `cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX_DEFAULT"`
echo 
echo "Do you want to edit it? y/n"
read YN

if [ $YN = y ]
then
nano /etc/default/grub
fi


#Updating grub
update-grub

#Installing required packages for Looking Glass
apt-get install binutils-dev cmake fonts-freefont-ttf libsdl2-dev libsdl2-ttf-dev libspice-protocol-dev libfontconfig1-dev libx11-dev nettle-dev -y

#Install required packages for virtualization
apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager ovmf -y

#Backing up /etc/modules for future use by uninstall.sh
cat /etc/modules > modules_backup.txt

#Adding kernel modules
echo "vfio_mdev" >> /etc/modules
echo "kvmgt" >> /etc/modules

#Updating initramfs
update-initramfs -u

#Allowing Looking Glass in app armor
echo "/dev/shm/looking-glass rw," >> /etc/apparmor.d/abstractions/libvirt-qemu

#Now the computer needs to be rebooted
while [ true ]
	do
echo
echo "To reboot your computer now, please enter (r)"
read REBOOT

if [ $REBOOT = "r" ]
	then
		reboot
fi

done
