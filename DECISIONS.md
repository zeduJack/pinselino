# Painting App — Entscheidungen

## Verwendung

- Wichtige Produkt-, Architektur- und Toolentscheidungen werden hier kurz
  festgehalten.
- Status: `Active`, `Deferred` oder `Rejected`.
- Widersprüchliche aktive Entscheidungen sind nicht erlaubt.
- Roadmap und Arbeitsstatus gehören in `PLAN.md`, nicht hierher.

## Aktive Entscheidungen

### Produktfokus Version 1

- Status: `Active`
- Entscheidung: Version 1 ist eine offline-fähige Ausmal-App mit vorbereiteten
  Motiven, Werkzeug- und Farbauswahl sowie randbegrenztem Malen.
- Grund: Dies ist der klar definierte Kernnutzen und wesentlich kleiner als die
  gesamte Referenz-App.

### Flutter statt PWA

- Status: `Active`
- Entscheidung: Die primäre App wird mit Flutter für iOS und Android geplant.
- Grund: Store-Verteilung, Touch-/Canvas-Verhalten, lokaler Speicher und
  gerätenahe Tests sind für dieses Produkt wichtiger als die geringfügig
  schnellere Bereitstellung eines Web-Prototyps.

### Pragmatische Feature-first-Architektur

- Status: `Active`
- Entscheidung: Feature-first mit Presentation, Application, Domain und
  Infrastructure/Rendering innerhalb komplexer Features; Ports nur an echten
  technischen Grenzen.
- Grund: Gute Testbarkeit und klare Agent-Grenzen ohne den Boilerplate einer
  vollständigen hexagonalen Architektur.

### Lokale Datenhaltung

- Status: `Active`
- Entscheidung: Motive und Fortschritt funktionieren in Version 1 lokal und
  ohne Benutzerkonto oder Backend.
- Grund: Zuverlässigkeit, Kinderschutz und geringere technische Komplexität.

### Fortschritt und Commit-Disziplin

- Status: `Active`
- Entscheidung: `PLAN.md` ist die einzige Statusquelle; `[-]` kennzeichnet den
  einem Task zugeordneten nicht committeten Stand. `[x]` erfordert erfolgreiche
  Verifikation und einen abgeschlossenen Commit.
- Grund: Menschen und Coding Agents können eine unterbrochene Sitzung anhand
  von Plan und Git-Diff sicher fortsetzen.

### Testpflicht für Business-Logik

- Status: `Active`
- Entscheidung: Jede Business-Regel erhält automatisierte Tests auf der
  niedrigsten sinnvollen Ebene; jeder Bugfix erhält einen Regressionstest.
- Grund: Randbegrenzung, Koordinaten und Undo/Redo sind zentral und anfällig für
  schwer sichtbare Regressionen.

## Noch zu entscheiden

### State-Management-Paket

- Status: `Deferred`
- Entscheidung: Erst nach einem kleinen vertikalen Spike auswählen.
- Kandidatenbewertung: geringe Magie, gute Testbarkeit, klare Zustandsquelle und
  wenig Boilerplate.

### Motiv- und Maskenpipeline

- Status: `Deferred`
- Entscheidung: Direkte SVG-Pfade und vorverarbeitete Masken in einem Spike
  hinsichtlich Korrektheit, Performance und Asset-Aufwand vergleichen.

### Visuelle Regressionstests

- Status: `Deferred`
- Entscheidung: Vor Implementierung festlegen, ob Flutter-Golden-Tests allein
  genügen oder ein ergänzendes Bildvergleichswerkzeug nötig ist.
