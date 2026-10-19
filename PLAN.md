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

Kein Task aktiv. Es sollten keine nicht committierten Dateien vorhanden sein.

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
- [ ] Performance auf Emulator und mindestens einem realen Referenzgerät messen
- [ ] SVG-Pfade gegen vorverarbeitete Masken bewerten und Entscheidung festhalten

Abnahme der Phase:

- Ein Kind kann auf einem Motiv frei über eine Kontur fahren, ohne dass Farbe
  in einer anderen Teilfläche oder außerhalb des Motivs erscheint.
- Fachregeln sind per Unit-/IntegrationsTests abgesichert.
- Das Ergebnis wurde visuell auf einem Zielgerät geprüft.

## Phase 2 — Erster kompletter Ausmalfluss

- [ ] Motivauswahl mit einem Testmotiv
- [ ] Acht Farben und ein einfacher Stift
- [ ] Strich beginnen, fortsetzen und abschließen
- [ ] Undo und Redo
- [ ] Randbegrenzter Radierer
- [ ] Zurücksetzen mit kindgerechter Sicherung
- [ ] lokalen Fortschritt automatisch speichern und wiederherstellen
- [ ] kompletter Flow als Widget-/Integrationstest

## Phase 3 — MVP-Inhalt und Galerie

- [ ] Sechs eigene, technisch validierte Ausmalmotive
- [ ] drei klar unterscheidbare Werkzeuge
- [ ] kindgerechte Motivkategorien und Navigation
- [ ] lokale Galerie mit Vorschaubildern
- [ ] Fortschritt je Motiv fortsetzen oder neu beginnen
- [ ] leere, beschädigte und alte Speicherstände robust behandeln

## Phase 4 — Kinder-, Geräte- und Store-Reife

- [ ] Bedienung mit Kindern der Zielgruppe beobachten und Probleme protokollieren
- [ ] Touchziele, Orientierung, Safe Areas und Barrierefreiheit prüfen
- [ ] Android-Patrol-Smoke-Flow stabilisieren
- [ ] iOS- und Android-Referenzgeräte testen
- [ ] Elternbereich für externe oder destruktive Aktionen
- [ ] Datenschutz-, Store- und Kinderkategorie-Anforderungen prüfen
- [ ] Release-Verifikationsskript und Checkliste abschließen

## Später / nicht Teil von Version 1

- [ ] Tap-to-fill als optionalen zweiten Malmodus evaluieren
- [ ] weitere Stifte, Texturen, Sounds und Abschlussanimationen evaluieren
- [ ] In-App-Käufe oder Motivpakete evaluieren
- [ ] Cloud-Sicherung nur bei begründetem Produktbedarf evaluieren
- [ ] Web-/PWA-Ausgabe nur bei begründetem Produktbedarf evaluieren
