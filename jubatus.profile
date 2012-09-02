#
# Shell profile for Jubatus build
#
# * Jubatus install directory is "../test-root" and
#   its absolute pathname is set to env-variable JUBATUS_TOP_DIR.
# * $JUBATUS_TOP_DIR/bin is prepended to PATH
# * PLUS_INCLUDE_PATH, LDFLAGS, LD_LIBRARY_PATH, PKG_CONFIG_PATH are set
#

install_dir=`readlink -f ..`/test-root

export JUBATUS_TOP_DIR=$install_dir

export PATH=$install_dir/bin:$PATH

export CPLUS_INCLUDE_PATH=$install_dir/include
export LDFLAGS=-L$install_dir/lib
export LD_LIBRARY_PATH=$install_dir/lib
export PKG_CONFIG_PATH=$install_dir/lib/pkgconfig
