sudo apt-get install blueman
sudo /etc/init.d/bluetooth start

#bluez-tools : https://zoomadmin.com/HowToInstall/UbuntuPackage/bluez-tools

sudo apt-get update -y
sudo apt-get install -y bluez-tools

bt-device -r <mac adress bluetooth speaker>
