# Galaxy Tab S10+ (Android 14) Termux i3wm Geliştirici Ortamı

Bu depo, Samsung Galaxy Tab S10+ gibi yeni nesil Android 14 cihazlarda Termux ve PRoot kullanarak tam yetkili, donanım klavyesi uyumlu ve yüksek performanslı bir Debian + i3wm Linux geliştirme ortamı kurmanızı sağlayan betikleri içerir.

## 🌟 Çözülen Sorunlar

* **Klavye Çakışması:** Samsung klavyeleri Windows (Super) tuşunu yuttuğu için i3wm ana tuşu (Mod tuşu) **ALT (Mod1)** olarak ayarlanmıştır.
* **Gecikme (Lag):** Sanal ortamda hantal kalan görsel başlatıcılar yerine sıfır gecikmeli **dmenu** entegre edilmiştir.
* **Çökme (Phantom Process):** Android 12+ arka plan işlem sınırı için ADB tabanlı kalıcı çözüm sağlanmıştır.

---

## 📌 1. Ön Hazırlık (Zorunlu)

Kuruluma geçmeden önce cihazınızda şu ayarları yapmalısınız:

1. **Uygulamaları İndirin:** Termux ve Termux-X11 uygulamalarını Google Play yerine **F-Droid** veya GitHub üzerinden indirin.
2. **Android İzinleri:**
   * `Ayarlar > Uygulamalar > Termux` yolunu izleyip **"Diğer uygulamaların üzerinde görüntüle"** iznini verin.
   * Termux ve Termux-X11 için pil optimizasyonunu **"Kısıtlanmamış"** yapın.
3. **Termux-X11 Ayarı (Klavye için):**
   * Termux-X11 uygulamasını açın, `Preferences` menüsünden **`Prefer scancodes`** seçeneğini **AÇIK** konuma getirin.
   * Performans için `Display resolution mode` ayarını **Scaled** yapın.

---

## 🚀 2. Kurulum

Depoyu cihazınıza klonlayın ve kurulum betiğini çalıştırın:

```bash
pkg update && pkg install git -y
git clone -b main https://github.com/umitdilsiz/Samsung-Galaxy-Tab-S10-Linux.git
cd Samsung-Galaxy-Tab-S10-Linux
chmod +x setup.sh
bash setup.sh
```

*(Betik sizi adım adım yönlendirecek, eksik paketleri kuracak ve kullanıcı yetkilendirmelerini yapacaktır.)*

---

## ⚠️ 3. Kritik Adım: Android Phantom Process Kısıtlamasını Kaldırma

Eğer kurulumdan sonra masaüstünüz aniden siyah ekrana düşüp çöküyorsa, Android'in arka plan işlem sınırını kaldırmalısınız. Bu işlem cihazda sadece bir kez yapılır:

**A. Geliştirici Seçeneklerini Açın:**
* `Ayarlar > Tablet hakkında > Yazılım bilgileri` menüsüne girin.
* `Yapı numarası` yazısına üst üste 7-8 kez hızlıca dokunun. Şifrenizi girerek geliştirici modunu aktifleştirin.

**B. Termux'u Hazırlayın:**
* Termux'u açın. Sol kenardan sağa kaydırarak yan menüyü açın ve `New session` ile yeni bir sekme başlatın.
* Şu komutu çalıştırın: `pkg install -y android-tools`

**C. Ekranı İkiye Bölün (Çok Önemli!):**
* Tablette `Ayarlar` ve `Termux` ekranı ikiye bölmüş şekilde yan yana açık olmalı. (Uygulamalar arası normal geçiş yaparsanız güvenlik gereği port numarası anında değişir).

**D. Eşleştirme (Pairing):**
* Ayarlar'da `Geliştirici seçenekleri > Kablosuz hata ayıklama` şalterini açın ve **yazının üzerine tıklayarak** içine girin.
* `Cihazı eşleştirme koduyla eşleştir` seçeneğine dokunun. Ekranda 6 haneli bir kod ve "Bağlantı Noktası" (Port) yazacak (Örn: `192.168.1.5:45678`).
* Termux'a geçip yazın: `adb pair 127.0.0.1:45678` (45678 yerine kendi portunuzu yazın).
* Enter'a basın, ekrandaki 6 haneli kodu girin.

**E. Cihaza Bağlanma (Connect):**
* Ayarlar'daki eşleştirme penceresini kapatın.
* Ana `Kablosuz Hata Ayıklama` ekranında alt kısımdaki `IP adresi ve Bağlantı noktası` bölümünde YENİ bir port göreceksiniz.
* Termux'a geçip bağlanın: `adb connect 127.0.0.1:YENI_PORT`

**F. Sınırı Kaldırma:**
* Termux'ta `connected to...` yazısını gördükten sonra şu komutu çalıştırın:
  ```bash
  adb shell device_config put activity_manager max_phantom_processes 2147483647
  ```
* İşlem tamamdır. Yeni ayarların sisteme işlemesi için **TABLETİNİZİ YENİDEN BAŞLATIN.**

---

## ⌨️ 4. Kullanım ve Kısayollar

Sistemi başlatmak için Termux:Widget'ı kullanabilir veya terminale şunu yazabilirsiniz:
```bash
bash ~/.shortcuts/start-dev.sh
```

Samsung klavye kısıtlamaları nedeniyle tüm kısayollar **ALT** tuşuna ayarlıdır:

| Kısayol | İşlem |
| :--- | :--- |
| `Alt + Enter` | Terminali Aç (xfce4-terminal) |
| `Alt + D` | Uygulama Başlatıcıyı Aç (dmenu) |
| `Alt + E` | Dosya Yöneticisini Aç (Thunar) |
| `Alt + Shift + S` | Uyku Engelleyici Aç/Kapat (Sleep Toggle) |
| `Alt + Shift + Q` | Aktif Pencereyi Kapat |
| `Alt + F` | Tam Ekran Geçişi (Fullscreen toggle) |
| `Alt + Yön Tuşları` | Pencereler Arası Geçiş (Focus) |

**Sudo Kullanımı:** Kurulumda belirlediğiniz şifre ile terminalde `sudo` komutlarını kullanabilirsiniz.

---

## 🔋 5. Uyku Modu (Energy Saver) ve Otomasyon

Bu projede yer alan uyku modu betikleri (`sleep_linux.sh` ve `wake_linux.sh`), **MacroDroid**, **Tasker** veya benzeri otomasyon uygulamalarıyla entegre çalışmak üzere özel olarak tasarlanmıştır.

* **Çalışma Mantığı:** Tabletin ekranı kapatıldığında PRoot, Termux-X11 ve PulseAudio gibi ağır süreçleri tamamen dondurarak (suspend) işlemciyi serbest bırakır ve pil tasarrufu sağlar. Ekran açıldığında ise bu süreçleri tekrar uyandırarak (resume) kaldığınız yerden anında devam etmenizi sağlar.
* **Otomatik Aktarım:** Kurulum (setup.sh) esnasında, repodaki hazır `Debian_uyut.macro` ve `Debian_uyandir.macro` dosyaları otomatik olarak tabletinizin **İndirilenler/macrodroid_macros** klasörüne kopyalanır. MacroDroid uygulamasını açıp bu dosyaları doğrudan içeri aktarabilirsiniz.
* **Otomasyon Kurulumu:** Eğer sıfırdan kurmak isterseniz, Termux:Tasker eklentisini cihazınıza kurduktan sonra otomasyon uygulamanızda şu iki makroyu oluşturabilirsiniz:
  1. **Tetikleyici (Trigger):** Ekran Kapandığında ➔ **Eylem (Action):** Termux:Tasker eklentisi ile `~/.termux/tasker/sleep_linux.sh` betiğini çalıştır.
  2. **Tetikleyici (Trigger):** Ekran Açıldığında ➔ **Eylem (Action):** Termux:Tasker eklentisi ile `~/.termux/tasker/wake_linux.sh` betiğini çalıştır.
* **Termux:Widget Kısayolları:** Ana ekranınıza Termux:Widget eklentisi ile `start-dev`, `wake_linux` ve `sleep_linux` kısayollarını ekleyebilirsiniz. **Önemli Fark:** Widget üzerinden `sleep_linux` kısayoluna dokunduğunuzda, Debian içerisindeki Uyku Engelleyici'nin durumuna bakılmaksızın sistem *zorla* uyku moduna alınır. Ancak MacroDroid veya Tasker gibi otomasyon uygulamaları üzerinden otomatik tetiklenen uyutma işlemi, Uyku Engelleyici'nin durumunu kontrol etmeye devam eder.

> **Önemli İpucu:** Arka planda kesintisiz bir derleme veya indirme işlemi yapmak istediğinizde, i3wm üzerinden Uyku Engelleyici anahtarını (`Alt + Shift + S`) kapatarak (**OFF** konumuna alarak) ekran kapansa dahi otomasyon uygulamalarının sistemi uykuya geçirmesini engelleyebilirsiniz. Ana ekrandaki widget kısayolunu kullanarak ise engelleyici durumuna bakılmaksızın istediğiniz an sistemi zorla uyutabilirsiniz.
