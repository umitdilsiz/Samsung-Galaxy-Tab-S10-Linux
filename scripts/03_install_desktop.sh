#!/data/data/com.termux/files/usr/bin/bash

echo "[*] 4/8 - Debian içine i3wm ve Geliştirici paketleri yükleniyor..."
while true; do
    if proot-distro login debian --shared-tmp -- bash -c "
        apt update && apt upgrade -y
        DEBIAN_FRONTEND=noninteractive apt install -y \
            i3-wm i3blocks dmenu thunar xfce4-terminal mousepad falkon synaptic \
            dbus-x11 build-essential python3 git curl wget sudo \
            fonts-noto-cjk x11-xserver-utils \
            jq xdotool wmctrl libinput-tools python3-pip python3-i3ipc
    "; then
        break
    fi
    echo ""
    echo "⚠️  Debian paket kurulumu başarısız oldu."
    echo "   Bu genellikle bir internet bağlantı sorunudur."
    read -p "   Tekrar denemek istiyor musunuz? (e/h): " retry
    if [[ $retry != "e" && $retry != "E" && $retry != "y" && $retry != "Y" ]]; then
        echo "Kurulum iptal edildi."
        exit 1
    fi
done

# libinput-gestures kurulumu (Github üzerinden manuel)
proot-distro login debian --shared-tmp -- bash -c "
    rm -rf /tmp/libinput-gestures
    git clone https://github.com/bulletmark/libinput-gestures.git /tmp/libinput-gestures
    cd /tmp/libinput-gestures && make install
"

echo "[*] 5/8 - Kullanıcı oluşturuluyor ve SUDO yetkisi tanımlanıyor..."
proot-distro login debian --shared-tmp -- bash -c "
    useradd -m -s /bin/bash $USER_NAME 2>/dev/null || true
    usermod -aG sudo,input,video $USER_NAME
    echo '$USER_NAME:$USER_PASS' | chpasswd

    echo '$USER_NAME ALL=(ALL:ALL) ALL' > /etc/sudoers.d/$USER_NAME
    chmod 0440 /etc/sudoers.d/$USER_NAME
"

echo "[*] 6/8 - i3wm Klavye/HiDPI/Niri-Style Optimizasyonları yapılıyor..."
proot-distro login debian --shared-tmp -- bash -c "
    echo 'Xft.dpi: 144' > /home/$USER_NAME/.Xresources

    mkdir -p /home/$USER_NAME/.config/i3

    # ── smart_ws_next.sh ─────────────────────────────────────────────────
    # Sağa git: mevcut workspace'den büyük bir sonraki varsa oraya geç,
    # yoksa yeni (max+1) numaralı workspace oluştur ve oraya geç.
    cat << 'NEXTWSEOF' > /home/$USER_NAME/.config/i3/smart_ws_next.sh
#!/bin/bash
# Niri-style: sonsuz sağa kaydırma — sağda workspace yoksa yenisini oluştur

CURRENT=\$(i3-msg -t get_workspaces | jq '[.[] | select(.focused==true)] | .[0].num')
NEXT=\$(i3-msg -t get_workspaces | jq \"[.[] | .num | select(. > \$CURRENT)] | min\")

if [ \"\$NEXT\" = \"null\" ] || [ -z \"\$NEXT\" ]; then
    # Sağda workspace yok → yenisini oluştur
    NEW=\$((CURRENT + 1))
    i3-msg \"workspace number \$NEW\"
else
    i3-msg \"workspace number \$NEXT\"
fi
NEXTWSEOF
    chmod +x /home/$USER_NAME/.config/i3/smart_ws_next.sh

    # ── smart_ws_prev.sh ─────────────────────────────────────────────────
    # Sola git: mevcut workspace'den küçük bir öncekine geç.
    # Workspace 1'deysen dur (niri gibi sol sınır var).
    cat << 'PREVWSEOF' > /home/$USER_NAME/.config/i3/smart_ws_prev.sh
#!/bin/bash
# Niri-style: sol sınırda dur, workspace 1'in altına inme

CURRENT=\$(i3-msg -t get_workspaces | jq '[.[] | select(.focused==true)] | .[0].num')
PREV=\$(i3-msg -t get_workspaces | jq \"[.[] | .num | select(. < \$CURRENT)] | max\")

if [ \"\$PREV\" = \"null\" ] || [ -z \"\$PREV\" ]; then
    # Solda workspace yok → dur (niri gibi sol sınır)
    exit 0
else
    i3-msg \"workspace number \$PREV\"
fi
PREVWSEOF
    chmod +x /home/$USER_NAME/.config/i3/smart_ws_prev.sh

    # ── smart_ws_move_next.sh ─────────────────────────────────────────────
    # Aktif pencereyi bir sonraki workspace'e taşı (yoksa oluştur).
    cat << 'MOVENEXTEOF' > /home/$USER_NAME/.config/i3/smart_ws_move_next.sh
#!/bin/bash
CURRENT=\$(i3-msg -t get_workspaces | jq '[.[] | select(.focused==true)] | .[0].num')
NEXT=\$(i3-msg -t get_workspaces | jq \"[.[] | .num | select(. > \$CURRENT)] | min\")

if [ \"\$NEXT\" = \"null\" ] || [ -z \"\$NEXT\" ]; then
    NEW=\$((CURRENT + 1))
    i3-msg \"move container to workspace number \$NEW; workspace number \$NEW\"
else
    i3-msg \"move container to workspace number \$NEXT; workspace number \$NEXT\"
fi
MOVENEXTEOF
    chmod +x /home/$USER_NAME/.config/i3/smart_ws_move_next.sh

    # ── smart_ws_move_prev.sh ─────────────────────────────────────────────
    # Aktif pencereyi bir önceki workspace'e taşı.
    cat << 'MOVEPREVEOF' > /home/$USER_NAME/.config/i3/smart_ws_move_prev.sh
#!/bin/bash
CURRENT=\$(i3-msg -t get_workspaces | jq '[.[] | select(.focused==true)] | .[0].num')
PREV=\$(i3-msg -t get_workspaces | jq \"[.[] | .num | select(. < \$CURRENT)] | max\")

if [ \"\$PREV\" = \"null\" ] || [ -z \"\$PREV\" ]; then
    exit 0
else
    i3-msg \"move container to workspace number \$PREV; workspace number \$PREV\"
fi
MOVEPREVEOF
    chmod +x /home/$USER_NAME/.config/i3/smart_ws_move_prev.sh

    # ── smart_focus_next.sh ────────────────────────────────────────────────
    # Sağa odaklan, eğer aynı kalırsa (sağ sınırda ise) sonraki ekrana geç
    cat << 'FOCUSNEXTEOF' > /home/$USER_NAME/.config/i3/smart_focus_next.sh
#!/bin/bash
OLD_FOCUS=\$(i3-msg -t get_tree | jq '.. | objects | select(.focused == true) | .id')
i3-msg focus right
NEW_FOCUS=\$(i3-msg -t get_tree | jq '.. | objects | select(.focused == true) | .id')

if [ \"\$OLD_FOCUS\" = \"\$NEW_FOCUS\" ]; then
    bash ~/.config/i3/smart_ws_next.sh
fi
FOCUSNEXTEOF
    chmod +x /home/$USER_NAME/.config/i3/smart_focus_next.sh

    # ── smart_focus_prev.sh ────────────────────────────────────────────────
    # Sola odaklan, eğer aynı kalırsa (sol sınırda ise) önceki ekrana geç
    cat << 'FOCUSPREVEOF' > /home/$USER_NAME/.config/i3/smart_focus_prev.sh
#!/bin/bash
OLD_FOCUS=\$(i3-msg -t get_tree | jq '.. | objects | select(.focused == true) | .id')
i3-msg focus left
NEW_FOCUS=\$(i3-msg -t get_tree | jq '.. | objects | select(.focused == true) | .id')

if [ \"\$OLD_FOCUS\" = \"\$NEW_FOCUS\" ]; then
    bash ~/.config/i3/smart_ws_prev.sh
fi
FOCUSPREVEOF
    chmod +x /home/$USER_NAME/.config/i3/smart_focus_prev.sh

    # ── libinput-gestures.conf ───────────────────────────────────────────
    # 3 parmak yatay swipe → odak/workspace değiştir (niri hissi)
    mkdir -p /home/$USER_NAME/.config
    cat << 'GESTUREEOF' > /home/$USER_NAME/.config/libinput-gestures.conf
# 3 parmak sola kaydır → sağdaki uygulamaya/ekrana geç
gesture swipe left  3 bash /home/$USER_NAME/.config/i3/smart_focus_next.sh

# 3 parmak sağa kaydır → soldaki uygulamaya/ekrana geç
gesture swipe right 3 bash /home/$USER_NAME/.config/i3/smart_focus_prev.sh

# 4 parmak yukarı → fullscreen toggle
gesture swipe up    4 i3-msg fullscreen toggle

# 4 parmak aşağı → pencereyi kapat
gesture swipe down  4 i3-msg kill
GESTUREEOF

    # ── i3 config ───────────────────────────────────────────────────────
    cat << 'I3EOF' > /home/$USER_NAME/.config/i3/config
# ════════════════════════════════════════════════════════════
#   Samsung Galaxy Tab S10+ │ i3wm  (Niri-Style Workspace)
# ════════════════════════════════════════════════════════════

set \$mod Mod1

font pango:monospace 10

# Yeni pencereler varsayılan olarak yatay yerleşir (niri benzeri)
default_orientation horizontal

# ── Temel Kısayollar ────────────────────────────────────────
bindsym \$mod+Return exec xfce4-terminal
bindsym \$mod+d      exec dmenu_run
bindsym \$mod+Shift+f exec falkon --no-sandbox
bindsym \$mod+e      exec thunar

# ── Pencere Kapatma & Tam Ekran ─────────────────────────────
bindsym \$mod+Shift+q kill
bindsym \$mod+f       fullscreen toggle

# ── LAYOUT (Düzen) Kısayolları ──────────────────────────────
# Yan yana bölme (varsayılan — niri gibi)
bindsym \$mod+h split h

# Üst alta bölme
bindsym \$mod+v split v

# Düzen geçişi: split ↔ tabbed ↔ stacked
bindsym \$mod+space layout toggle split tabbed stacked

# Floating ↔ Tiling geçiş
bindsym \$mod+Shift+space floating toggle

# ── PENCERE ODAKLAMA (Focus) ────────────────────────────────
bindsym \$mod+Left  exec bash ~/.config/i3/smart_focus_prev.sh
bindsym \$mod+Down  focus down
bindsym \$mod+Up    focus up
bindsym \$mod+Right exec bash ~/.config/i3/smart_focus_next.sh

# Floating pencereler arasında dolaş
bindsym \$mod+Tab focus mode_toggle

# ── PENCERE TAŞIMA ──────────────────────────────────────────
bindsym \$mod+Shift+Left  move left
bindsym \$mod+Shift+Down  move down
bindsym \$mod+Shift+Up    move up
bindsym \$mod+Shift+Right move right

# ── NİRİ-STYLE WORKSPACE NAVIGASYONU ───────────────────────
# Sağa: mevcut workspace'in sağındakine geç (yoksa yeni aç)
bindsym \$mod+ctrl+Right exec bash ~/.config/i3/smart_ws_next.sh

# Sola: mevcut workspace'in solundakine geç (sol sınırda dur)
bindsym \$mod+ctrl+Left  exec bash ~/.config/i3/smart_ws_prev.sh

# Aktif pencereyi sağdaki workspace'e taşı (ve oraya geç)
bindsym \$mod+ctrl+Shift+Right exec bash ~/.config/i3/smart_ws_move_next.sh

# Aktif pencereyi soldaki workspace'e taşı (ve oraya geç)
bindsym \$mod+ctrl+Shift+Left  exec bash ~/.config/i3/smart_ws_move_prev.sh

# ── KLASİK WORKSPACE KISAYOLLARI (Direkt Erişim) ───────────
bindsym \$mod+1 workspace number 1
bindsym \$mod+2 workspace number 2
bindsym \$mod+3 workspace number 3
bindsym \$mod+4 workspace number 4
bindsym \$mod+5 workspace number 5
bindsym \$mod+6 workspace number 6
bindsym \$mod+7 workspace number 7
bindsym \$mod+8 workspace number 8
bindsym \$mod+9 workspace number 9

bindsym \$mod+Shift+1 move container to workspace number 1
bindsym \$mod+Shift+2 move container to workspace number 2
bindsym \$mod+Shift+3 move container to workspace number 3
bindsym \$mod+Shift+4 move container to workspace number 4
bindsym \$mod+Shift+5 move container to workspace number 5

# ── PENCERE BOYUTLANDIRMA (Resize Modu) ─────────────────────
mode \"resize\" {
    bindsym Left  resize shrink width  30 px or 5 ppt
    bindsym Right resize grow   width  30 px or 5 ppt
    bindsym Up    resize shrink height 30 px or 5 ppt
    bindsym Down  resize grow   height 30 px or 5 ppt
    bindsym Return mode \"default\"
    bindsym Escape mode \"default\"
}
bindsym \$mod+r mode \"resize\"

# ── UYKU KİLİDİ ─────────────────────────────────────────────
bindsym \$mod+Shift+s exec bash ~/.config/i3/toggle_sleep.sh

# ── i3 YÖNETİMİ ─────────────────────────────────────────────
# Config'i yeniden yükle (kısayolları güncellemek için)
bindsym \$mod+Shift+r reload
# i3'ü yeniden başlat
bindsym \$mod+Shift+e restart

# ── OTOMATİK BAŞLATMA ───────────────────────────────────────
# Not: i3 exec shell üzerinden geçirmez; shell operatörleri için bash -c gerekir
exec --no-startup-id bash -c \"libinput-gestures-setup start 2>/dev/null || true\"
exec_always --no-startup-id ~/.config/i3/autoname_workspaces.py

# ── DURUM ÇUBUĞU ────────────────────────────────────────────
bar {
    status_command i3blocks -c ~/.config/i3/i3blocks.conf
    position bottom
    strip_workspace_numbers yes
}
I3EOF

    # ── toggle_sleep.sh ─────────────────────────────────────────────────
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

    # ── i3blocks.conf ────────────────────────────────────────────────────
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

    # ── autoname_workspaces.py ───────────────────────────────────────────
    cat << 'AUTONAMEEOF' > /home/$USER_NAME/.config/i3/autoname_workspaces.py
#!/usr/bin/env python3
import i3ipc

def rename_workspaces(i3):
    try:
        workspaces = i3.get_workspaces()
        for workspace in workspaces:
            ws_tree = i3.get_tree().find_by_id(workspace.ipc_data['id'])
            
            window_classes = []
            for leaf in ws_tree.leaves():
                if leaf.window_class:
                    name = leaf.window_class.lower()
                    if name == "xfce4-terminal":
                        name = "Terminal"
                    window_classes.append(name.capitalize())
            
            num = workspace.num
            if num == -1:
                continue
                
            if not window_classes:
                new_name = str(num)
            else:
                unique_classes = []
                for w in window_classes:
                    if w not in unique_classes:
                        unique_classes.append(w)
                new_name = f"{num}: {' - '.join(unique_classes)}"
                
            if workspace.name != new_name:
                i3.command(f'rename workspace "{workspace.name}" to "{new_name}"')
    except Exception as e:
        pass

def main():
    i3 = i3ipc.Connection()
    
    def on_change(i3, e):
        rename_workspaces(i3)
        
    i3.on('window::new', on_change)
    i3.on('window::close', on_change)
    i3.on('window::move', on_change)
    i3.on('workspace::focus', on_change)
    i3.on('window::title', on_change)
    
    rename_workspaces(i3)
    i3.main()

if __name__ == '__main__':
    main()
AUTONAMEEOF
    chmod +x /home/$USER_NAME/.config/i3/autoname_workspaces.py

    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/
"
