# Play Console kontrol listesi - reklamsız ilk sürüm

Bu taslak, `com.renkli.renkli_ogrenme` paketi ve reklamsız ilk sürüm içindir.
Play Console'da yalnızca son paketi ve gerçek uygulama davranışını doğruladıktan
sonra gönderilmelidir.

## App content

1. **Privacy policy:** `privacy-policy.html` için açık ve HTTPS çalışan adresi gir.
2. **Data safety:** Kod ve son AAB doğrulanırsa "uygulama gerekli kullanıcı verilerini toplamaz veya paylaşmaz" seçeneğini seç. Yerel oyun skoru/ayarları cihazdan dışarı gönderilmez.
3. **Ads:** Reklam içermez olarak beyan et.
4. **App access:** Giriş, hesap veya kısıtlı içerik yoktur; inceleme talimatı gerekmez.
5. **Content rating:** IARC anketini gerçek içerikle doldur. Uygulama şiddet, kumar, yetişkin içerik, kullanıcı üretimli içerik ve reklam içermez.
6. **Target audience and content:** Yaş gruplarını yalnızca hedeflediğin yaşlara göre seç. Çocuk yaş grubu seçilirse Families Policy uygulanır. Uygulama reklamsız ve izleyicisiz tasarlanmıştır.

## Store presence

1. `play-store-listing.md` içindeki adı ve açıklamaları kullan veya düzenle.
2. 512x512 PNG ikonu ve 1024x500 özellik görselini yükle.
3. Gerçek uygulama deneyimini gösteren en az iki ekran görüntüsü yükle.
4. Destek e-postası ile gizlilik politikası URL'sini doğrula.

## Test ve yayın

1. Gerçek Android cihazda boyama, sürükle-bırak yapboz, sesli okuma, küçük ekran,
   geri gezinme ve ekran yönü testlerini yap.
2. Yeni kişisel Play geliştirici hesabıysa en az 12 testçiyle 14 gün kesintisiz kapalı test yürüt.
3. Kendi upload keystore'un hazır olduğunda `android/key.properties` oluştur.
4. `flutter build appbundle --release` ile imzalı AAB üret, imzasını doğrula ve
   Play App Signing'i ilk yüklemede etkinleştir.

## Yayın öncesi yeniden kontrol

- Reklam, analiz, giriş, bulut kayıt veya yeni izin eklenirse Data safety, gizlilik
  politikası ve hedef kitle cevaplarını yeniden değerlendir.
- `flutter_tts` şu anda derleniyor; ancak Flutter'ın Built-in Kotlin geçişi için
  eklenti üreticisinin henüz yayımlamadığı bir uyumluluk düzeltmesi bekleniyor.
