# Renkli Öğrenme

Çocuklar için renkleri öğrenme ve renk oyunları uygulaması (Flutter).

## Özellikler

- **Renkleri Öğren** – Renk kartlarını gezin, Türkçe/İngilizce adlarını dinleyin (sesli okuma)
- **Renk Eşleştirme** – Söylenen rengi kartlar arasından bulun
- **Hafıza Oyunu** – Renk çiftlerini kartları çevirerek eşleştirin
- **Boyama** – Ev, ağaç, balık gibi resimleri seçtiğiniz renklerle boyayın
- **Yapboz** – Şekilleri doğru yuvaya sürükleyip bırakın
- **Renk Testi** – 10 soruluk renk testini çözün
- **Karşılama menüsü** – Logo, Oyna butonu, ses aç/kapat, toplam yıldız ve gizlilik politikası
- **Üç dilli arayüz** – Türkçe / English / Français (menüden anında değişir)
- **Skor ve yıldız sistemi** – Oyun sonuçları cihazda saklanır, en iyi skorlar ve toplam yıldız ana ekranda gösterilir
- **Geliştirici:** Turgut Taşkesen

## Kullanmaya Başlama

### Gereksinimler
- Flutter SDK (bu proje Flutter 3.44+ / Dart 3.12+ ile test edilmiştir)

### Çalıştırma

```sh
flutter pub get
flutter run
```

### Testler

```sh
flutter test
```

## Proje Yapısı

```
lib/
├── main.dart              # Uygulama girişi ve tema
├── data/                  # Renk ve çeviri verileri
├── models/                # Veri modelleri
├── screens/               # Oyun ekranları
├── services/              # Durum yönetimi ve TTS
└── widgets/               # Ortak bileşenler
```

## Uygulama İkonu

İkonu yeniden üretmek için (Android + iOS):

```sh
dart run flutter_launcher_icons
```

## Desteklenen Platformlar

Android, iOS (Flutter tarafından web ve Windows da desteklenir).
