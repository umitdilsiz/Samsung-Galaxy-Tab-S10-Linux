# Termux:Tasker dizinini oluştur
mkdir -p ~/.termux/tasker

# 1. Geliştirilmiş Dondurma Betiği
cat << 'EOF' > ~/.termux/tasker/sleep_linux.sh
#!/data/data/com.termux/files/usr/bin/bash

# Sleep Switch Kontrolü (Eğer OFF ise uykuyu engeller)
SWITCH_FILE="/data/data/com.termux/files/usr/tmp/sleep_switch_status"
if [ -f "$SWITCH_FILE" ]; then
    STATUS=$(cat "$SWITCH_FILE")
    if [ "$STATUS" = "OFF" ]; then
        exit 0
    fi
fi

# PRoot child process'lerini dondur
PROOT_PIDS=$(pgrep -f "proot" | paste -sd,)
if [ -n "$PROOT_PIDS" ]; then
    pkill -STOP -P $PROOT_PIDS 2>/dev/null
fi

# Ana servisleri dondur
pkill -STOP -f "proot|termux-x11|pulseaudio"

# İşlemciyi uykuya bırak
termux-wake-unlock
EOF

# 2. Geliştirilmiş Uyandırma Betiği
cat << 'EOF' > ~/.termux/tasker/wake_linux.sh
#!/data/data/com.termux/files/usr/bin/bash

# İşlemci uyku kilidini al
termux-wake-lock

# Ana servisleri uyandır
pkill -CONT -f "proot|termux-x11|pulseaudio"

# PRoot child process'lerini uyandır
PROOT_PIDS=$(pgrep -f "proot" | paste -sd,)
if [ -n "$PROOT_PIDS" ]; then
    pkill -CONT -P $PROOT_PIDS 2>/dev/null
fi

# DBus'ı yenile (GUI kilitlenmelerini çözer)
pkill -HUP -f "dbus-daemon" 2>/dev/null

# PulseAudio TCP bağlantısını anlık kapat/aç yaparak canlandır
pactl suspend-sink 0 1 2>/dev/null
pactl suspend-sink 0 0 2>/dev/null
EOF

# İzinleri garantiye al
chmod 700 ~/.termux/tasker/*.sh

# Termux:Widget kısayollarını oluştur
echo "[*] Termux:Widget kısayolları (wake_linux, sleep_linux) oluşturuluyor..."
mkdir -p ~/.shortcuts

# Widget için zorunlu uyku betiği (uyku önleyiciyi umursamaz)
cat << 'EOF' > ~/.shortcuts/sleep_linux.sh
#!/data/data/com.termux/files/usr/bin/bash

# Widget üzerinden tetiklendiği için sleep_switch_status kontrolü atlanır
# Doğrudan sistem dondurulur

# PRoot child process'lerini dondur
PROOT_PIDS=$(pgrep -f "proot" | paste -sd,)
if [ -n "$PROOT_PIDS" ]; then
    pkill -STOP -P $PROOT_PIDS 2>/dev/null
fi

# Ana servisleri dondur
pkill -STOP -f "proot|termux-x11|pulseaudio"

# İşlemciyi uykuya bırak
termux-wake-unlock
EOF

# Widget için uyanma betiği (tasker betiğini çağırır)
cat << 'EOF' > ~/.shortcuts/wake_linux.sh
#!/data/data/com.termux/files/usr/bin/bash

# Tasker için oluşturulan uyanma betiğini kullan
~/.termux/tasker/wake_linux.sh
EOF

# Kısayol izinlerini ayarla
chmod +x ~/.shortcuts/sleep_linux.sh ~/.shortcuts/wake_linux.sh

# MacroDroid dosyalarının aktarılması
echo "[*] MacroDroid dosyaları cihazın İndirilenler (Download) klasörüne kopyalanıyor..."
mkdir -p ~/storage/downloads/macrodroid_macros 2>/dev/null
cp -r ./macrodroid_macros/*.macro ~/storage/downloads/macrodroid_macros/ 2>/dev/null

echo "[*] 8/8 - İyileştirilmiş uyku/uyanma betikleri uygulandı ve Macrolar 'İndirilenler' klasörüne kopyalandı."
