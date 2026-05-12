#!/data/data/com.termux/files/usr/bin/bash

# İnternet bağlantısını her komut öncesi otomatik sınayan wrapper.
# set -e sayesinde hata fırlatan komutlar zaten betiği durdurur;
# ağ kaynaklı hataları (pkg, proot-distro) burada yakalıyoruz.
run_with_net_check() {
    local description="$1"
    shift
    while true; do
        echo "$description"
        if "$@"; then
            return 0
        fi
        EXIT_CODE=$?
        echo ""
        echo "⚠️  Komut başarısız oldu (Çıkış kodu: $EXIT_CODE): $*"
        # Yaygın ağ hata kodları: curl=6,7,28 / pkg HTTP hatası vb.
        # Basit yaklaşım: kullanıcıya sor.
        echo "   Bu genellikle bir internet bağlantı sorunudur."
        read -p "   Tekrar denemek istiyor musunuz? (e/h): " retry
        if [[ $retry != "e" && $retry != "E" && $retry != "y" && $retry != "Y" ]]; then
            echo "Kurulum iptal edildi. Hata kodu: $EXIT_CODE"
            exit $EXIT_CODE
        fi
    done
}

echo "[*] 1/8 - Sistem güncelleniyor ve depolar ekleniyor..."
run_with_net_check "    pkg update çalışıyor..." pkg update -y
run_with_net_check "    pkg upgrade çalışıyor..." pkg upgrade -y -o Dpkg::Options::="--force-confold"
run_with_net_check "    Depolar ekleniyor..." pkg install -y x11-repo tur-repo
run_with_net_check "    pkg update (depolar sonrası)..." pkg update -y

echo "[*] 2/8 - Termux ana araçları kuruluyor..."
run_with_net_check "    Termux araçları yükleniyor..." \
    pkg install -y proot-distro termux-x11-nightly pulseaudio wget curl git nano termux-api

echo "[*] 3/8 - Debian altyapısı kontrol ediliyor..."
if proot-distro list | grep -q "^debian"; then
    echo ""
    echo "⚠️  Debian zaten kurulu bir proot-distro olarak tespit edildi."
    read -p "   Mevcut Debian kurulumunu silip yeniden kurmak istiyor musunuz? (e/h): " reinstall
    if [[ $reinstall == "e" || $reinstall == "E" || $reinstall == "y" || $reinstall == "Y" ]]; then
        echo "   Mevcut Debian kurulumu kaldırılıyor..."
        proot-distro remove debian
        echo "   Debian kaldırıldı."
        run_with_net_check "   Debian yeniden indiriliyor..." proot-distro install debian
    else
        echo "   Mevcut Debian kurulumu korunuyor, kuruluma devam ediliyor..."
    fi
else
    run_with_net_check "   Debian indiriliyor..." proot-distro install debian
fi
