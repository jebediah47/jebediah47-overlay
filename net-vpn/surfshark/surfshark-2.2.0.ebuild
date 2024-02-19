# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils

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
    rm "${S}"/{control,data,debian,builder}* || die
}

src_install() {
    doins -r *
    # Give permissions to the files
    fperms 4755 '/opt/Surfshark/chrome-sandbox'
    fperms 755 '/opt/Surfshark/chrome_crashpad_handler'
    fperms 755 '/opt/Surfshark/libEGL.so'
    fperms 755 '/opt/Surfshark/libffmpeg.so'
    fperms 755 '/opt/Surfshark/libGLESv2.so'
    fperms 755 '/opt/Surfshark/libvk_swiftshader.so'
    fperms 755 '/opt/Surfshark/libvulkan.so.1'
    fperms 755 '/opt/Surfshark/surfshark'
    fperms 644 '/usr/lib/systemd/user/surfsharkd.service'
    fperms 644 '/usr/lib/systemd/system/surfsharkd2.service'
    fperms 755 '/opt/Surfshark/resources/dist/resources/surfsharkd.js'
    fperms 755 '/opt/Surfshark/resources/dist/resources/surfsharkd2.js'
    fperms 755 '/opt/Surfshark/resources/dist/resources/update'
    fperms 755 '/opt/Surfshark/resources/dist/resources/diagnostics'
    fperms 755 '/etc/init.d/surfshark'
    fperms 755 '/etc/init.d/surfshark2'
    dosym /opt/Surfshark/surfshark /usr/bin/${PN} || die
}

pkg_postinst() {
    case "$(ps -p 1 --no-headers -o '%c' | tr -d '\n')" in
    systemd)
        systemctl daemon-reload || true
        systemctl enable --global surfsharkd.service || true
        ;;
    init)
        update-rc.d surfshark defaults || true
        update-rc.d surfshark2 defaults || true
        /etc/init.d/surfshark restart || true
        /etc/init.d/surfshark2 restart || true
        ;;
    *)
        ewarn "Unsupported service manager"
        ;;
    esac

    xdg_desktop_database_update
    xdg_mimeinfo_database_update
}

pkg_prerm() {
    systemctl disable --global surfsharkd.service || true
    systemctl disable surfsharkd2.service || true

    systemctl stop surfsharkd2.service || true

    /etc/init.d/surfshark stop || true
    /etc/init.d/surfshark2 stop || true

    kill -15 $(pidof surfshark) || :
    kill -15 $(pgrep surfsharkd) || :

    rm -rf /run/surfshark || :
    rm -f /tmp/surfsharkd.sock || :
    rm -f /tmp/surfshark-electron.sock || :
    rm -f $XDG_RUNTIME_DIR/surfsharkd.sock || :
    rm -f $XDG_RUNTIME_DIR/surfshark-electron.sock || :

    rm -f '/usr/bin/surfshark' || :

    # Surfshark post-remove
    nmcli connection delete surfshark_ipv6 || true
    nmcli connection delete surfshark_wg || true
    nmcli connection delete surfshark_openvpn || true

    shopt -s globstar
    if [ "$1" = purge ]; then
        rm -rf /home/**/.config/Surfshark || true
    fi

    rm -rf /home/**/.cache/Surfshark || true

    iptables -S | grep surfshark_ks | sed -r '/.*comment.*surfshark_ks*/s/-A/iptables -D/e' || true
    ip6tables -S | grep surfshark_ks | sed -r '/.*comment.*surfshark_ks*/s/-A/ip6tables -D/e' || true
}

pkg_postrm() {
    xdg_desktop_database_update
    xdg_mimeinfo_database_update
}
