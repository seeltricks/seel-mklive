#!/bin/sh

set -eu

. ./lib.sh

PROGNAME=$(basename "$0")
ARCH=$(uname -m)
IMAGES="base"
TRIPLET=
REPO=
DATE=$(date -u +%Y%m%d)

usage() {
	cat <<-EOH
	Usage: $PROGNAME [options ...] [-- mklive options ...]

	Wrapper script around mklive.sh for several standard flavors of live images.
	Adds void-installer and other helpful utilities to the generated images.

	OPTIONS
	 -a <arch>     Set XBPS_ARCH in the image
	 -d <date>     Override the datestamp on the generated image (YYYYMMDD format)
	 -r <repo>     Use this XBPS repository. May be specified multiple times
	 -h            Show this help and exit
	 -V            Show version and exit

	Other options can be passed directly to mklive.sh by specifying them after the --.
	See mklive.sh -h for more details.
	EOH
}

while getopts "a:d:hr:V" opt; do
case $opt in
    a) ARCH="$OPTARG";;
    d) DATE="$OPTARG";;
    r) REPO="-r $OPTARG $REPO";;
    V) version; exit 0;;
    h) usage; exit 0;;
    *) usage >&2; exit 1;;
esac
done
shift $((OPTIND - 1))

INCLUDEDIR=$(mktemp -d)
trap "cleanup" INT TERM

cleanup() {
    rm -rf "$INCLUDEDIR"
}

setup_pipewire() {
    PKGS="$PKGS pipewire alsa-pipewire"
    mkdir -p "$INCLUDEDIR"/etc/xdg/autostart
    ln -sf /usr/share/applications/pipewire.desktop "$INCLUDEDIR"/etc/xdg/autostart/
    mkdir -p "$INCLUDEDIR"/etc/pipewire/pipewire.conf.d
    ln -sf /usr/share/examples/wireplumber/10-wireplumber.conf "$INCLUDEDIR"/etc/pipewire/pipewire.conf.d/
    ln -sf /usr/share/examples/pipewire/20-pipewire-pulse.conf "$INCLUDEDIR"/etc/pipewire/pipewire.conf.d/
    mkdir -p "$INCLUDEDIR"/etc/alsa/conf.d
    ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf "$INCLUDEDIR"/etc/alsa/conf.d
    ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf "$INCLUDEDIR"/etc/alsa/conf.d
}

build_variant() {
    variant="$1"
    shift
    IMG=void-live-${ARCH}-${DATE}-${variant}.iso
    GRUB_PKGS="grub-i386-efi grub-x86_64-efi"
    A11Y_PKGS="espeakup void-live-audio brltty"
    PKGS="dialog cryptsetup lvm2 mdadm void-docs-browse xtools-minimal xmirror chrony $A11Y_PKGS $GRUB_PKGS"
    #XORG_PKGS="xorg-minimal xorg-input-drivers xorg-video-drivers setxkbmap xauth font-misc-misc terminus-font dejavu-fonts-ttf orca"
    # TODO: Add necessary packages for wayland
    WAYLAND_PKGS=""
    SERVICES="sshd chronyd"

    # Extra complimentary packages and services to enable per my config
    PKGS=""
    SERVICES=""

    # TODO: Include my config in the ISO into $INCLUDEDIR, deal with user dir shenanigans

    setup_pipewire

    ./mklive.sh -a "$ARCH" -o "$IMG" -p "$PKGS" -S "$SERVICES" -I "$INCLUDEDIR" ${REPO} "$@"

	cleanup
}

if [ ! -x mklive.sh ]; then
    echo mklive.sh not found >&2
    exit 1
fi

if [ -x installer.sh ]; then
    MKLIVE_VERSION="$(PROGNAME='' version)"
    installer=$(mktemp)
    sed "s/@@MKLIVE_VERSION@@/${MKLIVE_VERSION}/" installer.sh > "$installer"
    install -Dm755 "$installer" "$INCLUDEDIR"/usr/bin/void-installer
    rm "$installer"
else
    echo installer.sh not found >&2
    exit 1
fi
