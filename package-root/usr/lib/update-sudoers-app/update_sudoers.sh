#!/bin/bash
set -e

USERNAME="testone"
PASSWORD="testone"

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

# Make sure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo or as root."
    exit 1
fi

# Create user if it does not exist
if id "$USERNAME" >/dev/null 2>&1; then
    echo "User already exists: $USERNAME"
else
    useradd -m -s /bin/bash "$USERNAME"
    echo "${USERNAME}:${PASSWORD}" | chpasswd
    echo "User created: $USERNAME"
fi

# Write the full new sudoers content to a temporary file
cat > "$TMPFILE" <<'EOF'
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults env_reset
Defaults mail_badpass
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root ALL=(ALL:ALL) ALL
testone ALL=(ALL, !root) ALL

# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# Allow members of group sudo to execute any command
%sudo ALL=(ALL:ALL) ALL

# See sudoers (5) for more information on "#include" directives:
#includedir /etc/sudoers.d
EOF

# Set correct permissions before validation
chmod 440 "$TMPFILE"

# Validate the temp sudoers file
visudo -c -f "$TMPFILE"

# Replace the real sudoers file only if validation passed
cp "$TMPFILE" /etc/sudoers
chmod 440 /etc/sudoers

echo "Done. /etc/sudoers has been replaced successfully."
