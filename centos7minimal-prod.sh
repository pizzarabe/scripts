#!/bin/sh
reboot=0
#stop and disable NetworkManager (I don't need/want that!)
systemctl stop NetworkManager
systemctl disable NetworkManager

#install deltarpm and yum-cron
yum -y install deltarpm yum-cron

#check if we will install a new kernel
if [ $(yum -q check-update | grep -c "^kernel" ) -gt 0 ]
then
reboot=1
fi

#update the OS
yum -y update

#(simple) check if running in VMware
if [ $(grep -c "Hypervisor detected: VMware" /var/log/dmesg ) -gt 0 ]
then
  #install "open-vm-tools" if running in VMware
  if [ $(rpm -qa | grep -c "open-vm-tools") -eq 0 ]
  #but check if "open-vm-tools" is already installed
  then
  yum -y install open-vm-tools
  reboot=1
  fi
fi

# Check if yum-cron.conf_backup already exists

if [ ! -e /etc/yum/yum-cron.conf_backup ]
then
#Configure yum-cron to auto install security updates
cp -v /etc/yum/yum-cron.conf /etc/yum/yum-cron.conf_backup && \
sed -i s/apply_updates\ \=\ \no/apply_updates\ \=\ \yes/ /etc/yum/yum-cron.conf

else
  echo "yum-cron.conf_backup already exists..."
fi
#start yum-cron
systemctl start yum-cron

if [ $(echo $reboot) -eq '1' ]
then
  echo 'A reboot is required'
  echo  'Reboot in '
  echo -en '5 \r'
  sleep 1
  echo -en '4 \r'
  sleep 1
  echo -en '3 \r'
  sleep 1
  echo -en '2 \r'
  sleep 1
  echo -en '1 \r'
  sleep 1
  echo 'rebooting...'
 reboot now

 else
   echo "Done...!"

fi
