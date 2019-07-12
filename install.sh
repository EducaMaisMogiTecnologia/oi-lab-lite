#!/bin/bash

install_udev () {
    udev_dir=/etc/udev/rules.d
    udev_file=71-seat-tn.rules

    install -m 644 udev/${udev_file} ${udev_dir}

    udevadm control --reload-rules
    udevadm trigger
}

install_xorg () {
    xorg_dir=/etc/X11/xorg.conf.d
    xorg_file=90-seat-sm501.conf
    xorg_update_script=oi-lab-lite-update-xorg-conf

    install -d ${xorg_dir}
    install -m 644 xorg/${xorg_file} ${xorg_dir}
    install -m 755 scripts/${xorg_update_script} /usr/local/bin

    ${xorg_update_script} ${xorg_dir}/${xorg_file}
}

install_lightdm () {
    lightdm_dir=/etc/xdg/lightdm/lightdm.conf.d

    install -d ${lightdm_dir}
    install -m 644 lightdm/*.conf ${lightdm_dir}

    systemctl restart lightdm
}

install_userful_rescue () {
    ur_prefix="/boot/userful-rescue"
    ur_file="userful-rescue-live-20160628-i386.iso"
    ur_google_id='0B_0RrXAKZ1hbdnRvcGRuSFc2Nkk'
    ur_google_prefix='https://drive.google.com/uc?export=download'

    if ! [ -f "${ur_prefix}/${ur_file}" ]
    then
        (
            [ -d "${ur_prefix}" ] || mkdir -p ${ur_prefix}
            filename="$(curl -sc /tmp/gcookie "${ur_google_prefix}&id=${ur_google_id}" | grep -o '="uc-name.*</span>' | sed 's/.*">//;s/<.a> .*//')"
            getcode="$(awk '/_warning_/ {print $NF}' /tmp/gcookie)"
            curl -Lb /tmp/gcookie -C - "${ur_google_prefix}&confirm=${getcode}&id=${ur_google_id}" -o "${ur_prefix}/${ur_file}"
            rm -f /tmp/gcookie
        ) || exit 1
    fi

    if [[ -x $(which update-grub) ]]
    then
        update-grub
    else
        grub2-mkconfig -o /boot/grub*/grub.cfg
    fi

    install -m 644 systemd/userful-rescue-* /etc/systemd/system
    install -m 755 scripts/userful-rescue-{enable,disable} /usr/local/bin
    install -m 755 grub/42_userful-rescue /etc/grub.d
}

install_freeze () {
    pam_file=pam_mount.conf.xml
    pam_dir=/etc/security

    install -m 755 scripts/oi-lab-lite-freeze-* /usr/local/bin

    if [[ -f ${pam_dir}/${pam_file} ]]
    then
        mv ${pam_dir}/${pam_file}{,.bkp}
    elif [[ ! -d ${pam_dir} ]]
    then
        install -d ${pam_dir}
    fi

    install -m 644 pam/${pam_file} ${pam_dir}
    install -d ${pam_dir}/limits.d
    install -m 644 pam/limits.d/* ${pam_dir}/limits.d
}

install_udev
install_xorg
install_freeze
install_userful_rescue
[[ -x $(which lightdm) ]] && install_lightdm
