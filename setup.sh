#!/data/data/com.termux/files/usr/bin/bash

clear
echo "================================================================"
echo "    GALAXY TAB S10+ | i3wm PRO DEV-SETUP (Tam Otomatik v6)      "
echo "================================================================"
echo ""

# Ön Hazırlıklar ve İzinler
source ./scripts/01_pre_checks.sh

echo ""
echo "================================================================"
echo "                   KULLANICI BİLGİLERİ                          "
echo "================================================================"
read -p "Oluşturulacak Linux kullanıcı adını girin (küçük harf, boşluksuz): " USER_NAME
read -s -p "$USER_NAME için sudo şifresi belirleyin (yazarken görünmez): " USER_PASS
echo ""
echo ""

# Değişkenleri alt modüllerin erişebilmesi için dışa aktar (export)
export USER_NAME
export USER_PASS

# Temel Kurulumlar
source ./scripts/02_install_base.sh

# Masaüstü ve Kullanıcı Kurulumları
source ./scripts/03_install_desktop.sh

# Kısayolların Ayarlanması
source ./scripts/04_setup_shortcuts.sh

# Enerji Tasarrufu ve Uyku Betiklerinin Ayarlanması
source ./scripts/05_energy_saver.sh

echo ""
echo "================================================================"
echo "[+] KURULUM KUSURSUZ TAMAMLANDI!"
echo "Masaüstünü başlatmak için terminale şunu yazın:"
echo "bash ~/.shortcuts/start-dev.sh"
echo "================================================================"
echo "KISAYOL REHBERİ (Samsung Klavye Uyumluluğu İçin ALT Tuşu Kullanılır)"
echo "----------------------------------------------------------------"
echo "Terminali Aç       : Alt + Enter"
echo "Uygulama Başlatıcı : Alt + D (dmenu)"
echo "Dosya Yöneticisi   : Alt + E"
echo "Uyku Engelleyici   : Alt + Shift + S"
echo "Pencereyi Kapat    : Alt + Shift + Q"
echo "Tam Ekran (Geçiş)  : Alt + F"
echo "Sudo (Yetki)       : Terminalde şifrenizi girerek kullanabilirsiniz."
echo "================================================================"
