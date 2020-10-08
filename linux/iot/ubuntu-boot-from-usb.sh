#!/bin/bash

# Refer from below URL
# https://medium.com/@zsmahi/make-ubuntu-server-20-04-boot-from-an-ssd-on-raspberry-pi-4-33f15c66acd4

sudo apt update && sudo apt full-upgrade -y
sudo echo 'FIRMWARE_RELEASE_STATUS="beta"' > /etc/default/rpi-eeprom-update
rpi-eeprom-update -d -f /lib/firmware/raspberrypi/bootloader/beta/pieeprom-2020-09-03.bin
reboot
sudo mkdir /mnt/boot && sudo mount /dev/sda1 /mnt/boot
sudo mkdir /mnt/principal && sudo mount /dev/sda2 /mnt/principal
cd /mnt/boot
sudo cp /boot/*.elf /mnt/boot/
sudo sudo cp /boot/*.dat /mnt/boot/
cd /mnt/boot

sudo su

zcat vmlinuz > vmlinux
echo 'dtoverlay=vc4-fkms-v3d 
boot_delay 
kernel=vmlinux 
initramfs initrd.img followkernel' >> /mnt/boot/config.txt

echo '#!/bin/bash -e
# auto_decompress_kernel script
#Set Variables 
BTPATH=/boot/firmware 
CKPATH=$BTPATH/vmlinuz 
DKPATH=$BTPATH/vmlinux  
#Check if compression needs to be done. 
if [ -e $BTPATH/check.md5 ]; then  
   if md5sum --status --ignore-missing -c $BTPATH/check.md5; then
      echo -e "\e[32mFiles have not changed, Decompression not needed\e[0m"  
      exit 0  
   else 
      echo -e "\e[31mHash failed, kernel will be compressed\e[0m"  
   fi 
fi
#Backup the old decompressed kernel 
mv $DKPATH $DKPATH.bak  
if [ ! $? == 0 ]; then  
   echo -e "\e[31mDECOMPRESSED KERNEL BACKUP FAILED!\e[0m"  
   exit 1 
else  
   echo -e "\e[32mDecompressed kernel backup was successful\e[0m" 
fi  
#Decompress the new kernel 
echo "Decompressing kernel: "$CKPATH".............."  
zcat $CKPATH > $DKPATH  
if [ ! $? == 0 ]; then  
   echo -e "\e[31mKERNEL FAILED TO DECOMPRESS!\e[0m"  
   exit 1 
else  
   echo -e "\e[32mKernel Decompressed Succesfully\e[0m" 
fi  
#Hash the new kernel for checking 
md5sum $CKPATH $DKPATH > $BTPATH/check.md5  
if [ ! $? == 0 ]; then  
   echo -e "\e[31mMD5 GENERATION FAILED!\e[0m"  
else 
   echo -e "\e[32mMD5 generated Succesfully\e[0m" 
fi  
#Exit 
exit 0' > auto_decompress_kernel
chmod +x auto_decompress_kernel

echo 'DPkg::Post-Invoke {"/bin/bash /boot/firmware/auto_decompress_kernel"; };' > /mnt/principal/etc/apt/apt.conf.d/999_decompress_rpi_kernel

chmod +x /mnt/principal/etc/apt/apt.conf.d/999_decompress_rpi_kernel
shutdown -h now
