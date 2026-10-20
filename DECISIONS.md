# Pinselino — Entscheidungen

## Verwendung

- Wichtige Produkt-, Architektur- und Toolentscheidungen werden hier kurz
  festgehalten.
- Status: `Active`, `Deferred` oder `Rejected`.
- Widersprüchliche aktive Entscheidungen sind nicht erlaubt.
- Roadmap und Arbeitsstatus gehören in `PLAN.md`, nicht hierher.

## Aktive Entscheidungen

### Produktname

- Status: `Active`
- Entscheidung: Produkt, Flutter-Projekt und Repository verwenden den Namen
  `Pinselino`; der technische Bezeichner lautet `pinselino`.
- Grund: Der Name ist kurz, kindgerecht und beschreibt durch den Wortstamm
  „Pinsel“ die kreative Ausrichtung.

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
- Umsetzung: Ein `ProgressStore`-Port trennt die Anwendung vom
  `SharedPreferences`-Adapter. Gespeichert werden versionierte JSON-Striche pro
  Motiv; beschädigte oder unbekannte Versionen fallen sicher auf einen leeren
  Stand zurück.

### Fortschritt und Commit-Disziplin

- Status: `Active`
- Entscheidung: `PLAN.md` ist die einzige Statusquelle; `[-]` kennzeichnet den
  einem Task zugeordneten nicht committeten Stand. `[x]` erfordert erfolgreiche
  Verifikation und einen abgeschlossenen Commit.
- Grund: Menschen und Coding Agents können eine unterbrochene Sitzung anhand
  von Plan und Git-Diff sicher fortsetzen.

### Vollständiger Test-Gate vor Commit und Push

- Status: `Active`
- Entscheidung: Die vollständige vereinbarte Prüfsuite läuft unmittelbar vor
  jedem Commit und erneut auf dem committeten Stand vor jedem Push. Das gilt
  nach Einrichtung des Verifikationsskripts auch für Dokumentationsänderungen.
- Grund: Weder lokale Historie noch Remote sollen einen wissentlich
  unvollständig getesteten Stand enthalten.

### Testpflicht für Business-Logik

- Status: `Active`
- Entscheidung: Jede Business-Regel erhält automatisierte Tests auf der
  niedrigsten sinnvollen Ebene; jeder Bugfix erhält einen Regressionstest.
- Grund: Randbegrenzung, Koordinaten und Undo/Redo sind zentral und anfällig für
  schwer sichtbare Regressionen.

### Flutter-Testbasis

- Status: `Active`
- Entscheidung: `flutter_test`, `flutter_lints` und Flutter-eigene Golden-Tests
  bilden die Testbasis. Patrol wird erst mit dem ersten plattformabhängigen
  End-to-End-Flow als gezieltes Gerätetestwerkzeug hinzugefügt.
- Grund: Die erste technische Schwierigkeit liegt in deterministischer
  Geometrie- und Renderinglogik; dafür sind schnelle Unit-, Widget- und
  Golden-Tests geeigneter als Geräte-E2E-Tests.

### Motiv- und Maskenpipeline

- Status: `Active`
- Entscheidung: Bestehende handmodellierte Vektormotive bleiben unterstützt.
  Neue detaillierte PNG-/JPG-Malvorlagen werden offline in eine transparente
  Kontur, eine verlustfreie technische Regions-ID-Maske und vorberechnete
  Regions-/Malgruppenpfade konvertiert. Technische Regionen und kindgerechte
  Malgruppen sind getrennte Konzepte.
- Grund: Die untersuchten KI-Bilder enthalten 30 bis über 60 geschlossene
  Flächen. Eine ID-Maske ermöglicht einen konstant schnellen Hit-Test, während
  vorberechnete Pfade präzises Canvas-Clipping ohne Bilderkennung zur Laufzeit
  erlauben. Die Trennung ermöglicht manuell geprüfte Vereinfachungen und spätere
  Schwierigkeitsprofile.
- Abgelöst: Die frühere ausschließliche SVG-Quellstrategie bleibt für die
  vorhandenen Motive gültig, ist aber nicht mehr das Produktionsformat für
  detaillierte Rastervorlagen.

## Noch zu entscheiden

### State Management ohne Zusatzpaket

- Status: `Active`
- Entscheidung: Für das MVP genügen ein testbarer `ColoringController` und
  lokaler Widget-Zustand. Ein State-Management-Paket wird erst bei nachgewiesenem
  Bedarf ergänzt.
- Grund: Der Zustand ist pro geöffnetem Motiv klar begrenzt; zusätzliche
  Abstraktionen würden derzeit keinen entsprechenden Nutzen liefern.

### Ergänzendes Bildvergleichswerkzeug

- Status: `Deferred`
- Entscheidung: Zunächst Flutter-Golden-Tests verwenden und erst bei realen
  plattformübergreifenden Abweichungen ein weiteres Werkzeug evaluieren.
