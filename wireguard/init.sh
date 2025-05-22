dnf install -y elrepo-release epel-release 
dnf makecache
dnf install -y kmod-wireguard wireguard-tools
wg genkey | tee /etc/wireguard/private.key | wg pubkey > /etc/wireguard/public.key
tee -a /etc/wireguard/wg0.conf > /dev/null <<EOT
[Interface]
Address = 100.10.1.1/24
SaveConfig = true
ListenPort = 51820
PrivateKey = EsomekeyE78DDj1ddICrfyAbHj+R8zC7dDMrV11M=
#PostUp = firewall-cmd --zone=public --add-port 51820/udp && firewall-cmd --zone=public --add-masquerade
#PostDown = firewall-cmd --zone=public --remove-port 51820/udp && firewall-cmd --zone=public --remove-masquerade
EOT
chmod 600 /etc/wireguard/{private.key,wg0.conf}
wg-quick up wg0
systemctl enable wg-quick@wg0.service
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/99-custom.conf
sysctl -p
modprobe wireguard
modprobe iptable_nat
modprobe ip6table_nat
echo "wireguard" > /etc/modules-load.d/wireguard.conf
echo "iptable_nat" > /etc/modules-load.d/iptable_nat.conf
echo "ip6table_nat" > /etc/modules-load.d/ip6table_nat.conf
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
