#!/data/data/com.termux/files/usr/bin/bash

echo "[*] 7/8 - Sistem başlatıcı (start-dev.sh) oluşturuluyor..."
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
