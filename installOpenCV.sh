#!/bin/bash
cmd=(dialog --clear --backtitle "OpenCV" --title "Install" --checklist "Select install options" 20 100 20)
options=("Cuda" "Build with cuda" ON
	 "Python2" "Build with Python2" ON
	 "Python3" "Build with Python3" ON
	 "Non free" "Enable build non free algorithm" ON
	 "Contrib modules" "Download and build contrib modules" ON
	)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

valret=$?
if [ $valret = 0 ]; then
	for choice in $choices
	do
		case "$choice" in
			"Cuda")		WithCuda="ON" 	;;
			"Python2")	WithPython2="ON"	;;
			"Python3")	WithPython3="ON"	;;
			"Non free")	WithNonFree="ON"	;;
			"Contrib modules") WithContrib="ON"	;;
		esac
	done
else
	clear
	echo "Install aborded"
	exit
fi

dialog --inputbox "Enter the opencv version you want install (Default: 3.3.1):" 8 40 2>Version
if [ -z $Version ]; then
	Version="3.3.1"
fi

clear

sudo apt-get update
sudo apt-get install \
	libglew-dev \
	libgstreamer1.0-dev \
	libgstreamer0.10-dev \
	libtiff5-dev \
	zlib1g-dev \
	libjpeg-dev \
	libpng12-dev \
	libavcodec-dev \
	libavformat-dev \
	libjasper-dev \
	libavutil-dev \
	libpostproc-dev \
	libswscale-dev \
	libeigen3-dev \
	libtbb-dev \
	libgtk2.0-dev \
	cmake \
	pkg-config -y

if [[ $WithPython2 -eq "ON" ]]
then
	sudo apt-get install python-dev python-numpy python-py python-pytest -y
fi

if [[ $WithPython3 -eq "ON" ]]
then
	sudo apt-get install python3-dev python3-numpy python3-py python3-pytest -y
fi

PWD=`pwd`

cd $HOME
mkdir install
cd install

git clone https://github.com/opencv/opencv.git

if [[ $WithContrib -eq "ON" ]]; then
	Contrib="-DOPENCV_EXTRA_MODULES_PATH=$HOME/install/opencv_contrib/modules "
	git clone https://github.com/opencv/opencv_contrib.git
	cd opencv_contrib
	git checkout $Version
	cd ..
fi

cd opencv
git checkout $Version
mkdir build
cd build

if [[ $WithCuda -eq "ON" ]]
then
	cuda="-DWITH_CUDA=ON -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -DCUDA_ARCH_BIN='3.0 3.5 5.0 5.3 6.0 6.1 6.2' -DCUDA_ARCH_PTX=\"\" "
fi

cmake \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DBUILD_PNG=OFF \
	-DBUILD_TIFF=OFF \
	-DBUILD_TBB=OFF \
	-DBUILD_JPEG=OFF \
	-DBUILD_JASPER=OFF \
	-DBUILD_ZLIB=OFF \
	-DBUILD_opencv_java=OFF \
	-DBUILD_opencv_python2=$WithPython2 \
	-DBUILD_opencv_python3=$WithPython3 \
	-DOPENCV_ENABLE_NONFREE=$WithNonFree \
	$Contrib \
	-DENABLE_NEON=ON \
	-DWITH_OPENCL=OFF \
	-DWITH_OPENMP=OFF \
	-DWITH_FFMPEG=ON \
	-DWITH_GSTREAMER=ON \
	-DWITH_GSTREAMER_0_10=ON \
	-DWITH_GTK=ON \
	-DWITH_VTK=OFF \
	-DWITH_TBB=ON \
	-DWITH_1394=OFF \
	-DWITH_OPENEXR=OFF \
	$cuda \
	../
make -j`nproc`
sudo make install
