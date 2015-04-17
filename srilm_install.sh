#!/bin/bash
# SRILM installation steps 
# Supports 16-bit unicode characters (we'll install libiconv library). 
# Doesn't support max entropy models (we'll not install libLBFGS optimization library).
# Since we might have to do sudo for some of the commands, it is recommended
# to run the commands line by line.
# 

# ============================================
# Step 1: First download the SRILM package to your ~/Downloads directory.
## To be able to do this, register yourself at http://www.speech.sri.com/projects/srilm/download.html and then download. wget not possible.
## Latest version as of 04/16/15 is srilm-1.7.1.tar.gz
cd ~/Downloads
[[ -f srilm-1.7.1.tar.gz ]] || exit 1;  # srilm-1.7.1.tar.gz must be present

# ============================================
# Step 2: Install Dependencies
## Dependency 1: gawk
apt-get install gawk

## Dependency 2: libiconv (required if your lang model has 16-bit unicode characters. otherwise skip installing libiconv)
## Fetch the dependencies for libiconv
wget http://mirrors.kernel.org/ubuntu/pool/universe/liba/libapache-mod-encoding/libiconv-hook1_0.0.20021209-10ubuntu2_amd64.deb
dpkg -i libiconv-hook1_0.0.20021209-10ubuntu2_amd64.deb

wget http://mirrors.kernel.org/ubuntu/pool/universe/liba/libapache-mod-encoding/libiconv-hook-dev_0.0.20021209-10ubuntu2_amd64.deb
dpkg -i libiconv-hook-dev_0.0.20021209-10ubuntu2_amd64.deb

## Fetch package libiconv (latest package is libiconv-1.14.tar.gz)
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar -xvzf libiconv-1.14.tar.gz

## cd, configure, make all
cd libiconv-1.14/
./configure --prefix=/usr/local/lib/libiconv
make all

## This will cause an error due to srclib/stdio.h which looks sth like
## _GL_WARN_ON_USE ( .... "gets is a security hole" ) ... use fgets
## Use the hack below to get rid of the error.
sed -i '/\<gets is a security hole\>/d' srclib/stdio.h

## run make all again
make all

## run make install
make install

## add libiconv to our environment
echo -e "# libincov support\n/usr/local/lib/libiconv/lib" > /etc/ld.so.conf.d/libiconv.conf
ldconfig
cd ..

## optional sanity check
## ldconfig -v|grep -i "libiconv"
## This should show sth like:
## /usr/local/lib/libiconv/lib:
##		libcharset.so.1 -> libcharset.so.1.0.0
##		libiconv.so.2 -> libiconv.so.2.5.1

# ============================================
# Step 3: Install main srilm package 
## Assuming you have ~/Downloads/srilm-1.7.1.tar.gz 
## If not , register yourself http://www.speech.sri.com/projects/srilm/download.html to be able to download the pkg
## Latest version as of 04/16/15 is srilm-1.7.1.tar.gz
tar -xvzf srilm-1.7.1.tar.gz

## Change the default installation path to desired path. For me, desired path was "/usr/share/srilm"
## To do this, change the following line in Makefile 
## from "# SRILM = /home/speech/stolcke/project/srilm/devel" to "SRILM = /usr/share/srilm"
cd srilm-1.7.1
sed -i 's:# SRILM =.*:SRILM = /usr/share/srilm:' Makefile
cd ..

## Copy srilm to /usr/share/srilm, cd, and make
mkdir -p /usr/share/srilm
cp -R srilm-1.7.1/* /usr/share/srilm/
cd /usr/share/srilm/
make World

## After installation is complete, call a program and see if it outputs useful info.
 ./bin/i686-m64/ngram-count -help
 
# ============================================ 
# Step 4: Run some tests
make test
## You should see sth like:
## 
## *** Running test adapt-marginals ***
## 3.85user 0.01system 0:03.86elapsed 100%CPU (0avgtext+0avgdata 29444maxresident)k
## 0inputs+48outputs (0major+18831minor)pagefaults 0swaps
## adapt-marginals: stdout output IDENTICAL.
## adapt-marginals: stderr output IDENTICAL.
## 
## *** Running test class-ngram ***
## 0.08user 0.00system 0:00.08elapsed 98%CPU (0avgtext+0avgdata 11584maxresident)k
## 0inputs+616outputs (0major+3682minor)pagefaults 0swaps
## class-ngram: stdout output IDENTICAL.
## class-ngram: stderr output IDENTICAL.
## .
## .
## *** Running test select-vocab ***
## 7.19user 0.05system 0:06.65elapsed 108%CPU (0avgtext+0avgdata 19164maxresident)k
## 0inputs+1944outputs (0major+15133minor)pagefaults 0swaps
## select-vocab: stdout output IDENTICAL.
## select-vocab: stderr output IDENTICAL.
##
## Note 1: IDENTICAL means test outputs and reference outputs are identical. Hence, we are doing good :)
## Note 2: "select-vocab" is the last test that has to pass.


## Clean up
make cleanest
# ============================================ 

# Add to PATH 
## PATH=${PATH}:/usr/share/srilm/bin/i686-m64
[[ ! -z  `which ngram-count` ]] || echo "SRILM not visible to PATH"
