#!/bin/bash
set -euo pipefail

SRC_SCRIPT="${1:-./update_sudoers.sh}"
DEST_SCRIPT="/usr/local/sbin/update_sudoers.sh"
SERVICE_FILE="/etc/systemd/system/update-sudoers.service"

# Must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo or as root."
    exit 1
fi

# Check source script exists
if [ ! -f "$SRC_SCRIPT" ]; then
    echo "Source script not found: $SRC_SCRIPT"
    exit 1
fi

# Install the script to the correct location with correct ownership and permissions
install -o root -g root -m 700 "$SRC_SCRIPT" "$DEST_SCRIPT"

echo "Installed script to $DEST_SCRIPT"
ls -l "$DEST_SCRIPT"

# Create the systemd service unit
cat > "$SERVICE_FILE" <<'EOF'
[Unit]
Description=Apply sudoers update script at boot
After=local-fs.target
ConditionPathExists=/usr/local/sbin/update_sudoers.sh

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/update_sudoers.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

chmod 644 "$SERVICE_FILE"

echo "Created systemd service at $SERVICE_FILE"
ls -l "$SERVICE_FILE"

# Reload systemd and enable the service
systemctl daemon-reload
systemctl enable update-sudoers.service

echo
echo "Setup complete."
echo "The script now has:"
echo "  Owner: root:root"
echo "  Mode : 700"
echo
echo "The service is enabled and will run at boot."
echo
echo "Useful commands:"
echo "  Run now:        sudo systemctl start update-sudoers.service"
echo "  Check status:   sudo systemctl status update-sudoers.service"
echo "  View logs:      sudo journalctl -u update-sudoers.service -b"
echo "  Confirm enable: sudo systemctl is-enabled update-sudoers.service"