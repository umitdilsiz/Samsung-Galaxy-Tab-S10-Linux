# 1. Geliştirilmiş Dondurma Betiği
cat << 'EOF' > ~/.termux/tasker/linux-sleep.sh
#!/data/data/com.termux/files/usr/bin/bash

# PRoot child process'lerini dondur
PROOT_PIDS=$(pgrep -f "proot")
if [ -n "$PROOT_PIDS" ]; then
    pkill -STOP -P $PROOT_PIDS 2>/dev/null
fi

# Ana servisleri dondur
pkill -STOP -f "proot|termux-x11|pulseaudio"

# İşlemciyi uykuya bırak
termux-wake-unlock
EOF

# 2. Geliştirilmiş Uyandırma Betiği
cat << 'EOF' > ~/.termux/tasker/linux-wake.sh
#!/data/data/com.termux/files/usr/bin/bash

# İşlemci uyku kilidini al
termux-wake-lock

# Ana servisleri uyandır
pkill -CONT -f "proot|termux-x11|pulseaudio"

# PRoot child process'lerini uyandır
PROOT_PIDS=$(pgrep -f "proot")
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

echo "İyileştirilmiş uyku/uyanma betikleri Termux:Tasker dizinine uygulandı."
