# Painting App — Plan und Fortschritt

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
- `[x]` wird erst gesetzt, nachdem relevante Tests erfolgreich waren und der
  gesamte Slice committet ist.
- Ist Arbeit unterbrochen, bleibt der Task `[-]`. `Current Work` beschreibt den
  exakten Stand, betroffene Dateien, letzte Verifikation und nächsten Schritt.
- Vor Fortsetzung eines `[-]`-Tasks werden `git status`, `git diff` und alle unter
  `Current Work` genannten Dateien gelesen.

## Current Work

Kein Implementierungstask aktiv. Es sollten keine nicht committeten
Implementierungsdateien vorhanden sein.

## Phase 0 — Projektgrundlagen

- [x] Architektur, Fortschrittsmodell, Teststrategie und Entscheidungslog
  dokumentieren
  - Akzeptanz: Die Dokumente erklären Architekturgrenzen, Statussemantik,
    Wiederaufnahme nicht committeter Arbeit, Testpflicht und Commit-Vertrag.
  - Verifikation: Dokumentreview und Querverweisprüfung; keine App-Tests, da
    noch kein Anwendungscode existiert.
- [ ] Konkreten Flutter-Test-Stack gemeinsam bestätigen
  - Akzeptanz: Entscheidung zu `flutter_test`, Patrol und Golden-Strategie ist
    in `TESTING.md` und `DECISIONS.md` festgehalten.
  - Verifikation: Dokumentreview.
- [ ] Flutter-Projekt initialisieren und minimale Qualitätsprüfung einrichten
  - Akzeptanz: App startet auf mindestens einem Ziel; Analyze, Basistest und
    Debug-Build sind grün; `scripts/verify.sh` existiert.
  - Verifikation: spätere konkrete Befehle in `TESTING.md`.

## Phase 1 — Technischer Mal-Spike

- [ ] Testmotiv mit drei geschlossenen Teilflächen definieren
- [ ] Pointer-Koordinaten korrekt in Motivkoordinaten transformieren
- [ ] Startfläche eines Strichs deterministisch erkennen
- [ ] Strich sichtbar auf die Startfläche begrenzen
- [ ] Konturen sauber über der Farbe rendern
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
