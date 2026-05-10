#!/data/data/com.termux/files/usr/bin/bash

echo "[*] 4/8 - Debian içine i3wm ve Geliştirici paketleri yükleniyor..."
proot-distro login debian --shared-tmp -- bash -c "
    apt update && apt upgrade -y
    DEBIAN_FRONTEND=noninteractive apt install -y i3-wm i3blocks dmenu thunar xfce4-terminal mousepad falkon synaptic dbus-x11 build-essential python3 git curl wget sudo fonts-noto-cjk x11-xserver-utils
"

echo "[*] 5/8 - Kullanıcı oluşturuluyor ve SUDO yetkisi tanımlanıyor..."
proot-distro login debian --shared-tmp -- bash -c "
    useradd -m -s /bin/bash $USER_NAME
    usermod -aG sudo $USER_NAME
    echo '$USER_NAME:$USER_PASS' | chpasswd
    
    echo '$USER_NAME ALL=(ALL:ALL) ALL' > /etc/sudoers.d/$USER_NAME
    chmod 0440 /etc/sudoers.d/$USER_NAME
"

echo "[*] 6/8 - i3wm Klavye/HiDPI Optimizasyonları yapılıyor..."
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

# Uyku Kilidi / Sleep Toggle
bindsym \$mod+Shift+s exec bash ~/.config/i3/toggle_sleep.sh

bindsym \$mod+Left focus left
bindsym \$mod+Down focus down
bindsym \$mod+Up focus up
bindsym \$mod+Right focus right

bar {
        status_command i3blocks -c ~/.config/i3/i3blocks.conf
        position bottom
}
I3EOF

    cat << 'SLEEPEOF' > /home/$USER_NAME/.config/i3/toggle_sleep.sh
#!/bin/bash
FILE=\"/tmp/sleep_switch_status\"
if [ ! -f \"\$FILE\" ]; then
    echo \"OFF\" > \"\$FILE\"
else
    STATUS=\$(cat \"\$FILE\")
    if [ \"\$STATUS\" = \"ON\" ]; then
        echo \"OFF\" > \"\$FILE\"
    else
        echo \"ON\" > \"\$FILE\"
    fi
fi
pkill -RTMIN+1 i3blocks
SLEEPEOF
    chmod +x /home/$USER_NAME/.config/i3/toggle_sleep.sh

    cat << 'BLOCKSEOF' > /home/$USER_NAME/.config/i3/i3blocks.conf
[sleep]
command=if [ -f /tmp/sleep_switch_status ] && [ \"\$(cat /tmp/sleep_switch_status)\" = \"OFF\" ]; then echo \"Sleep: OFF 🔴\"; else echo \"Sleep: ON 🟢\"; fi
interval=2
signal=1

[disk]
command=df -h / | awk '/\// {print \"💾 \" \$4 \" free\"}'
interval=60

[time]
command=date '+🕒 %Y-%m-%d %H:%M'
interval=5
BLOCKSEOF
    
    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/
"
