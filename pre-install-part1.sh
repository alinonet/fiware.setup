#!/bin/bash

# 1. Stop the automatic updater.
echo At the first prompt, choose not to download and install updates.
echo Press Enter to continue...
read key

sudo dpkg-reconfigure -plow unattended-upgrades

echo Rebooting...
sudo reboot