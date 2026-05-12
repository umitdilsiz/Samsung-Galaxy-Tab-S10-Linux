#!/data/data/com.termux/files/usr/bin/bash

# ---- Hata ayıklama modunu aktifleştir ----
# Bir komut 0 dışında bir çıkış kodu dönerse hemen dur (internet hatası gibi
# beklenen yerlerde ayrıca kontrol yapacağız).
set -euo pipefail

# ---- Yardımcı fonksiyonlar ----

# İnternet bağlantısını sınar. Bağlantı yoksa kullanıcıya bildirir ve
# onay alındıktan sonra tekrar sınar. Başka türlü bir hata varsa çıkar.
check_internet() {
    while true; do
        if curl -fsS --max-time 5 https://github.com >/dev/null 2>&1; then
            return 0
        fi
        echo ""
        echo "⚠️  İnternet bağlantısı algılanamadı!"
        echo "   Lütfen Wi-Fi bağlantınızı kontrol edin."
        read -p "   Tekrar denemek istiyor musunuz? (e/h): " retry
        if [[ $retry != "e" && $retry != "E" && $retry != "y" && $retry != "Y" ]]; then
            echo "Kurulum iptal edildi."
            exit 1
        fi
    done
}

# ---- Depolama İzni (kurulum başlamadan bir kez al) ----
echo "================================================================"
echo "    GALAXY TAB S10+ | i3wm PRO DEV-SETUP (Tam Otomatik v6)      "
echo "================================================================"
echo ""
echo "[*] Depolama izni kontrol ediliyor..."
if [ ! -d ~/storage ]; then
    echo "    MacroDroid dosyalarını İndirilenler klasörüne kopyalamak için"
    echo "    depolama iznine ihtiyacımız var."
    termux-setup-storage
    echo "    Lütfen açılan izin penceresinde 'İzin Ver' tuşuna basın ve"
    read -p "    ardından devam etmek için Enter'a basın..."
fi
echo ""

# ---- İnternet Bağlantısı Kontrolü ----
echo "[*] İnternet bağlantısı kontrol ediliyor..."
check_internet
echo "    ✓ Bağlantı başarılı."
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
echo ""
echo "KISAYOL REHBERİ (Samsung Klavye: ALT = Mod tuşu)"
echo "================================================================"
echo ""
echo "── TEMEL ────────────────────────────────────────────────────"
echo "Terminal Aç         : Alt + Enter"
echo "Uygulama Başlatıcı  : Alt + D"
echo "Dosya Yöneticisi    : Alt + E"
echo "Tarayıcı            : Alt + Shift + F"
echo "Pencereyi Kapat     : Alt + Shift + Q"
echo "Tam Ekran (Geçiş)   : Alt + F"
echo "Uyku Engelleyici    : Alt + Shift + S"
echo ""
echo "── LAYOUT / DÜZEN ───────────────────────────────────────────"
echo "Yan Yana Böl        : Alt + H  (yatay)"
echo "Üst Alta Böl        : Alt + V  (dikey)"
echo "Düzen Değiştir      : Alt + Space  (split ↔ tabbed ↔ stacked)"
echo "Floating Geçiş      : Alt + Shift + Space"
echo "Boyutlandır         : Alt + R  (ok tuşlarıyla)"
echo ""
echo "── PENCERE ODAKLAMA (Focus) ─────────────────────────────────"
echo "Sola/Sağa/Yukarı/Aşağı Odak : Alt + Ok Tuşları"
echo "Floating ↔ Tiling Odak       : Alt + Tab"
echo ""
echo "── PENCERE TAŞIMA ───────────────────────────────────────────"
echo "Pencereyi Taşı      : Alt + Shift + Ok Tuşları"
echo ""
echo "── NİRİ-STYLE WORKSPACE (Sonsuz Kaydırma) ──────────────────"
echo "Sağdaki Workspace   : Alt + Ctrl + Sağ  (yoksa yeni açar)"
echo "Soldaki Workspace   : Alt + Ctrl + Sol  (sol sınırda durur)"
echo "Pencereyi Sağa Gönder : Alt + Ctrl + Shift + Sağ"
echo "Pencereyi Sola Gönder : Alt + Ctrl + Shift + Sol"
echo ""
echo "── DOKUNMATIK GESTURES (Tablet) ────────────────────────────"
echo "3 Parmak Sola Kaydır  → Sonraki Workspace"
echo "3 Parmak Sağa Kaydır  → Önceki Workspace"
echo "4 Parmak Yukarı       → Tam Ekran Aç/Kapat"
echo "4 Parmak Aşağı        → Pencereyi Kapat"
echo ""
echo "── DİREKT WORKSPACE ERİŞİMİ ────────────────────────────────"
echo "Workspace 1-9       : Alt + [1-9]"
echo "Pencereyi WS'ye Gönder : Alt + Shift + [1-5]"
echo "================================================================"
