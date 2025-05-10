#!/usr/bin/env bash

VERSION=$(grep 'Kernel Configuration' < config | awk '{print $3}')

# add deb-src to sources.list
sudo sed -i "/deb-src/s/# //g" /etc/apt/sources.list
sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources

# install dep
sudo apt update
sudo apt install -y wget 
sudo apt update && sudo apt install -y bc bison flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf make libelf-dev libssl-dev debhelper-compat debhelper build-essential device-tree-compiler
# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

# download kernel source and patch
git clone -b nikroks/alioth https://github.com/yuweiyuan8/linux-alioth.git linux --depth=1
cd linux  || exit

# add some patch
# echo "Add MI8-dipper.patch"
# git am ../MI8-dipper.patch

# add mix2s panel driver
# sed -i "s/^.*CONFIG_DRM_PANEL_JDI_NT35596S.*$/CONFIG_DRM_PANEL_JDI_NT35596S=y/" .config

#Run mv scripts/package/mkdeb scripts/package/mkdebian -v
mv scripts/package/mkdeb scripts/package/mkdebian -v
# build deb packages
export PATH="/usr/lib/ccache:/usr/local/opt/ccache/libexec:$PATH"
make -j16 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnuabeihf- defconfig sm8250.config bindeb-pkg


# move deb packages to artifact dir
cd ..
mkdir "artifact"

cp linux/arch/arm64/boot/dts/qcom/sm8250-*.dtb artifact/
mv ./*.deb artifact/
