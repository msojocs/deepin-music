#!/bin/bash

root_dir=$(cd `dirname $0`/.. && pwd -P)
cd $root_dir
mkdir -p build
cd build
cmake ..
make