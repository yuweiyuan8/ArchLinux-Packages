#!/usr/bin/env bash

VERSION=$(grep 'Kernel Configuration' < config | awk '{print $3}')

# add deb-src to sources.list
sudo sed -i "/deb-src/s/# //g" /etc/apt/sources.list
sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources

# install dep
sudo apt update
sudo apt install -y wget 
sudo apt install -y build-essential openssl pkg-config libssl-dev libncurses5-dev pkg-config minizip libelf-dev flex bison  libc6-dev libidn11-dev rsync bc liblz4-tool  
sudo apt install -y gcc-aarch64-linux-gnu dpkg-dev dpkg git debhelper
sudo apt build-dep -y linux

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

# download kernel source and patch
git clone -b nikroks/alioth https://github.com/mainlining/linux.git linux --depth=1
cd linux  || exit

# add some patch
# echo "Add MI8-dipper.patch"
# git am ../MI8-dipper.patch

# add mix2s panel driver
# sed -i "s/^.*CONFIG_DRM_PANEL_JDI_NT35596S.*$/CONFIG_DRM_PANEL_JDI_NT35596S=y/" .config

# generate .config
make ARCH=arm64 defconfig sm8250.config

# build deb packages
make -j$(nproc) ARCH=arm64 KBUILD_DEBARCH=arm64 KDEB_CHANGELOG_DIST=mobile CROSS_COMPILE=aarch64-linux-gnu- deb-pkg
# This will generate several deb files in ../

# move deb packages to artifact dir
cd ..
mkdir "artifact"

cp linux/arch/arm64/boot/dts/qcom/sm8250-*.dtb artifact/
mv ./*.deb artifact/
