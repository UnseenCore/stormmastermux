#!/usr/bin/env bash

############################################################
# StormMasterMux Auto Installer
#
# Installs:
#   - StormDNS
#   - MasterDnsVPN
#   - StormMasterMux
#
# Ubuntu 22/24
############################################################

set -e

clear

echo "=================================================="
echo "           StormMasterMux Installer"
echo "=================================================="
echo

############################################################
# Root Check
############################################################

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] Run as root"
  exit 1
fi

############################################################
# User Input
############################################################

read -p "Public Server IP: " PUBLIC_IP

echo

read -p "StormDNS Domain (example: a.example.com): " STORM_DOMAIN

read -p "MasterDnsVPN Domain (example: b.example.com): " MASTER_DOMAIN

echo
echo "=================================================="
echo "Configuration"
echo "=================================================="
echo "Public IP        : $PUBLIC_IP"
echo "StormDNS Domain  : $STORM_DOMAIN"
echo "MasterDNS Domain : $MASTER_DOMAIN"
echo "=================================================="
echo

read -p "Continue installation? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
  exit 0
fi

############################################################
# Variables
############################################################

BASE_DIR="/opt"

MUX_DIR="$BASE_DIR/stormmastermux"
STORM_DIR="$BASE_DIR/stormdns"
MASTER_DIR="$BASE_DIR/masterdnsvpn"

STORM_PORT=5301
MASTER_PORT=5302

############################################################
# Helper
############################################################

log() {
  echo
  echo "[INFO] $1"
}

############################################################
# Update TOML
############################################################

update_toml() {
  local key="$1"
  local value="$2"
  local file="$3"

  if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$file"; then
    sed -i -E \
      "s|^[[:space:]]*${key}[[:space:]]*=.*|${key} = ${value}|g" \
      "$file"
  else
    echo "${key} = ${value}" >> "$file"
  fi
}

############################################################
# Install Dependencies
############################################################

log "Installing dependencies..."

apt update

apt install -y \
  curl \
  wget \
  unzip \
  git \
  golang-go \
  nano \
  lsof \
  net-tools \
  iptables

############################################################
# Disable systemd-resolved
############################################################

log "Disabling systemd-resolved..."

systemctl stop systemd-resolved || true
systemctl disable systemd-resolved || true

rm -f /etc/resolv.conf

cat > /etc/resolv.conf <<EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

############################################################
# Free Port 53
############################################################

log "Freeing port 53..."

fuser -k 53/tcp || true
fuser -k 53/udp || true

############################################################
# Create Directories
############################################################

log "Creating directories..."

mkdir -p "$MUX_DIR"
mkdir -p "$STORM_DIR"
mkdir -p "$MASTER_DIR"

############################################################
# Install StormDNS
############################################################

log "Installing StormDNS..."

cd "$STORM_DIR"

wget -O StormDNS.zip \
https://github.com/nullroute1970/StormDNS/releases/latest/download/StormDNS_Server_Linux_AMD64.zip

unzip -o StormDNS.zip

STORM_BIN=$(find . -type f | grep StormDNS_Server_Linux_AMD64_v | head -n1)

chmod +x "$STORM_BIN"

############################################################
# Configure StormDNS
############################################################

log "Configuring StormDNS..."

STORM_CONFIG="$STORM_DIR/server_config.toml"

update_toml "DOMAIN" "[\"$STORM_DOMAIN\"]" "$STORM_CONFIG"

update_toml "UDP_HOST" "\"127.0.0.1\"" "$STORM_CONFIG"

update_toml "UDP_PORT" "$STORM_PORT" "$STORM_CONFIG"

update_toml "DATA_ENCRYPTION_METHOD" "1" "$STORM_CONFIG"

############################################################
# Generate StormDNS Key
############################################################

log "Generating StormDNS key..."

timeout 3 "$STORM_BIN" -config "$STORM_CONFIG" || true

STORM_KEY=$(cat "$STORM_DIR/encrypt_key.txt")

############################################################
# Install MasterDnsVPN
############################################################

log "Installing MasterDnsVPN..."

cd "$MASTER_DIR"

wget -O MasterDNS.zip \
https://github.com/masterking32/MasterDnsVPN/releases/latest/download/MasterDnsVPN_Server_Linux_AMD64.zip

unzip -o MasterDNS.zip

MASTER_BIN=$(find . -type f | grep MasterDnsVPN_Server_Linux_AMD64_v | head -n1)

mv "$MASTER_BIN" MasterDnsVPN_Server_Linux_AMD64

chmod +x MasterDnsVPN_Server_Linux_AMD64

############################################################
# Configure MasterDnsVPN
############################################################

log "Configuring MasterDnsVPN..."

MASTER_CONFIG="$MASTER_DIR/server_config.toml"

update_toml "DOMAIN" "[\"$MASTER_DOMAIN\"]" "$MASTER_CONFIG"

update_toml "UDP_HOST" "\"127.0.0.1\"" "$MASTER_CONFIG"

update_toml "UDP_PORT" "$MASTER_PORT" "$MASTER_CONFIG"

update_toml "DATA_ENCRYPTION_METHOD" "1" "$MASTER_CONFIG"

############################################################
# Generate Master Key
############################################################

log "Generating MasterDnsVPN key..."

timeout 3 ./MasterDnsVPN_Server_Linux_AMD64 \
-config "$MASTER_CONFIG" || true

MASTER_KEY=$(cat "$MASTER_DIR/encrypt_key.txt")

############################################################
# Install StormMasterMux
############################################################

log "Installing StormMasterMux..."

cd /tmp

rm -rf stormmastermux


git clone https://github.com/UnseenCore/stormmastermux.git

cd stormmastermux

go build -o stormmastermux ./cmd/stormmastermux

mv stormmastermux "$MUX_DIR/"

chmod +x "$MUX_DIR/stormmastermux"

############################################################
# Create Mux Config
############################################################

log "Creating mux configuration..."

cat > "$MUX_DIR/config.toml" <<EOF
listen = ":53"

storm_backend = "127.0.0.1:$STORM_PORT"
master_backend = "127.0.0.1:$MASTER_PORT"

storm_domain = "$STORM_DOMAIN"
master_domain = "$MASTER_DOMAIN"
EOF

############################################################
# Create Services
############################################################

log "Creating systemd services..."

cat > /etc/systemd/system/stormdns.service <<EOF
[Unit]
Description=StormDNS Server
After=network.target

[Service]
Type=simple
WorkingDirectory=$STORM_DIR
ExecStart=$STORM_DIR/$STORM_BIN -config $STORM_CONFIG
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/masterdnsvpn.service <<EOF
[Unit]
Description=MasterDnsVPN Server
After=network.target

[Service]
Type=simple
WorkingDirectory=$MASTER_DIR
ExecStart=$MASTER_DIR/MasterDnsVPN_Server_Linux_AMD64 -config $MASTER_CONFIG
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/stormmastermux.service <<EOF
[Unit]
Description=StormMasterMux
After=network.target stormdns.service masterdnsvpn.service

[Service]
Type=simple
WorkingDirectory=$MUX_DIR
ExecStart=$MUX_DIR/stormmastermux
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

############################################################
# Reload Services
############################################################

log "Reloading systemd..."

systemctl daemon-reload

############################################################
# Enable Services
############################################################

log "Enabling services..."

systemctl enable stormdns
systemctl enable masterdnsvpn
systemctl enable stormmastermux

############################################################
# Start Services
############################################################

log "Starting services..."

systemctl restart stormdns
systemctl restart masterdnsvpn
systemctl restart stormmastermux

############################################################
# Firewall
############################################################

log "Opening firewall..."

iptables -I INPUT -p udp --dport 53 -j ACCEPT
iptables -I INPUT -p tcp --dport 53 -j ACCEPT

############################################################
# Final Status
############################################################

clear

echo "=================================================="
echo "           INSTALLATION COMPLETED"
echo "=================================================="
echo

echo "Public IP:"
echo "$PUBLIC_IP"
echo

echo "StormDNS"
echo "----------------------------------------------"
echo "Domain : $STORM_DOMAIN"
echo "Key    : $STORM_KEY"
echo "Backend: 127.0.0.1:$STORM_PORT"
echo

echo "MasterDnsVPN"
echo "----------------------------------------------"
echo "Domain : $MASTER_DOMAIN"
echo "Key    : $MASTER_KEY"
echo "Backend: 127.0.0.1:$MASTER_PORT"
echo

echo "StormMasterMux"
echo "----------------------------------------------"
echo "Listen : :53"
echo

echo "Services"
echo "----------------------------------------------"
echo "systemctl status stormdns"
echo "systemctl status masterdnsvpn"
echo "systemctl status stormmastermux"
echo

echo "Ports"
echo "----------------------------------------------"

ss -lunpt | grep 53 || true

echo
echo "=================================================="
echo "Done."
echo "=================================================="