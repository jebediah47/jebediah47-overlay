# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils

DESCRIPTION="Warp, the Rust-based terminal for developers and teams
 Warp is a modern, Rust-based terminal with AI built in so teams can
 build great software, faster. Bringing collaboration to the command line,
 Warp lets teams save and share commands for streamlined onboarding and
 incident response."
HOMEPAGE="https://warp.dev/"
SRC_URI="https://releases.warp.dev/stable/v0.2024.02.20.08.01.stable_02/warp-terminal_0.2024.02.20.08.01.stable.02_amd64.deb"
LICENSE="EULA"
KEYWORDS="~amd64"
SLOT="0"
IUSE=""

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
    dosym /opt/warpdotdev/warp-terminal/warp /usr/bin/${PN} || die
}

pkg_postinst() {
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
