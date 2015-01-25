#!/bin/bash -eux
export DEBIAN_FRONTEND=noninteractive
apt-get update -y -q
apt-get install -q -y python-software-properties
# Installs Android Build Tools
## Installs JDK6
echo debconf shared/accepted-oracle-license-v1-1 select true | \
  debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | \
  debconf-set-selections
add-apt-repository -y ppa:webupd8team/java 
apt-get update -y -q
apt-get install -y -q oracle-java6-installer 
## Installs android build tools dependencies
apt-get install -y -q git gnupg flex bison gperf build-essential \
  zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
  libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
  libgl1-mesa-dev g++-multilib mingw32 tofrodos \
  python-markdown libxml2-utils xsltproc zlib1g-dev:i386 \
  bc schedtool unzip less
## Links 32bit libGL to the expected path
ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
## Installs && Set-ups CCache
apt-get install -y -q ccache
echo 'export CCACHE_PATH="/usr/bin"                 # Tell ccache to only use compilers here
export CCACHE_DIR=/tmp/ccache             # Tell ccache to use this path to store its cache
export USE_CCACHE=1' | tee --append /etc/profile.d/ccache.sh
chmod +x /etc/profile.d/ccache.sh
## Installs Repo (Android meta-git manager)
curl https://storage.googleapis.com/git-repo-downloads/repo | tee --append /usr/bin/repo
chmod +x /usr/bin/repo
