# Pinselino auf Android installieren – ohne Play Store

Die APK wird direkt von der öffentlichen GitHub-Release-Seite installiert.
Entwickleroptionen und USB-Debugging sind dafür **nicht** nötig.

## Installation auf dem Smartphone

1. Auf dem Android-Smartphone die
   [Pinselino-Releases](https://github.com/zeduJack/pinselino/releases/latest)
   öffnen.
2. Unter **Assets** die Datei `Pinselino-v…apk` antippen und herunterladen.
3. Die heruntergeladene Datei über die Browsermeldung oder die App **Eigene
   Dateien/Downloads** öffnen.
4. Beim ersten Mal meldet Android, dass der Browser oder Dateimanager keine
   unbekannten Apps installieren darf. **Einstellungen** öffnen und
   **Aus dieser Quelle zulassen** aktivieren.
5. Zurückgehen, **Installieren** wählen und danach **Öffnen** antippen.
6. Optional die Berechtigung **Aus dieser Quelle zulassen** danach wieder
   ausschalten.

Je nach Hersteller heißen die Menüpunkte leicht anders. Auf Samsung findet man
die Einstellung auch unter **Einstellungen → Sicherheit und Datenschutz →
Weitere Sicherheitseinstellungen → Unbekannte Apps installieren**.

## Sicherheitsmeldung

Android beziehungsweise Google Play Protect kann bei einer außerhalb des Play
Stores verteilten Test-App warnen. Nur installieren, wenn die Adresse mit
`github.com/zeduJack/pinselino` beginnt. Niemals eine APK aus einer
weitergeleiteten, unbekannten Quelle verwenden.

## Neue Testversion

Eine neue APK wird auf derselben Release-Seite angeboten. Die Datei erneut
herunterladen und installieren. Der lokale Malfortschritt bleibt bei einem
normalen Update erhalten.

Der aktuelle Testbuild verwendet noch keine endgültige Produktionssignatur.
Falls Android bei einer späteren Testversion einen Signaturkonflikt meldet, muss
die bestehende Pinselino-App einmal deinstalliert werden. Dabei wird ihr lokal
gespeicherter Malfortschritt gelöscht. Vor einer breiten oder dauerhaften
Verteilung wird deshalb eine gesicherte Produktionssignatur eingerichtet.

## Installation per USB für Entwickler

Nur für diesen Weg werden Entwickleroptionen und USB-Debugging benötigt:

```bash
cd app
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Auf dem Smartphone aktiviert man USB-Debugging über **Einstellungen → Über das
Telefon → Softwareinformationen**, tippt siebenmal auf **Buildnummer** und
schaltet anschließend unter **Entwickleroptionen** das **USB-Debugging** ein.
