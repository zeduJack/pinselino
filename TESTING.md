# Pinselino — Teststrategie

Die Basisauswahl ist festgelegt. Dieses Dokument definiert Testgrenzen und den
Abschlussvertrag.

## 1. Vorgesehener Test-Stack

Verbindliche Basis:

- `flutter_test` für Dart-Unit- und Flutter-Widget-Tests
- `flutter analyze` plus `flutter_lints` als statische Qualitätsprüfung
- Flutter-eigene Golden-Tests für stabile Canvas-/Maskenresultate
- stabile `ValueKey`s oder Semantics für app-eigene Bedienelemente
- Screenshots zur manuellen visuellen Prüfung, nicht als alleinige Testwahrheit

Später beim ersten echten Gerätefluss:

- Patrol für wenige wichtige Geräte-/App-Flüsse
- Emulator-Smoke-Test und ein physischer Android-Referenzpfad

Für die grafische App gelten zusätzlich deterministische
Bildvergleichstoleranzen und kleine programmatisch erzeugte Testmotive statt
ausschließlich komplexer Produktionsassets.

Nicht übernommen werden Playwright, WebRTC-/Medientests und Serverchecks, da
Version 1 keine Web- oder Serverkomponente besitzt.

## 2. Testpyramide

### Unit-Tests — verpflichtend für Business-Logik

Unit-Tests decken mindestens ab:

- Punkt-zu-Region-Erkennung
- Bindung eines Strichs an seine Startregion
- Koordinatentransformation zwischen Widget und Motiv
- Stroke-Erzeugung und Punktreduktion/-glättung, falls fachlich eingesetzt
- Undo-/Redo-Regeln
- Radiererregeln
- Session-Serialisierung und Migration
- Katalogfilter und Fortschrittsstatus

### Widget-Tests

- Werkzeug- und Farbauswahl
- Buttonzustände für Undo/Redo
- Reset-/Elterndialoge
- Navigation zwischen Auswahl, Malfläche und Galerie
- Semantics, Touchziele und relevante Ausrichtung

### Rendering-/Integrations-Tests

- Strich wird außerhalb der Startregion nicht sichtbar
- benachbarte Region bleibt unverändert
- Konturlinie bleibt über der Farbe sichtbar
- Skalierung und Rotation verändern das Ergebnis nicht fachlich
- Speichern, Neustart und Laden reproduzieren das Werk

### Patrol-/Gerätetests

Patrol wird selektiv genutzt für:

- App starten, Motiv wählen, malen, verlassen und fortsetzen
- lokale Berechtigung oder Export, falls später vorhanden
- Elternschranke und Kauf-/externe Aktionen, falls später vorhanden
- mindestens einen Android-Smoke-Flow; iOS-Gerätepfad nach Bedarf

Nicht jeder UI-Zustand benötigt einen Patrol-Test. Deterministische Logik bleibt
in schnellen Unit-/Widget-Tests.

## 3. Bugfix-Regel

Ein Bugfix ist erst abgeschlossen, wenn ein dauerhafter Regressionstest auf der
niedrigsten sinnvollen Ebene vorhanden ist. War der Fehler nur auf einem echten
Gerät reproduzierbar, bleibt die manuelle Prüfung im `PLAN.md` dokumentiert,
bis eine praktikable automatisierte Absicherung existiert.

## 4. Visuelle Prüfung

Bei UI- und Canvas-Änderungen werden stabile Zustände auf mindestens einer
Zielgröße visuell geprüft. Vor einer Release-Version kommen Portrait und
Landscape sowie kleine und große Zielgeräte hinzu.

Zu prüfen sind insbesondere:

- Konturen, weiße Säume und Farbaustritt
- abgeschnittene oder überlagerte Bedienelemente
- Touchziele, Safe Areas und Orientierung
- korrektes Vorschaubild nach Speicherung
- flüssige Strichdarstellung ohne sichtbare Sprünge

## 5. Standardbefehle

Für gezielte lokale Arbeit gelten mindestens:

```bash
cd app
flutter analyze
flutter test
```

`./scripts/verify.sh` ist der verpflichtende vollständige Gate:

- unmittelbar vor jedem Commit ausführen
- nach dem Commit unmittelbar vor jedem Push erneut ausführen
- nur bei vollständigem Erfolg committen beziehungsweise pushen
- auch bei reinen Dokumentationsänderungen ausführen

Der Gate löst Abhängigkeiten auf, prüft Formatierung, führt Analyse und alle
Unit-/Widget-/Golden-Tests aus und baut ein Android-Debug-APK. Weitere
deterministische Integrationstests werden aufgenommen, sobald sie Teil der
verbindlichen Suite sind. Gezielte Tests sind der schnelle Entwicklungsloop,
aber kein Ersatz für den vollständigen Gate.

Patrol-Gerätetests können wegen Laufzeit und Geräteabhängigkeit in einem
separaten, ebenfalls verpflichtenden Release-/Risiko-Gate liegen. Welche
Änderungen diesen Gate auslösen, wird vor Beginn der Implementierung eindeutig
festgelegt.


## 6. Testdaten und Reproduzierbarkeit

- Tests verwenden feste Koordinaten, Farben und Motiv-IDs.
- Keine Zufallswerte ohne festen Seed.
- Testmotive bleiben klein und enthalten bekannte Randfälle.
- Golden-Baselines werden nur nach bewusster visueller Prüfung aktualisiert.
- Laufzeitbilder, Reports und temporäre Screenshots werden nicht committet.
