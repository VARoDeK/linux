#!/usr/bin/env bash

# Now torvalds/tree doesn't have ti_config_fragments. Hence, won't be able
# to build config files for boards. Better is to build config file in
# 'ti-linux-kernel', paste it here and run 'make olddefconfig'.
#
# So, this script assumes that config files is present in ../config directory.

# Halt the execution as soon as any line trows non true exit.
set -e

#==============================================================================

if [ "$1" == "" ] ;
then
	echo "Choose one of: [buildconfig, menuconfig, build, install]"
	exit 0
fi

#==============================================================================

# Change the export path for your system.

# Export path to Arm cross compiler.
if ! [[ $PATH == *"aarch64-none-linux-gnu"* ]] ;
then
	##echo "exporting path"
	export PATH=$HOME/ExternalPackages/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin:$PATH
fi

#==============================================================================

# Show each command before executing it.
set -x

if [ "$1" == "buildconfig" ] ;
then
	cp ../config/config ./.config

	make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- olddefconfig

	##echo "build config command"
	exit 0

elif [ "$1" == "menuconfig" ] ;
then
	make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- menuconfig
	
	##echo "menuconfig command"
	exit 0

elif [ "$1" == "build" ] ;
then
	make -j"$(nproc)" W=1 ARCH=arm64 \
	CROSS_COMPILE=aarch64-none-linux-gnu- Image > \
	./buildconfig_log.not_patch.patch 2>&1

	make -j"$(nproc)" W=1 ARCH=arm64 \
	CROSS_COMPILE=aarch64-none-linux-gnu- modules > \
	./buildmodules_log.not_patch.patch 2>&1

	make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- \
	ti/k3-am642-evm.dtb

	##echo "build command"
	exit 0

elif [ "$1" == "install" ] ;
then
	#Change installation paths according to your own need
	sudo cp arch/arm64/boot/Image /run/media/varodek/ROOT/boot

	sudo cp arch/arm64/boot/dts/ti/k3-am642-evm.dtb /run/media/varodek/ROOT/boot

	sudo make ARCH=arm64 INSTALL_MOD_PATH=/run/media/varodek/ROOT modules_install

	##echo "install command"
	exit 0

else
	echo "Choose one of: [buildconfig, menuconfig, build, install]"
	exit 0
fi

#==============================================================================

#END
