#!/bin/bash

sudo cp orion-ld.service /etc/systemd/system/
sudo systemctl start orion-ld
sudo systemctl enable orion-ld

# verify
sudo systemctl status orion-ld