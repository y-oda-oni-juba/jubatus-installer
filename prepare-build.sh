#/bin/sh

# prepare-build.sh
#
# * To download sources, 
#     ./prepare-build -d -p $JUBATUS_TOP_DIR
#
# * To build sources,
#     ./prepare-build -i -p $JUBATUS_TOP_DIR
#

MSG_VER="0.5.7"
GLOG_VER="0.3.2"
UX_VER="0.1.8"
MECAB_VER="0.99"
IPADIC_VER="2.7.0-20070801"
ZK_VER="3.4.3"
EVENT_VER="2.0.19"
PKG_VER="0.25"
# JUBA_VER="0.3.0"
PREFIX=${JUBATUS_TOP_DIR:-"${HOME}/local"}

while getopts dip: OPT
do
  case $OPT in
    "d" ) DOWNLOAD_ONLY="TRUE" ;;
    "i" ) INSTALL_ONLY="TRUE" ;;
    "p" ) PREFIX="$OPTARG" ;;
  esac
done

download_tgz(){
    # download_tgz URL SAVE_NAME
    if [ -n "$2" ]; then
        filename=$2
    else
        filename=${1##*/}
    fi
    if [ ! -f $filename ]; then
	wget -O $filename $1
    fi
}

if [ "${INSTALL_ONLY}" != "TRUE" ]
  then
    mkdir download
    cd download

    download_tgz http://msgpack.org/releases/cpp/msgpack-${MSG_VER}.tar.gz
    download_tgz http://google-glog.googlecode.com/files/glog-${GLOG_VER}.tar.gz
    download_tgz http://ux-trie.googlecode.com/files/ux-${UX_VER}.tar.bz2
    download_tgz http://mecab.googlecode.com/files/mecab-${MECAB_VER}.tar.gz
    download_tgz http://mecab.googlecode.com/files/mecab-ipadic-${IPADIC_VER}.tar.gz
    # download_tgz http://ftp.riken.jp/net/apache/zookeeper/zookeeper-${ZK_VER}/zookeeper-${ZK_VER}.tar.gz
    download_tgz http://ftp.tsukuba.wide.ad.jp/software/apache/zookeeper/zookeeper-${ZK_VER}/zookeeper-${ZK_VER}.tar.gz
    download_tgz http://github.com/downloads/libevent/libevent/libevent-${EVENT_VER}-stable.tar.gz
    download_tgz http://pkgconfig.freedesktop.org/releases/pkg-config-${PKG_VER}.tar.gz

    hg clone https://re2.googlecode.com/hg re2

    git clone https://github.com/pfi/pficommon.git
    
    if [ -n "$JUBA_VER" ] ;then
        download_tgz https://github.com/jubatus/jubatus/tarball/jubatus-${JUBA_VER} jubatus-${JUBA_VER}.tar.gz
    fi

    cd ..
fi

if [ "${DOWNLOAD_ONLY}" != "TRUE" ]
  then
    cd download

    tar zxf msgpack-${MSG_VER}.tar.gz
    # tar zxf glog-${GLOG_VER}-1.tar.gz
    tar zxf glog-${GLOG_VER}.tar.gz
    tar jxf ux-${UX_VER}.tar.bz2
    tar zxf mecab-${MECAB_VER}.tar.gz
    tar zxf mecab-ipadic-${IPADIC_VER}.tar.gz
    tar zxf zookeeper-${ZK_VER}.tar.gz
    tar zxf libevent-${EVENT_VER}-stable.tar.gz
    tar zxf pkg-config-${PKG_VER}.tar.gz

    if [ -n "$JUBA_VER" ]; then
        mkdir -p jubatus-${JUBA_VER}
        tar xvfzC jubatus-${JUBA_VER}.tar.gz jubatus-${JUBA_VER} --strip-components=1
    fi

    mkdir -p ${PREFIX}

    LD_LIBRARY_PATH=${PREFIX}/lib
    export LD_LIBRARY_PATH

    cd ./pkg-config-${PKG_VER}
    ./configure --prefix=${PREFIX}
    make
    make install

    cd ../msgpack-${MSG_VER}
    # cd ./msgpack-${MSG_VER}
    ./configure --prefix=${PREFIX}
    make
    make install

    cd ../glog-${GLOG_VER}
    ./configure --prefix=${PREFIX}
    make
    make install

    cd ../ux-${UX_VER}
    ./waf configure --prefix=${PREFIX}
    ./waf build
    ./waf install

    cd ../mecab-${MECAB_VER}
    ./configure --prefix=${PREFIX} --enable-utf8-only
    make
    make install

    cd ../mecab-ipadic-${IPADIC_VER}
    ./configure --prefix=${PREFIX} --with-charset=utf8
    make
    make install

    cd ../re2
    sed -i -e "s|/usr/local|${PREFIX}/|g" Makefile
    make
    make install

    cd ../libevent-${EVENT_VER}-stable
    ./configure --prefix=${PREFIX}
    make
    make install

    cd ../zookeeper-${ZK_VER}/src/c
    ./configure --prefix=${PREFIX}
    make
    make install

    cd ../../../pficommon
    ./waf configure --prefix=${PREFIX} --with-msgpack=${PREFIX}
    ./waf build
    ./waf install

    if [ -n "$JUBA_VER" ]; then
        cd ../jubatus-${JUBA_VER}

        ./waf configure --prefix=${PREFIX} --enable-ux --enable-mecab --enable-zookeeper
        ./waf build --checkall
        ./waf install
    fi
fi

