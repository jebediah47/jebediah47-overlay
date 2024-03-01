# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils

DESCRIPTION="Warp, the Rust-based terminal for developers and teams."
HOMEPAGE="https://warp.dev/"
SRC_URI="https://releases.warp.dev/stable/v0.2024.02.27.08.01.stable_03/warp-terminal_0.2024.02.27.08.01.stable.03_amd64.deb"
LICENSE="EULA"
KEYWORDS="~amd64"
SLOT="0"
IUSE=""
RESTRICT="strip"

REDEPEND="media-libs/fontconfig
        net-misc/curl
        media-libs/mesa
        x11-libs/libX11
        x11-libs/libxcb
        x11-libs/libXcursor
        x11-libs/libXi
        x11-libs/libxkbcommon
        sys-libs/zlib"
DEPEND="${REDEPEND}"

S="${WORKDIR}"

src_unpack() {
    unpack ${A}
    unpack "${S}"/data.tar.xz
    rm "${S}"/{control,data,debian}* || die
}

src_install() {
    doins -r *
    fperms 755 '/opt/warpdotdev/warp-terminal/crashpad_handler'
    fperms 755 '/opt/warpdotdev/warp-terminal/warp'
}

pkg_postinst() {
    dosym /opt/warpdotdev/warp-terminal/warp /usr/bin/${PN} || die
    xdg_desktop_database_update
    xdg_mimeinfo_database_update
}

pkg_prerm() {
    rm -f "/usr/bin/${PN}" || :
}

pkg_postrm() {
    xdg_desktop_database_update
    xdg_mimeinfo_database_update
}
