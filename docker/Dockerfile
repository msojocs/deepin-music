FROM mamaship/qt5.15:v2

WORKDIR /workspace

RUN cat /etc/issue
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    apt update && \
    apt install -y cmake libqt5svg5 libqt5svg5-dev qttools5-dev qt5-default qtbase5-private-dev \
    libgsettings-qt-dev libgsettings-qt1 libgtest-dev qtmultimedia5-dev git librsvg2-dev libxi-dev \
    libxcb-util-dev libstartup-notification0-dev libcups2-dev &&\
    apt-get install -y --reinstall ca-certificates wget && \
    mkdir /usr/local/share/ca-certificates/cacert.org && \
    wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt && \
    update-ca-certificates && \
    git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
# dtk
RUN qmake -set prefix /usr
RUN mkdir -p /workplace/dtk && cd /workplace/dtk &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/dtkcommon.git && \
    cd dtkcommon && qmake && make && make install
RUN mkdir -p /workplace/dtk && cd /workplace/dtk &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/dtkcore.git && \
    cd dtkcore && qmake && make -nomake tests && make install
RUN mkdir -p /workplace/dtk && cd /workplace/dtk &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/dtkgui.git && \
    cd dtkgui && qmake && make -nomake tests && make install
RUN mkdir -p /workplace/dtk && cd /workplace/dtk &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/dtkwidget.git &&\
    cd dtkwidget && qmake QMAKE_INCDIR=/usr/include/x86_64-linux-gnu/qt5 && make -nomake tests && make install
# 以下，deepin-music
RUN mkdir -p /workplace/other && cd /workplace/other &&\
    git clone https://hub.fastgit.xyz/sailfishos/qtmpris.git &&\
    cd qtmpris && qmake && make && make install
RUN mkdir -p /workplace/other && cd /workplace/other &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/udisks2-qt5.git &&\
    cd udisks2-qt5 && qmake && make && make install
RUN apt install -y libdbusextended-qt5-dev libvlc-dev libvlccore-dev libtag1-dev libdframeworkdbus-dev libavcodec-dev libavformat-dev qtbase5-dev libkf5codecs-dev libicu-dev libicu60
# 修正安装路径 /home/qt/work/install -----> /opt/Qt/5.15.2/gcc_64
RUN for pc in /opt/Qt/5.15.2/gcc_64/lib/pkgconfig/*; \
    do \
        sed -i 's#/home/qt/work/install#/opt/Qt/5.15.2/gcc_64#' $pc;\
    done; \
    cat /opt/Qt/5.15.2/gcc_64/lib/pkgconfig/Qt5DBus.pc
RUN cp -r /opt/Qt/5.15.2/gcc_64/lib/pkgconfig/* /usr/lib/x86_64-linux-gnu/pkgconfig
RUN apt install -y libfuse2

