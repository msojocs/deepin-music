/*
 * Copyright (C) 2020 ~ 2021 Uniontech Software Technology Co., Ltd.
 *
 * Author:     ZouYa <zouya@uniontech.com>
 *
 * Maintainer: WangYu <wangyu@uniontech.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "vlcdynamicinstance.h"
#include <QDir>
#include <QLibrary>
#include <QLibraryInfo>
#include <QDebug>

const QString libvlccore = "libvlccore.so";
const QString libvlc = "libvlc.so";
const QString libcodec = "libavcodec.so";
const QString libformate = "libavformat.so";

VlcDynamicInstance::VlcDynamicInstance(QObject *parent) : QObject(parent)
{
    qDebug() << "=== VlcDynamicInstance 0";
    bool bret = loadVlcLibrary();
    qDebug() << "=== VlcDynamicInstance 1" << bret;
    Q_ASSERT(bret == true);
}

VlcDynamicInstance::~VlcDynamicInstance()
{
    libcore.unload();
    libdvlc.unload();
    libavcode.unload();
    libdformate.unload();
}

VlcDynamicInstance *VlcDynamicInstance::VlcFunctionInstance()
{
    static VlcDynamicInstance  vlcinstance;
    return &vlcinstance;
}

QFunctionPointer VlcDynamicInstance::resolveSymbol(const char *symbol, bool bffmpeg)
{
    if (m_funMap.contains(symbol)) {
        return m_funMap[symbol];
    }

    if (bffmpeg) {
        QFunctionPointer fgp = libavcode.resolve(symbol);
        if (!fgp) {
            fgp = libdformate.resolve(symbol);
            if (!fgp) {
                //never get here if obey the rule
                qDebug() << "[VlcDynamicInstance::resolveSymbol] resolve function:" << symbol;
            }
        }
        m_funMap[symbol] = fgp;
        return fgp;
    }
    //resolve function
    QFunctionPointer fp = libdvlc.resolve(symbol);
    if (!fp) {
        fp = libcore.resolve(symbol);
    }

    if (!fp) {
        //never get here if obey the rule
        qDebug() << "[VlcDynamicInstance::resolveSymbol] resolve function:" << symbol;
        return fp;
    } else {
        //cache fuctionpointer for next visiting
        m_funMap[symbol] = fp;
    }

    return fp;
}

bool VlcDynamicInstance::loadVlcLibrary()
{
    QString strvlccore = libPath(libvlccore);
    qDebug() << "=== load lib: " << strvlccore;
    if (QLibrary::isLibrary(strvlccore)) {
        libcore.setFileName(strvlccore);
        if (!libcore.load())
            return false;
    } else {
        return false;
    }

    QString strlibvlc = libPath(libvlc);
    qDebug() << "=== load lib: " << strlibvlc;
    if (QLibrary::isLibrary(strlibvlc)) {
        qDebug() << "=== load0: " << strlibvlc;
        libdvlc.setFileName(strlibvlc);
        qDebug() << "=== load1: " << strlibvlc;
        if (!libdvlc.load()) {
            qDebug() << "=== load failed: " << strlibvlc;
            return false;
        }
    } else {
        qDebug() << "=== not lib: " << strlibvlc;
        return false;
    }

    QString strlibcodec = libPath(libcodec);
    qDebug() << "=== load lib: " << strlibcodec;
    if (QLibrary::isLibrary(strlibcodec)) {
        libavcode.setFileName(strlibcodec);
        if (!libavcode.load()) {
            return false;
        }
    } else {
        return false;
    }

    QString strlibformate = libPath(libformate);
    qDebug() << "=== load lib: " << strlibformate;
    if (QLibrary::isLibrary(strlibformate)) {
        libdformate.setFileName(strlibformate);
        if (!libdformate.load()) {
            qDebug() << "=== load fail: " << strlibcodec << " - " << libdformate.errorString();
            return false;
        }
    } else {
        return false;
    }
    qDebug() << "=== load lib: over";
    return true;
}

QString VlcDynamicInstance::libPath(const QString &strlib)
{
    QDir  dir;
    QString path  = QLibraryInfo::location(QLibraryInfo::LibrariesPath);
    dir.setPath(path);
    QStringList list = dir.entryList(QStringList() << (strlib + "*"), QDir::NoDotAndDotDot | QDir::Files); //filter name with strlib
    if (list.contains(strlib)) {
        return path + "/" + strlib;
    } else {
        list.sort();
    }

    Q_ASSERT(list.size() > 0);
    return path + "/" + list.last();
}
