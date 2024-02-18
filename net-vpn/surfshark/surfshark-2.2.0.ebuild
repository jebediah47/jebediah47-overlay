# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2-utils xdg-utils systemd unpacker

DESCRIPTION="Surfshark VPN GUI client for Linux."
HOMEPAGE="https://surfshark.com"
SRC_URI="https://ocean.surfshark.com/debian/pool/main/s/surfshark_${PV}_amd64.deb -> ${P}.deb"
LICENSE="EULA"
KEYWORDS="~amd64"
SLOT="0"
IUSE=""

REDEPEND="media-libs/alsa-lib
        app-accessibility/at-spi2-core
        dev-libs/gjs
        dev-libs/nss
        gnome-base/gnome-keyring
        net-vpn/wireguard-tools"
DEPEND="${REDEPEND}"

S="${WORKDIR}"

src_unpack() {
    unpack ${A}
    unpack "${S}"/data.tar.xz
}

src_install() {
    doins -r *
    fperms 4755 /opt/Surfshark/chrome-sandbox || die
    fperms 644 /usr/lib/systemd/user/surfsharkd.service || die
    fperms 644 /usr/lib/systemd/system/surfsharkd2.service || die
    fperms 755 /opt/Surfshark/resources/dist/resources/surfsharkd.js || die
    fperms 755 '/opt/Surfshark/resources/dist/resources/surfsharkd2.js' || die
    fperms 755 '/opt/Surfshark/resources/dist/resources/update' || die
    fperms 755 '/opt/Surfshark/resources/dist/resources/diagnostics' || die
    fperms 755 '/etc/init.d/surfshark' || die
    fperms 755 '/etc/init.d/surfshark2' || die
    dosym /opt/Surfshark/surfshark /usr/bin/surfshark || die
}
