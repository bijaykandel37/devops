#!/bin/bash

# Exit on any error
set -e

# Check for sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root (use sudo)."
    exit 1
fi

# Variables
PUBLIC_IP_OR_DOMAIN="$1"
if [ -z "$PUBLIC_IP_OR_DOMAIN" ]; then
    echo "Usage: $0 <public-ip-or-domain>"
    exit 1
fi
PORT=1194
PROTO=udp
VPN_SUBNET="10.8.0.0 255.255.255.0"
INTERFACE=$(ip -o -f inet addr show | awk '/scope global/ {print $2}' | head -n 1)
EASY_RSA_DIR="$HOME/easy-rsa"
CLIENT_CONFIG_DIR="$HOME/client-configs"
SERVER_CONF="/etc/openvpn/server.conf"

# Step 1: Update system and install dependencies
echo "Updating system and installing OpenVPN, Easy-RSA, and iptables-persistent..."
apt update && apt upgrade -y
apt install openvpn easy-rsa iptables-persistent -y

# Step 2: Set up Easy-RSA for CA and certificates
echo "Setting up Easy-RSA..."
make-cadir "$EASY_RSA_DIR"
cd "$EASY_RSA_DIR"

# Create vars file for CA configuration
cat > vars << EOL
export KEY_COUNTRY="US"
export KEY_PROVINCE="CA"
export KEY_CITY="SanFrancisco"
export KEY_ORG="MyOrg"
export KEY_EMAIL="admin@example.com"
export KEY_CN="server"
export KEY_NAME="server"
export KEY_OU="IT"
EOL

# Initialize PKI and generate certificates
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req server nopass
./easyrsa sign-req server server
./easyrsa gen-dh
openvpn --genkey secret ta.key

# Copy certificates to OpenVPN directory
cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem ta.key /etc/openvpn/

# Step 3: Configure OpenVPN server
echo "Configuring OpenVPN server..."
cat > "$SERVER_CONF" << EOL
port $PORT
proto $PROTO
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
server $VPN_SUBNET
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
persist-key
persist-tun
user nobody
group nogroup
verb 3
EOL

# Step 4: Enable IP forwarding
echo "Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl -p

# Step 5: Set up NAT with iptables
echo "Setting up NAT with iptables..."
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$INTERFACE" -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# Step 6: Start and enable OpenVPN service
echo "Starting OpenVPN service..."
systemctl enable openvpn@server
systemctl start openvpn@server
systemctl status openvpn@server --no-pager

# Step 7: Prompt for client configuration
read -p "Do you want to create a client configuration? (y/yes/n/no): " CREATE_CLIENT
if [ "$CREATE_CLIENT" = "y" ] || [ "$CREATE_CLIENT" = "yes" ]; then
    echo "Creating client configuration for 'client1'..."
    mkdir -p "$CLIENT_CONFIG_DIR"
    cd "$EASY_RSA_DIR"

    # Generate client certificates
    ./easyrsa gen-req client1 nopass
    ./easyrsa sign-req client client1

    # Create client configuration
    cat > "$CLIENT_CONFIG_DIR/client1.ovpn" << EOL
client
dev tun
proto $PROTO
remote $PUBLIC_IP_OR_DOMAIN $PORT
resolv-retry infinite
nobind
persist-key
persist-tun
ca [inline]
cert [inline]
key [inline]
tls-auth [inline] 1
cipher AES-256-CBC
verb 3
pull
block-outside-dns
<ca>
$(cat pki/ca.crt)
</ca>
<cert>
$(cat pki/issued/client1.crt)
</cert>
<key>
$(cat pki/private/client1.key)
</key>
<tls-auth>
$(cat ta.key)
</tls-auth>
EOL

    echo "Client configuration created."
fi

# Step 8: Display output file locations
echo -e "\n=== Output File Locations ==="
echo "Server configuration: $SERVER_CONF"
echo "Certificates and keys: /etc/openvpn/{ca.crt,server.crt,server.key,dh.pem,ta.key}"
if [ "$CREATE_CLIENT" = "y" ] || [ "$CREATE_CLIENT" = "yes" ]; then
    echo "Client configuration: $CLIENT_CONFIG_DIR/client1.ovpn"
    echo "To connect from Windows, transfer $CLIENT_CONFIG_DIR/client1.ovpn to your Windows machine and import it into OpenVPN Connect."
fi
echo -e "===========================\n"
echo "OpenVPN server setup complete. Ensure port $PORT/$PROTO is open on your router if behindIVPN server setup complete. Ensure port $PORT/$PROTO is open on your router if behind NAT."
