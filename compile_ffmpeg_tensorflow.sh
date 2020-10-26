# COMPILING FFMPEG + X264 + HEVC + AAC + MP3 + OPUS + VPX + Tensorflow ON UBUNTU
# AWS deep learning AMI 25 ubuntu 16
# g4dn.xlarge
sudo apt-get update
 
# PREREQUISITES
sudo apt install -y autoconf automake build-essential \
  libass-dev libfreetype6-dev libgpac-dev libsdl1.2-dev libsdl2-dev libtheora-dev \
  libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
  libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev cmake mercurial unzip \
  libmp3lame-dev libopus-dev gpac libffms2-4 libavcodec-dev libgnutls28-dev texinfo wget
 
# PREPARE YASM
mkdir ~/ffmpeg_sources
cd ~/ffmpeg_sources
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make -j${nproc}
make install
make distclean
 
# PREPARE NASM
sudo apt install -y nasm

# Compile LIBAV
cd ~
git clone git://git.libav.org/libav
cd libav
./configure --enable-pic
make -j${nproc}
sudo make install
# PREPARE X264
sudo apt install -y libx264-dev
# PREPARE X265 HEVC
sudo apt-get install -y libx265-dev libnuma-dev

# PREPARE AAC
cd ~/ffmpeg_sources
wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master
unzip fdk-aac.zip
cd mstorsjo-fdk-aac*
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make -j${nproc}
make install
make distclean

# PREPARE WEBM
cd ~/ffmpeg_sources
git clone https://chromium.googlesource.com/webm/libvpx
cd ~/ffmpeg_sources/libvpx
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests
PATH="$HOME/bin:$PATH" make -j${nproc}
make install
make clean

# Detect CPU, CPU with AVX instructions or GPU and select appropriate libtensorflow
gpu=$(nvidia-smi -L | grep GPU | wc -l)
avx=$(cat /proc/cpuinfo | grep avx | wc -l)
if [ "$gpu" -ge 1 ]; then
	export gpu='1'
else
	export gpu='0'
fi
if [ "$avx" -ge 1 ]; then
	export avx='1'
else
	export avx='0'
fi

if [ "$gpu" -eq '1' ]; then
	wget https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-gpu-linux-x86_64-1.15.0.tar.gz
	sudo tar -C /usr/local -xzf libtensorflow-gpu-linux-x86_64-1.15.0.tar.gz
	rm libtensorflow-gpu-linux-x86_64-1.15.0.tar.gz
else
	if [ "$avx" -eq '1' ]; then
		wget https://www.dropbox.com/s/8hn9f67oq47kuk7/libtensorflow.tar.gz
		sudo tar -C /usr/local -xzf libtensorflow.tar.gz
		rm libtensorflow.tar.gz
	else
		wget https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz
		sudo tar -C /usr/local -xzf libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz
		rm libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz
	fi
fi

# PREPARE FFMPEG
cd ~/ffmpeg_sources
wget http://ffmpeg.org/releases/ffmpeg-4.2.2.tar.bz2
tar xjvf ffmpeg-4.2.2.tar.bz2
cd ffmpeg-4.2.2
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libfontconfig \
  --enable-libfreetype \
  --enable-nonfree \
  --enable-libtensorflow
PATH="$HOME/bin:$PATH" make -j${nproc}
make install
make distclean
hash -r
sudo ldconfig

