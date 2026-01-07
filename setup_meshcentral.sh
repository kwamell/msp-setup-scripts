#!/bin/bash
# =========================================
# MeshCentral Setup Script (Ubuntu)
# - Installs Node.js LTS + MeshCentral
# - Creates a dedicated meshcentral user
# - Runs MeshCentral as a systemd service
# - Opens firewall ports (80/443 by default)
#
# After install:
#   sudo meshcentral-create-admin
#   Browse: https://<server-ip>/
# =========================================

set -e

# -----------------------------
# Settings (change if needed)
# -----------------------------
MESH_USER="meshcentral"
MESH_HOME="/opt/meshcentral"
MESH_DATA="/opt/meshcentral/meshcentral-data"
HTTP_PORT="80"
HTTPS_PORT="443"

echo "✅ Updating OS + installing prerequisites..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget ufw ca-certificates gnupg

echo "✅ Installing Node.js LTS (NodeSource)..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v

echo "✅ Creating MeshCentral user + directories..."
if ! id "$MESH_USER" >/dev/null 2>&1; then
  sudo useradd -r -m -d "$MESH_HOME" -s /usr/sbin/nologin "$MESH_USER"
fi

sudo mkdir -p "$MESH_HOME" "$MESH_DATA"
sudo chown -R "$MESH_USER:$MESH_USER" "$MESH_HOME"

echo "✅ Installing MeshCentral (as service user)..."
sudo -u "$MESH_USER" bash -c "cd '$MESH_HOME' && npm install meshcentral"

echo "✅ Creating MeshCentral config (basic defaults)..."
sudo tee "$MESH_HOME/config.json" > /dev/null <<EOF
{
  "settings": {
    "port": $HTTPS_PORT,
    "redirPort": $HTTP_PORT,
    "cert": "meshcentral",
    "agentPing": 30,
    "tlsOffload": false
  },
  "domains": {
    "": {
      "title": "MeshCentral",
      "newAccounts": false
    }
  }
}
EOF

sudo chown "$MESH_USER:$MESH_USER" "$MESH_HOME/config.json"

echo "✅ Creating systemd service..."
sudo tee /etc/systemd/system/meshcentral.service > /dev/null <<EOF
[Unit]
Description=MeshCentral Server
After=network.target

[Service]
Type=simple
User=$MESH_USER
WorkingDirectory=$MESH_HOME
Environment=NODE_ENV=production
ExecStart=/usr/bin/node $MESH_HOME/node_modules/meshcentral
Restart=always
RestartSec=5
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Enabling + starting MeshCentral..."
sudo systemctl daemon-reload
sudo systemctl enable meshcentral
sudo systemctl restart meshcentral

echo "✅ Opening firewall ports..."
sudo ufw allow "$HTTP_PORT"/tcp || true
sudo ufw allow "$HTTPS_PORT"/tcp || true
sudo ufw reload || true

echo "✅ Creating helper command to create admin user..."
sudo tee /usr/local/bin/meshcentral-create-admin > /dev/null <<EOF
#!/bin/bash
sudo -u $MESH_USER bash -c 'cd "$MESH_HOME" && /usr/bin/node node_modules/meshcentral --createaccount'
EOF
sudo chmod +x /usr/local/bin/meshcentral-create-admin

IP="$(hostname -I | awk '{print $1}')"

echo "======================================"
echo "✅ MeshCentral installed and running!"
echo "Service status: sudo systemctl status meshcentral --no-pager"
echo "Create admin:   sudo meshcentral-create-admin"
echo "Web URL:        https://$IP/"
echo ""
echo "NOTES:"
echo "- First time HTTPS uses a self-signed cert (browser warning is normal)."
echo "- newAccounts is disabled. Create users via the helper command above."
echo "======================================"
