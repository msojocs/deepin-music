#!/bin/bash
set -e
notice() {
    echo -e "\033[36m $1 \033[0m "
}
fail() {
    echo -e "\033[41;37m 失败 \033[0m $1"
}

root_dir=$(cd `dirname $0`/.. && pwd -P)
work_dir="$root_dir/work/appimage"
build_dir="$work_dir/AppDir"
tmp_dir="$work_dir/tmp"
src_dir="$work_dir/src"

###################### 准备 ##########################
mkdir -p $build_dir $tmp_dir $src_dir/build
cd $src_dir
if [[ ! -d $src_dir/deepin-music ]];then
  git clone --branch 6.2.12 https://github.com/linuxdeepin/deepin-music.git
fi
cd deepin-music
git checkout tags/6.2.12
# fix: crash for scan
sed -i 's#  register_all_function r#  // register_all_function r#' src/libdmusic/metadetector.cpp
sed -i 's#  register_all();#  // register_all();#' src/libdmusic/metadetector.cpp
sed -i 's#"-fPIC"#"-L/usr/lib/x86_64-linux-gnu -L/opt/Qt/5.15.2/gcc_64/lib -fno-sized-deallocation -fPIC"#' CMakeLists.txt

##################### 构建 ###########################
mkdir -p build
cd build
cmake .. && make && make install DESTDIR=$build_dir

notice "下载LinuxDeploy构建工具 ACTION_MODE:$ACTION_MODE"
if [[ $ACTION_MODE == 'true' ]]; then
  appimagetool_host="github.com"
else
  appimagetool_host="download.fastgit.org"
fi
if [ ! -f "$tmp_dir/linuxdeployqt-continuous-x86_64.AppImage" ];then
  wget "https://$appimagetool_host/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage" \
    -O "$tmp_dir/linuxdeployqt-continuous-x86_64.AppImage"
fi
chmod a+x "$tmp_dir/linuxdeployqt-continuous-x86_64.AppImage"

notice "MAKE APPIMAGE"
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
$tmp_dir/linuxdeployqt-continuous-x86_64.AppImage $build_dir/usr/local/share/applications/deepin-music.desktop -appimage
