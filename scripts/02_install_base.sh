#!/data/data/com.termux/files/usr/bin/bash

echo "[*] 1/8 - Sistem güncelleniyor ve depolar ekleniyor..."
pkg update -y
pkg upgrade -y -o Dpkg::Options::="--force-confold"
pkg install -y x11-repo tur-repo
pkg update -y

echo "[*] 2/8 - Termux ana araçları kuruluyor..."
pkg install -y proot-distro termux-x11-nightly pulseaudio wget curl git nano termux-api

echo "[*] 3/8 - Debian altyapısı indiriliyor..."
proot-distro install debian
