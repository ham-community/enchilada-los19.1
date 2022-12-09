#!/usr/bin/env bash
set -e
# No need to check for latest version of the OS
# since OP dropped support for OP6 :(
# So no more vendor security fixes.
# (Do they actually do that in the first place?)
# Who knows what these vendor blobs does.
mkdir -p /ham-build/stock_os/
rm -rf /ham-build/stock_os/*
wget -O /ham-build/stock_os/current-stock-os.zip "https://oxygenos.oneplus.net/OnePlus6Oxygen_22.J.62_OTA_0620_all_2111252336_287bcb1636d743d3.zip"
