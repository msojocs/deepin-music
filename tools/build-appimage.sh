#!/bin/bash
set -e
notice() {
    echo -e "\033[36m $1 \033[0m "
}
fail() {
    echo -e "\033[41;37m 失败 \033[0m $1"
}

root_dir=$(cd `dirname $0`/.. && pwd -P)
build_dir="$root_dir/build/AppDir"
tmp_dir="$root_dir/build/tmp"
src_dir="$root_dir/build/src"

###################### 准备 ##########################
cd $root_dir
# fix: crash for scan
sed -i 's#  register_all_function r#  // register_all_function r#' src/libdmusic/metadetector.cpp
sed -i 's#  register_all();#  // register_all();#' src/libdmusic/metadetector.cpp

##################### 构建 ###########################
mkdir -p $root_dir/build
cd $root_dir/build
sed -i 's#"-fPIC"#"-L/usr/lib/x86_64-linux-gnu -L/opt/Qt/5.15.2/gcc_64/lib -fPIC -fno-sized-deallocation"#' $root_dir/CmakeLists.txt
cmake .. && make
cd $root_dir

mkdir -p $build_dir $tmp_dir
mkdir -p $build_dir/usr/{bin,lib/x86_64-linux-gnu,share/applications,share/icons}
mkdir -p $build_dir/usr/share/icons/hicolor/scalable/apps

# desktop
cp src/music-player/data/deepin-music.desktop $build_dir/usr/share/applications
cp src/music-player/data/deepin-music.desktop $build_dir
# icon
cp src/music-player/icons/icons/deepin-music.svg $build_dir/usr/share/icons/hicolor/scalable/apps
cp src/music-player/icons/icons/deepin-music.svg $build_dir

# bin
cp -r $src_dir/libdmusic/libdmusic.a $build_dir/usr/lib
cp -r $src_dir/music-player $build_dir/usr/bin
cp -r $src_dir/music-player $build_dir/usr/lib

cat > "$build_dir/AppRun" <<- 'EOF'
#!/bin/bash
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$LD_LIBRARY_PATH"
exec $APPDIR/usr/bin/music-player/deepin-music -platformtheme deepin -style chameleon
EOF
chmod +x "$build_dir/AppRun"

# lib
cp /usr/lib/x86_64-linux-gnu/libicu*  $build_dir/usr/lib
# cp /opt/Qt/5.15.2/gcc_64/lib/libicu*  $build_dir/usr/lib
cp /opt/Qt/5.15.2/gcc_64/lib/libdtk*.so  $build_dir/usr/lib
cp /usr/lib/libudisk*  $build_dir/usr/lib
cp /opt/Qt/5.15.2/gcc_64/lib/libmpris*  $build_dir/usr/lib
cp /usr/lib/x86_64-linux-gnu/libKF5*  $build_dir/usr/lib
# cp /opt/Qt/5.15.2/gcc_64/lib/libQt5*  $build_dir/usr/lib
# ls /opt/Qt/5.15.2/gcc_64/lib | grep
# ls /usr/lib/x86_64-linux-gnu | grep

notice "下载AppImage构建工具 ACTION_MODE:$ACTION_MODE"
if [[ $ACTION_MODE == 'true' ]]; then
  appimagetool_host="github.com"
else
  appimagetool_host="download.fastgit.org"
fi
if [ ! -f "$tmp_dir/appimagetool-x86_64.AppImage" ];then
  wget "https://$appimagetool_host/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" \
    -O "$tmp_dir/appimagetool-x86_64.AppImage"
fi
chmod a+x "$tmp_dir/appimagetool-x86_64.AppImage"

notice "MAKE APPIMAGE"

$tmp_dir/appimagetool-x86_64.AppImage --version
$tmp_dir/appimagetool-x86_64.AppImage "$build_dir" "$root_dir/build/deepin-music.AppImage"
chmod +x "$root_dir/build/deepin-music.AppImage"
# "$root_dir/build/deepin-music.AppImage"
