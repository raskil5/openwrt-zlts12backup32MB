#!/bin/bash

# Define directories
BACKUP_DIR=~/openwrt-zlts12backup32MB
OPENWRT_DIR=~/openwrt
BACKUP_REPO="https://github.com/raskil5/openwrt-zlts12backup32MB.git"

# Remove existing OpenWrt directory if it exists
if [ -d "$OPENWRT_DIR" ]; then
    echo "Deleting existing OpenWrt directory..."
    rm -rf $OPENWRT_DIR
fi

# Clone OpenWrt source
echo "Cloning OpenWrt repository..."
git clone https://github.com/openwrt/openwrt.git $OPENWRT_DIR

# Clone the backup repository (if not already present)
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Cloning openwrt-zlts12backup32MB from GitHub..."
    git clone $BACKUP_REPO $BACKUP_DIR
else
    echo "Updating openwrt-zlts12backup32MB from GitHub..."
    cd $BACKUP_DIR && git pull origin main
    cd ~
fi

# Change to OpenWrt directory
cd $OPENWRT_DIR

# Update the feeds
echo "Updating feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# Create necessary directory for wireless file
mkdir -p $OPENWRT_DIR/files/etc/config/

# Copy backup files
echo "Copying backup files..."
cp $BACKUP_DIR/wireless $OPENWRT_DIR/files/etc/config/
cp $BACKUP_DIR/mt7621.mk $OPENWRT_DIR/target/linux/ramips/image/
cp $BACKUP_DIR/mt7621_tozed_zlt-s12-pro.dts $OPENWRT_DIR/target/linux/ramips/dts/

# Compile OpenWrt
echo "Compiling OpenWrt..."
make -j$(nproc) v=s
