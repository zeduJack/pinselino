# Painting App — Teststrategie

Die konkrete Paketwahl wird vor Implementierungsbeginn bestätigt. Dieses
Dokument definiert bereits die Testgrenzen und den Abschlussvertrag.

## 1. Vorgesehener Test-Stack

Aus dem VolleyVision-Projekt sinnvoll zu übernehmen:

- `flutter_test` für Dart-Unit- und Flutter-Widget-Tests
- `flutter analyze` plus `flutter_lints` als statische Qualitätsprüfung
- Patrol für wenige wichtige Geräte-/App-Flüsse, sobald diese existieren
- stabile `ValueKey`s oder Semantics für app-eigene Bedienelemente
- Emulator-Smoke-Test und später ein physischer Android-Referenzpfad
- Screenshots zur manuellen visuellen Prüfung, nicht als alleinige Testwahrheit

Zusätzlich für diese grafische App zu prüfen:

- Golden-Tests für stabile Canvas-/Maskenresultate
- deterministische Bildvergleichstoleranzen pro Plattform/Renderer
- kleine programmatisch erzeugte Testmotive statt ausschließlich komplexer
  Produktionsassets

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

## 5. Geplante Standardbefehle

Nach Erstellung des Flutter-Projekts gelten mindestens:

```bash
cd app
flutter analyze
flutter test
```

Vor einem abgeschlossenen größeren Slice soll ein gemeinsames Skript wie
`./scripts/verify.sh` Analyse, alle Unit-/Widget-Tests und einen Debug-Build
ausführen. Patrol wird risikobasiert ergänzt und nicht blind bei jeder
Dokumentationsänderung gestartet.

## 6. Testdaten und Reproduzierbarkeit

- Tests verwenden feste Koordinaten, Farben und Motiv-IDs.
- Keine Zufallswerte ohne festen Seed.
- Testmotive bleiben klein und enthalten bekannte Randfälle.
- Golden-Baselines werden nur nach bewusster visueller Prüfung aktualisiert.
- Laufzeitbilder, Reports und temporäre Screenshots werden nicht committet.
