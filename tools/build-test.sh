#!/bin/bash

root_dir=$(cd `dirname $0`/.. && pwd -P)

export PKG_CONFIG_PATH=/mnt/disk2/Deepin/deepin-music/tmp/files/lib/pkgconfig
cd $root_dir/build
cmake ..
make