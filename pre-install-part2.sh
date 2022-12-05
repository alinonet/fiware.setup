#!/bin/bash

# 2. Make sure any packages in an unclean state are installed correctly.
sudo dpkg --configure -a

# 3. Get your system up-to-date.
sudo apt update && sudo apt -f install && sudo apt full-upgrade

# 4. Turn the automatic updater back on, now that the blockage is cleared.
sudo dpkg-reconfigure -plow unattended-upgrades

echo Select the package unattended-upgrades again.
echo Press Enter to continue...
read key