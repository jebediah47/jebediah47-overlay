# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2-utils xdg-utils systemd unpacker

DESCRIPTION="Surfshark VPN GUI client for Linux."
HOMEPAGE="https://surfshark.com"
SRC_URI="https://ocean.surfshark.com/debian/pool/main/s/surfshark_${PV}_amd64.deb"
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
    unpack_deb "${A}"
}

src_install() {
    tar -xJf "${DISTDIR}/${A}" -C "${D}" || die
    dodoc "/opt/${PN}/resources/dist/resources/surfsharkd.js.LICENSE.txt"
}
