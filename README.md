# Update Sudoers App

Local Debian package project for installing and running the update_sudoers script with systemd and a desktop launcher.

## Project structure

- `source_scripts/` → original scripts
- `package-root/` → Debian package contents
- `.gitignore` → ignored files

## Build

```bash
sudo dpkg-deb --build package-root update-sudoers-app_1.0.0_all.deb
