#!/data/data/com.termux/files/usr/bin/bash

clear
echo "================================================================"
echo "    GALAXY TAB S10+ | i3wm PRO DEV-SETUP (Tam Otomatik v6)      "
echo "================================================================"
echo ""
echo "[1/2] TEMEL ANDROID VE KLAVYE İZİNLERİ"
echo "----------------------------------------------------------------"
echo "Lütfen devam etmeden önce şu ayarları yaptığınızdan emin olun:"
echo "1. Ayarlar > Uygulamalar > Termux için 'Diğer uygulamaların"
echo "   üzerinde görüntüle' iznini açın."
echo "2. Termux ve Termux-X11 için pil optimizasyonunu kapatın"
echo "   (Kısıtlanmamış yapın)."
echo "3. Termux-X11 uygulamasını açıp 'Preferences' menüsünden"
echo "   'Prefer scancodes' seçeneğini AÇIK hale getirin."
echo "----------------------------------------------------------------"
read -p "Bu temel ayarları tamamladınız mı? (e/h): " base_confirm

if [[ $base_confirm != "e" && $base_confirm != "E" && $base_confirm != "y" && $base_confirm != "Y" ]]; then
    echo "Lütfen önce ayarları yapın ve betiği tekrar çalıştırın."
    exit 1
fi

echo ""
echo "[2/2] ANDROID PHANTOM PROCESS (ÇÖKME) KISITLAMASI"
echo "----------------------------------------------------------------"
echo "Eğer Linux masaüstünüz aniden siyah ekrana düşüp çöküyorsa, Android'in"
echo "arka plan işlem sınırını (Phantom Process) kaldırmalıyız. Adımları"
echo "hiçbir yeri atlamadan, sırasıyla uygulayın:"
echo ""
echo "1. GELİŞTİRİCİ SEÇENEKLERİNİ AÇIN:"
echo "   - Tabletinizin 'Ayarlar' uygulamasına girin."
echo "   - En alttaki 'Tablet hakkında' menüsüne, ardından 'Yazılım bilgileri'ne girin."
echo "   - Ekranda yazan 'Yapı numarası' yazısına üst üste 7-8 kez hızlıca dokunun."
echo "   - Ekran kilidi şifrenizi sorduğunda girin. Ekranda 'Geliştirici modu "
echo "     açıldı' yazısını göreceksiniz."
echo ""
echo "2. TERMUX'U HAZIRLAYIN:"
echo "   - Termux ekranını açın. Ekranın sol kenarından sağa doğru kaydırarak"
echo "     yan menüyü açın ve 'New session' diyerek yeni bir sekme başlatın."
echo "   - Şu komutu yazıp Enter'a basın: pkg install -y android-tools"
echo ""
echo "3. EKRANI İKİYE BÖLÜN (ÇOK ÖNEMLİ):"
echo "   - Tablette 'Ayarlar' ve 'Termux' uygulamaları ekranı ikiye bölmüş "
echo "     şekilde yan yana açık olmalı. (Uygulamalar arası geçiş yaparsanız "
echo "     güvenlik gereği port numarası anında değişir ve hata alırsınız)."
echo ""
echo "4. KABLOSUZ HATA AYIKLAMA (EŞLEŞTİRME):"
echo "   - Ayarlar'ın en ana menüsüne dönün, en alta inip yeni açılan "
echo "     'Geliştirici seçenekleri' menüsüne girin."
echo "   - Listeden 'Kablosuz hata ayıklama' (Wireless debugging) seçeneğini "
echo "     bulup yanındaki şalteri AÇIK hale getirin."
echo "   - Şalteri açtıktan sonra doğrudan 'Kablosuz hata ayıklama' YAZISINA"
echo "     dokunarak menünün içine girin."
echo "   - 'Cihazı eşleştirme koduyla eşleştir' seçeneğine dokunun."
echo "   - Ekranda kocaman bir 6 haneli kod ve altında 'Bağlantı Noktası' "
echo "     (Port) yazacak. Örn: 192.168.1.5:45678 (Buradaki port 45678'dir)."
echo "   - Termux'a geçip şunu yazın (45678 yerine ekrandaki portu yazın):"
echo "     adb pair 127.0.0.1:45678"
echo "   - Enter'a basın, sizden 'Enter pairing code' isteyecek. Ekrandaki"
echo "     6 haneli eşleştirme kodunu yazıp Enter'a basın. Başarılı diyecektir."
echo ""
echo "5. CİHAZA BAĞLANMA (CONNECT):"
echo "   - Ayarlar kısmındaki eşleştirme penceresini iptal/geri tuşuyla kapatın."
echo "   - Şimdi 'Kablosuz Hata Ayıklama' ANA ekranındasınız. Bu ekranda alt "
echo "     kısımda yer alan 'IP adresi ve Bağlantı noktası' bölümünde YENİ "
echo "     bir port yazar. (Eşleştirme portundan farklıdır)."
echo "   - Termux'a geçip bu yeni portla bağlanın (Örn yeni port 33445 ise):"
echo "     adb connect 127.0.0.1:33445"
echo ""
echo "6. SINIRI KALDIRMA KOMUTU:"
echo "   - Termux'ta 'connected to...' yazısını gördükten sonra son olarak "
echo "     şu uzun komutu yazıp (veya kopyalayıp) Enter'a basın:"
echo "     adb shell device_config put activity_manager max_phantom_processes 2147483647"
echo ""
echo "7. SON AŞAMA:"
echo "   - Komut sessizce çalışır, herhangi bir çıktı vermez. İşlem tamamdır."
echo "   - Yeni ayarların sisteme işlemesi için TABLETİNİZİ YENİDEN BAŞLATIN."
echo "----------------------------------------------------------------"
read -p "Bu ADB işlemini tamamladınız mı? (e/h): " adb_confirm

if [[ $adb_confirm != "e" && $adb_confirm != "E" && $adb_confirm != "y" && $adb_confirm != "Y" ]]; then
    echo "Lütfen önce ADB işlemini yapıp tableti yeniden başlatın."
    exit 1
fi

echo ""
echo "================================================================"
echo "                   KULLANICI BİLGİLERİ                          "
echo "================================================================"
read -p "Oluşturulacak Linux kullanıcı adını girin (küçük harf, boşluksuz): " USER_NAME
read -s -p "$USER_NAME için sudo şifresi belirleyin (yazarken görünmez): " USER_PASS
echo ""
echo ""

echo "[*] 1/7 - Sistem güncelleniyor ve depolar ekleniyor..."
pkg update -y
pkg upgrade -y -o Dpkg::Options::="--force-confold"
pkg install -y x11-repo tur-repo
pkg update -y

echo "[*] 2/7 - Termux ana araçları kuruluyor..."
pkg install -y proot-distro termux-x11-nightly pulseaudio wget curl git nano termux-api

echo "[*] 3/7 - Debian altyapısı indiriliyor..."
proot-distro install debian

echo "[*] 4/7 - Debian içine i3wm ve Geliştirici paketleri yükleniyor..."
proot-distro login debian --shared-tmp -- bash -c "
    apt update && apt upgrade -y
    DEBIAN_FRONTEND=noninteractive apt install -y i3-wm dmenu thunar xfce4-terminal mousepad falkon synaptic dbus-x11 build-essential python3 git curl wget sudo fonts-noto-cjk x11-xserver-utils
"

echo "[*] 5/7 - Kullanıcı oluşturuluyor ve SUDO yetkisi tanımlanıyor..."
proot-distro login debian --shared-tmp -- bash -c "
    useradd -m -s /bin/bash $USER_NAME
    usermod -aG sudo $USER_NAME
    echo '$USER_NAME:$USER_PASS' | chpasswd
    
    echo '$USER_NAME ALL=(ALL:ALL) ALL' > /etc/sudoers.d/$USER_NAME
    chmod 0440 /etc/sudoers.d/$USER_NAME
"

echo "[*] 6/7 - i3wm Klavye/HiDPI Optimizasyonları yapılıyor..."
proot-distro login debian --shared-tmp -- bash -c "
    echo 'Xft.dpi: 144' > /home/$USER_NAME/.Xresources
    
    mkdir -p /home/$USER_NAME/.config/i3
    cat << 'I3EOF' > /home/$USER_NAME/.config/i3/config
set \$mod Mod1

font pango:monospace 10

bindsym \$mod+Return exec xfce4-terminal
bindsym \$mod+d exec dmenu_run
bindsym \$mod+Shift+f exec falkon --no-sandbox
bindsym \$mod+e exec thunar

bindsym \$mod+Shift+q kill
bindsym \$mod+f fullscreen toggle
bindsym \$mod+space layout toggle split

bindsym \$mod+Left focus left
bindsym \$mod+Down focus down
bindsym \$mod+Up focus up
bindsym \$mod+Right focus right

bar {
        status_command i3status
        position bottom
}
I3EOF
    
    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/
"

echo "[*] 7/7 - Sistem başlatıcı (start-dev.sh) oluşturuluyor..."
mkdir -p ~/.shortcuts
cat > ~/.shortcuts/start-dev.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash

termux-wake-lock
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null

pulseaudio --start --exit-idle-time=-1
export PULSE_SERVER=127.0.0.1
termux-x11 :0 -ac &
sleep 3

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity

export DISPLAY=:0
proot-distro login debian --user $USER_NAME --shared-tmp -- bash -c "export DISPLAY=:0 && xrdb -nocpp -merge ~/.Xresources && dbus-launch --exit-with-session i3"

termux-wake-unlock
EOF

chmod +x ~/.shortcuts/start-dev.sh

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
echo "Pencereyi Kapat    : Alt + Shift + Q"
echo "Tam Ekran (Geçiş)  : Alt + F"
echo "Sudo (Yetki)       : Terminalde şifrenizi girerek kullanabilirsiniz."
echo "================================================================"
