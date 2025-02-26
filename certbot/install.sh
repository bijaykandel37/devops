dnf install snapd
systemctl enable snapd
systemctl start snapd

sudo ln -s /var/lib/snapd/snap /snap
snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

##Go to this link and read carefully
## https://certbot.eff.org/instructions?ws=nginx&os=centosrhel7

sudo apt install python3-certbot-nginx certbot