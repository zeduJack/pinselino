# Pinselino — Plan und Fortschritt

Diese Datei ist die einzige Quelle für Roadmap und Arbeitsstatus.

## Statuslegende

- `[ ]`: geplant, noch nicht begonnen
- `[-]`: in Arbeit; Details stehen unter `Current Work`
- `[x]`: verifiziert, dokumentiert und committet
- `~~Verworfen~~ — Grund`: bewusst nicht umgesetzt

## Completion Contract

- Jeder Task besitzt vor Implementierung Akzeptanzkriterien und einen
  Verifikationsweg.
- Business-Logik ist ohne passende Unit- oder Integrationstests nicht fertig.
- Ein Bugfix ist ohne Regressionstest nicht fertig.
- Vor jedem Commit und erneut vor jedem Push muss die vollständige in
  `TESTING.md` definierte Prüfsuite erfolgreich laufen.
- `[x]` wird erst gesetzt, nachdem relevante Tests erfolgreich waren und der
  gesamte Slice committet ist.
- Ist Arbeit unterbrochen, bleibt der Task `[-]`. `Current Work` beschreibt den
  exakten Stand, betroffene Dateien, letzte Verifikation und nächsten Schritt.
- Vor Fortsetzung eines `[-]`-Tasks werden `git status`, `git diff` und alle unter
  `Current Work` genannten Dateien gelesen.

## Current Work

- Aktiver Task: keiner – Raster-Pipeline Slice 1 abgeschlossen
- Letzter Stand: Die reproduzierbare OpenCV-Pipeline erzeugt Kontur, RGB-ID-
  Maske, technische Pfade, Metadaten, Debug-Vorschau und Qualitätsbericht.
  Acht Pipeline-Unit-Tests, 25 Flutter-Tests, Analyze und Android-Debug-Build
  waren im vollständigen Gate am 2026-10-20 erfolgreich. Sechs lokale reale
  Vorlagen wurden verarbeitet, automatisiert gegengeprüft und visuell bewertet.
- Nächster Schritt: Slice 2 beginnt mit dem Malgruppenmodell und dem
  Elefant-Pilot; die Installation der neuen Malfunktion folgt nach der
  Flutter-Integration in Slice 3.

## Phase 0 — Projektgrundlagen

- [x] Architektur, Fortschrittsmodell, Teststrategie und Entscheidungslog
  dokumentieren
  - Akzeptanz: Die Dokumente erklären Architekturgrenzen, Statussemantik,
    Wiederaufnahme nicht committeter Arbeit, Testpflicht und Commit-Vertrag.
  - Verifikation: Dokumentreview und Querverweisprüfung; keine App-Tests, da
    noch kein Anwendungscode existiert.
- [x] Commit- und Push-Testpflicht sowie Slice-Definition präzisieren
  - Akzeptanz: `AGENTS.md` verlangt vor jedem Commit und vor jedem Push die
    vollständige grüne Prüfsuite; Dokumentations-Commits haben einen expliziten
    Dokument-Gate; ein Slice ist mit Beispielen definiert.
  - Verifikation am 2026-10-20: Dokumentreview, `git diff --check` und
    Querverweisprüfung erfolgreich. Kein Anwendungscode/Testprojekt vorhanden.
    Push derzeit nicht möglich, weil kein Git-Remote konfiguriert ist.
- [x] Repository als Pinselino benennen und GitHub-Remote einrichten
  - Akzeptanz: lokaler Ordner heißt `pinselino`, Dokumente verwenden den
    Produktnamen, `origin` zeigt auf das angegebene GitHub-Repository und der
    verifizierte `main`-Stand ist gepusht.
  - Verifikation: Dokument-Gate, `git remote -v`, `git status` und erfolgreicher
    Push.
  - Verifiziert am 2026-10-20: lokaler Ordner
    `/Users/zedu/workarea/workspaces/pinselino`, `origin` auf
    `https://github.com/zeduJack/pinselino.git`, Dokument-Gate erfolgreich.
- [x] Konkreten Flutter-Test-Stack gemeinsam bestätigen
  - Akzeptanz: Entscheidung zu `flutter_test`, Patrol und Golden-Strategie ist
    in `TESTING.md` und `DECISIONS.md` festgehalten.
  - Verifiziert am 2026-10-20 durch Dokumentreview: `flutter_test`,
    `flutter_lints` und Flutter-Goldens bilden die Basis; Patrol folgt mit dem
    ersten plattformabhängigen End-to-End-Flow.
- [x] Flutter-Projekt initialisieren und minimale Qualitätsprüfung einrichten
  - Akzeptanz: App startet auf mindestens einem Ziel; Analyze, Basistest und
    Debug-Build sind grün; `scripts/verify.sh` existiert.
  - Verifiziert am 2026-10-20 mit `./scripts/verify.sh`: Formatierung, Analyze,
    vollständiger Flutter-Test und Android-Debug-APK erfolgreich. Zusätzlich
    startete die Debug-App mit `flutter run` erfolgreich auf dem iPhone-17-
    Simulator (iOS 26.3).

## Phase 1 — Technischer Mal-Spike

Status: `[x]` abgeschlossen

- [x] Testmotiv mit drei geschlossenen Teilflächen definieren
  - Verifiziert am 2026-10-20 durch Domain-Tests für Anzahl, IDs, Innen-, Außen-
    und Randpunkte.
- [x] Pointer-Koordinaten korrekt in Motivkoordinaten transformieren
  - Verifiziert am 2026-10-20 durch Unit-Tests für breite und hohe Viewports,
    Roundtrip und Letterbox-Ausschluss.
- [x] Startfläche eines Strichs deterministisch erkennen
  - Verifiziert am 2026-10-20 durch Unit-Tests für stabile Asset-Reihenfolge,
    Start außerhalb einer Fläche und dauerhafte Regionsbindung.
- [x] Strich sichtbar auf die Startfläche begrenzen
  - Verifiziert am 2026-10-20 durch Widget-Interaktion und Golden-Test: Ein
    Strich durch alle drei Regionen bleibt ausschließlich links sichtbar.
- [x] Konturen sauber über der Farbe rendern
  - Verifiziert am 2026-10-20 durch visuell geprüfte Golden-Baseline und
    Simulator-Screenshot; schwarze Konturen bleiben vollständig sichtbar.
- [x] Performance auf Emulator und mindestens einem realen Referenzgerät messen
  - Verifiziert am 2026-10-20 mit dem reproduzierbaren Interaktions-Benchmark:
    iPhone-17-Simulator Debug Total-p90 22,647 ms; Samsung SM-S928B Android 16
    Profile Total-p90 1,693 ms. Reale ADB-Wischgeste und Screenshot bestätigen
    Clipping und sichtbare Konturen. Details in `docs/PERFORMANCE.md`.
- [x] SVG-Pfade gegen vorverarbeitete Masken bewerten und Entscheidung festhalten
  - Verifiziert am 2026-10-20 durch dokumentierten Variantenvergleich in
    `docs/MOTIF_PIPELINE.md`; gewählt ist SVG als Quelle mit vorverarbeiteter
    Vektorgeometrie zur Laufzeit.

Abnahme der Phase:

- Ein Kind kann auf einem Motiv frei über eine Kontur fahren, ohne dass Farbe
  in einer anderen Teilfläche oder außerhalb des Motivs erscheint.
- Fachregeln sind per Unit-/IntegrationsTests abgesichert.
- Das Ergebnis wurde visuell auf einem Zielgerät geprüft.

## Phase 2 — Erster kompletter Ausmalfluss

- Status: `[x]` abgeschlossen

- [x] Motivauswahl mit einem Testmotiv
- [x] Acht Farben und ein einfacher Stift
- [x] Strich beginnen, fortsetzen und abschließen
- [x] Undo und Redo
- [x] Randbegrenzter Radierer
- [x] Zurücksetzen mit kindgerechter Sicherung
- [x] lokalen Fortschritt automatisch speichern und wiederherstellen
- [x] kompletter Flow als Widget-/Integrationstest

Abnahme am 2026-10-20: Auswahl, Malen, Autosave, Fortsetzen und bestätigtes
Zurücksetzen sind als Widget-Flow getestet; Controller- und Speicherregeln sind
mit Unit-Tests abgedeckt.

## Phase 3 — MVP-Inhalt und Galerie

- Status: `[x]` abgeschlossen

- [x] Sechs eigene, technisch validierte Ausmalmotive
- [x] drei klar unterscheidbare Werkzeuge
- [x] kindgerechte Motivkategorien und Navigation
- [x] lokale Galerie mit Vorschaubildern
- [x] Fortschritt je Motiv fortsetzen oder neu beginnen
- [x] leere, beschädigte und alte Speicherstände robust behandeln
- [x] Motive visuell verbessern und verschachtelte Teilflächen aussparen
  - Verifiziert am 2026-10-20 durch Domain-RegressionsTest, Clipping-Golden,
    Galerie-Golden, Widget-Test der Farbstiftauswahl und vollständiges Gate.

Abnahme am 2026-10-20: Der Katalogtest validiert sechs eindeutige Motive,
Kategorien, Grenzen und Mindestflächen. Codec-Tests decken Roundtrip, leere,
beschädigte und alte Daten ab; unbekannte Regions-IDs werden beim
Wiederherstellen verworfen. Der vollständige Widget-Flow prüft Galerie,
Kategorien, Werkzeuge, Autosave und Fortsetzen.

## Raster-Malvorlagen und intelligente Malgruppen

- [x] Slice 1: Bildvorverarbeitung und technische Regionen
  - Verifiziert am 2026-10-20: acht synthetische Pipeline-Tests sowie der
    vollständige Repository-Gate waren grün; Elefant, Fisch, Dinosaurier und
    drei lokal ignorierte Unity-Referenzen wurden erfolgreich verarbeitet und
    visuell geprüft.
- [ ] Slice 2: Malgruppenmodell, automatische Vorschläge und Elefant-Pilot
- [ ] Slice 3: Raster-/Malgruppen-Laufzeit in Flutter und Querformat
- [ ] Slice 4: Datengetriebene Kategorien und Vorlagenauswahl
- [ ] Slice 5: versionierte Speicherung, weitere Motive und Optimierung

## Phase 4 — Kinder-, Geräte- und Store-Reife

- [ ] Bedienung mit Kindern der Zielgruppe beobachten und Probleme protokollieren
- [ ] Touchziele, Orientierung, Safe Areas und Barrierefreiheit prüfen
- [ ] Android-Patrol-Smoke-Flow stabilisieren
- [ ] iOS- und Android-Referenzgeräte testen
- [ ] Elternbereich für externe oder destruktive Aktionen
- [ ] Datenschutz-, Store- und Kinderkategorie-Anforderungen prüfen
- [ ] Release-Verifikationsskript und Checkliste abschließen
- [x] Android-Testbuild ohne Play Store als GitHub-Release bereitstellen
  - Verifiziert am 2026-10-20: Release-APK auf SM-S928B installiert und als
    Vordergrund-App gestartet; Workflow-YAML geprüft; vollständiges Gate grün.
- [x] Release-Test plattformstabil machen und korrigierte APK veröffentlichen
  - Lokal verifiziert am 2026-10-20: 25 Tests, Analyze und Android-Build grün;
    App auf SM-S928B als Vordergrund-App gestartet und visuell geprüft. GitHub-
    Workflow `39378079764` und Release `v0.1.2` erfolgreich; APK-Asset
    `Pinselino-v0.1.2.apk` mit 45.267.132 Bytes veröffentlicht.

## Später / nicht Teil von Version 1

- [ ] Tap-to-fill als optionalen zweiten Malmodus evaluieren
- [ ] weitere Stifte, Texturen, Sounds und Abschlussanimationen evaluieren
- [ ] In-App-Käufe oder Motivpakete evaluieren
- [ ] Cloud-Sicherung nur bei begründetem Produktbedarf evaluieren
- [ ] Web-/PWA-Ausgabe nur bei begründetem Produktbedarf evaluieren
