# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome2-utils xdg-utils systemd

DESCRIPTION="Surfshark VPN GUI client for Linux."
HOMEPAGE="https://surfshark.com"
SRC_URI="https://ocean.surfshark.com/debian/pool/main/s/surfshark_2.1.0-2503_amd64.deb"
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

RESTRICT="strip"

src_unpack() {
        mkdir -p "${S}"
        unpack surfshark_2.1.0-2503_amd64.deb "${S}"
}

src_install() {
        # Extract files from deb package
        dodir /opt/Surfshark
        insinto /opt/Surfshark
        doins -r "${WORKDIR}"opt/Surfshark/*

        insinto /usr/share/doc
        doins -r "${WORKDIR}"usr/share/doc/*
        insinto /usr/share/icons/hicolor/128x128/apps/
        doins -r "${WORKDIR}"usr/share/icons/hicolor/128x128/apps/surfshark.png
        insinto /usr/share/applications
        doins -r "${WORKDIR}"usr/share/applications/surfshark.desktop

        insinto /etc/init.d/
        doins -r "${WORKDIR}"etc/init.d/*

        insinto /var/lib/surfshark/
        doins -r var/lib/surfshark/surfshark/*

        # Post-install tasks
        dosym /opt/Surfshark/surfshark /usr/bin/surfshark
        chmod 4755 /opt/Surfshark/chrome-sandbox || true
        update-mime-database /usr/share/mime || true
        update-desktop-database /usr/share/applications || true

        # Systemd services
        insinto /usr/lib/systemd/user
        doins - \
                \
                surfsharkd.service <<<'
        [Unit]
        Description=Surfshark Daemon

        [Service]
        ExecStart=/opt/Surfshark/resources/dist/resources/surfsharkd.js
        Restart=on-failure
        RestartSec=5
        IPAddressDeny=any
        RestrictRealtime=true
        ProtectKernelTunables=true
        ProtectSystem=full
        RestrictSUIDSGID=true

        [Install]
        WantedBy=default.target
        ' || die "Failed to install surfsharkd.service"

        insinto /usr/lib/systemd/system
        doins - \
                \
                surfsharkd2.service <<<'
        [Unit]
        Description=Surfshark Daemon2

        [Service]
        ExecStart=/opt/Surfshark/resources/dist/resources/surfsharkd2.js
        Restart=on-failure
        RestartSec=5
        IPAddressDeny=any
        RestrictRealtime=true
        ProtectKernelTunables=true
        ProtectSystem=full
        RestrictSUIDSGID=true

        [Install]
        WantedBy=default.target
        ' || die "Failed to install surfsharkd2.service"

        chmod 644 /usr/lib/systemd/user/surfsharkd.service || die "Failed to set permissions for surfsharkd.service"
        chmod 644 /usr/lib/systemd/system/surfsharkd2.service || die "Failed to set permissions for surfsharkd2.service"

        # Set permissions for scripts and executables
        chmod 755 /opt/Surfshark/resources/dist/resources/surfsharkd.js || true
        chmod 755 /opt/Surfshark/resources/dist/resources/surfsharkd2.js || true
        chmod 755 /opt/Surfshark/resources/dist/resources/update || true
        chmod 755 /opt/Surfshark/resources/dist/resources/diagnostics || true
        chmod 755 /etc/init.d/surfshark || true
        chmod 755 /etc/init.d/surfshark2 || true

        # Enable services based on init system
        case "$(ps -p 1 --no-headers -o '%c' | tr -d '\n')" in
        systemd)
                systemctl daemon-reload || die "Failed to reload systemd"
                systemctl enable --global surfsharkd.service || die "Failed to enable surfsharkd.service"
                ;;
        init)
                # Enable services for init
                update-rc.d surfshark defaults || die "Failed to enable surfshark service for init"
                update-rc.d surfshark2 defaults || die "Failed to enable surfshark2 service for init"
                /etc/init.d/surfshark restart || die "Failed to restart surfshark service for init"
                /etc/init.d/surfshark2 restart || die "Failed to restart surfshark2 service for init"
                ;;
        *)
                die "Unsupported service manager"
                ;;
        esac

        xdg_icon_cache_update
}

pkg_postrm() {
        xdg_icon_cache_update

        # Disable and stop services
        systemctl disable --global surfsharkd.service || true
        systemctl disable surfsharkd2.service || true
        systemctl stop surfsharkd2.service || true
        /etc/init.d/surfshark stop || true
        /etc/init.d/surfshark2 stop || true

        # Terminate processes
        kill -15 $(pidof surfshark) || true
        kill -15 $(pgrep surfsharkd) || true

        # Remove temporary files and sockets
        rm -rf /run/surfshark || true
        rm -f /tmp/surfsharkd.sock || true
        rm -f /tmp/surfshark-electron.sock || true
        rm -f $XDG_RUNTIME_DIR/surfsharkd.sock || true
        rm -f $XDG_RUNTIME_DIR/surfshark-electron.sock || true

        # Remove symbolic link
        rm -f '/usr/bin/surfshark' || true

        # Remove NetworkManager connections
        nmcli connection delete surfshark_ipv6 || true
        nmcli connection delete surfshark_wg || true
        nmcli connection delete surfshark_openvpn || true

        # Remove configuration files in user home directories
        shopt -s globstar
        if [ "$1" = purge ]; then
                rm -rf /home/**/.config/Surfshark || true
        fi

        # Remove cache files in user home directories
        rm -rf /home/**/.cache/Surfshark || true

        # Remove iptables rules
        iptables -S | grep surfshark_ks | sed -r '/.*comment.*surfshark_ks*/s/-A/iptables -D/e' || true
        ip6tables -S | grep surfshark_ks | sed -r '/.*comment.*surfshark_ks*/s/-A/ip6tables -D/e' || true

        # Update desktop database
        update-desktop-database /usr/share/applications
}
