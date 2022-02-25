#!/bin/bash

set -x

### Install Build Tools #1

DEBIAN_FRONTEND=noninteractive apt -qq update
DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	appstream \
	automake \
	autotools-dev \
	build-essential \
	checkinstall \
	cmake \
	curl \
	devscripts \
	equivs \
	extra-cmake-modules \
	gettext \
	git \
	gnupg2 \
	lintian \
	wget

### Add Neon Sources

wget -qO /etc/apt/sources.list.d/neon-user-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.neon.user

DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
	55751E5D > /dev/null

curl -L https://packagecloud.io/nitrux/testing/gpgkey | apt-key add -;

wget -qO /etc/apt/sources.list.d/nitrux-testing-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.nitrux.testing

DEBIAN_FRONTEND=noninteractive apt -qq update

### Install Package Build Dependencies #2
### Maui Shell needs ECM > 5.70

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	kinit-dev \
	kded5-dev \
	libpolkit-agent-1-dev \
	libkf5activities-dev \
	libkf5activitiesstats-dev \
	libkf5config-dev \
	libkf5coreaddons-dev \
	libkf5crash-dev \
	libkf5declarative-dev \
	libkf5doctools-dev \
	libkf5i18n-dev \
	libkf5idletime-dev \
	libkf5itemmodels-dev \
	libkf5kio-dev \
	libkf5notifications-dev \
	libkf5notifyconfig-dev \
	libkf5people-dev \
	libkf5prison-dev \
	libkf5runner-dev \
	libkf5service-dev \
	libkf5su-dev \
	libkf5syntaxhighlighting-dev \
	libkf5texteditor-dev \
	libkf5unitconversion-dev \
	libkf5wallet-dev \
	libkf5wayland-dev \
	libphonon4qt5-dev \
	libpolkit-qt5-1-dev \
	libqt5svg5-dev \
	libqt5waylandcompositor5-dev \
	mauikit-filebrowsing-git \
	mauikit-git \
	qtbase5-dev \
	qtdeclarative5-dev \
	qtquickcontrols2-5-dev

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --only-upgrade \
	extra-cmake-modules

### Clone repo.

git clone --single-branch --branch master https://github.com/Nitrux/maui-shell.git

rm -rf maui-shell/{screenshots,wallpapers,LICENSE,README.md}

### Compile Source

mkdir -p maui-shell/build && cd maui-shell/build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu ..

make

### Run checkinstall and Build Debian Package
### DO NOT USE debuild, screw it

>> description-pak printf "%s\n" \
	'Maui Shell is a convergent shell for desktop, tablets and phones.' \
	'' \
	'Cask is the shell container and elements templates, such as panels, popups, cards etc.' \
	'' \
	'Zpace is the composer, which is the layout and places the windows' \
	'surfaces into the Cask container.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=maui-shell-git \
	--pkgversion=2.1.1+git+2 \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=lib \
	--pkgsource=maui-shell \
	--pakdir=../.. \
	--maintainer=uri_herrera@nxos.org \
	--provides=maui-shell-git \
	--requires="kinit,kded5,libc6,libpolkit-agent-1-0,libkf5activities5,libkf5activitiesstats5,libkf5configcore5,libkf5coreaddons5,libkf5crash5,libkf5declarative5,libkf5doctools5,libkf5i18n5,libkf5idletime5,libkf5itemmodels5,libkf5kiocore5,libkf5notifications5,libkf5notifyconfig5,libkf5people5,libkf5prison5,libkf5runner5,libkf5service5,libkf5su5,libkf5syntaxhighlighting,libkf5texteditor,libkf5unitconversion5,libkf5wallet5,libkf5wayland5,libphonon4qt5-4,libpolkit-qt5-1-1,libqt5core5a,libqt5gui5,libqt5qml5,libqt5svg5,libqt5waylandcompositor5,libqt5widgets5,libstdc++6,mauikit-filebrowsing-git \(\>= 2.1.1+git\),mauikit-git \(\>= 2.1.1+git\),qml-module-qt-labs-calendar,qml-module-qt-labs-platform" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
