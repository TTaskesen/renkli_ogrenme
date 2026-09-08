# Renkli Öğrenme 1.1.0 üretim hazırlığı

Bu belge, üretim erişimi başvurusu ve mağaza yayını öncesi son kontrol listesidir.

## Uygulama içi hazırlık

- [x] Veli kapısı: ayarlar, ilerleme sıfırlama, gizlilik, destek e-postası ve harici bağlantılar korunuyor.
- [x] Büyük metin, yüksek kontrast, renk adları, şekil ipuçları ve ses tekrarı ayarları cihazda saklanıyor.
- [x] Skorlar ve yıldızlar oyun ve seviye bazında tutuluyor; eski skor anahtarları okunmaya devam ediyor.
- [x] Renk denemesi/doğru cevap istatistikleri ve ilerleme sıfırlama eklendi.
- [x] Beş oyun türünde kolay, orta ve zor seviyeler farklı oynanış yoğunluğu sunuyor.
- [x] Türkçe, İngilizce, Fransızca ve Kurmançi ekran metinleri ile güvenli geri dönüş mevcut.
- [x] Reklam, analitik, hesap, bulut senkronizasyonu ve hassas Android izni eklenmedi.

## Otomatik doğrulama

- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `flutter build appbundle --release` (imza anahtarı mevcutsa)
- `git diff --check`

## Manuel cihaz matrisi (bekliyor)

| Alan | Android telefon | Küçük ekran | Büyük metin/yüksek kontrast | Dört dil | Sonuç |
|---|---|---|---|---|---|
| Veli kapısı ve sıfırlama | ☐ | ☐ | ☐ | ☐ | Bekliyor |
| Beş oyun × üç seviye | ☐ | ☐ | ☐ | ☐ | Bekliyor |
| İlerleme, renk istatistikleri, kalıcılık | ☐ | ☐ | ☐ | ☐ | Bekliyor |
| Ses aç/kapat ve TTS | ☐ | ☐ | ☐ | ☐ | Bekliyor |
| Beyaz şekillerin görünürlüğü ve logo varlıkları | ☐ | ☐ | ☐ | ☐ | Bekliyor |

## Play Console gönderiminden önce

- [ ] Gerçek imzalı AAB ve cihaz testi tamamlandı.
- [ ] Mağaza açıklaması, ekran görüntüleri, içerik derecelendirmesi ve hedef kitle beyanı gözden geçirildi.
- [ ] Gizlilik politikası URL'si erişilebilir ve mağaza kaydıyla aynı.
- [ ] Veri güvenliği formu, uygulamanın gerçek veri davranışıyla karşılaştırıldı.
- [ ] Üretim başvurusu gönderilmeden önce Google Play'in güncel kapalı test koşulları kontrol edildi.

Bu belge Play Console'a otomatik gönderim yapmaz; onay ve beyanlar hesap sahibinin sorumluluğundadır.
