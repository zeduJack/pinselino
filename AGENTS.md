# Painting App — Agent Workflow

Diese Datei ist für Codex und andere Coding Agents verbindlich.

## Autoritative Dokumente

- `PLAN.md` ist die einzige Quelle für Roadmap, Arbeitsstatus und Abnahme.
- `ARCHITECTURE.md` definiert Struktur und erlaubte Abhängigkeiten.
- `TESTING.md` definiert Testarten, Testgrenzen und Verifikationsbefehle.
- `DECISIONS.md` dokumentiert aktive, verschobene und verworfene Entscheidungen.
- Bei Widersprüchen haben `AGENTS.md` und danach die speziellere Fachdatei Vorrang.

## Arbeitsbeginn und Wiederaufnahme

Vor jeder Implementierungsarbeit:

1. `AGENTS.md`, den Abschnitt `Current Work` in `PLAN.md` und die betroffene
   Architektur-/Testdokumentation lesen.
2. `git status --short --branch` und `git diff --stat` ausführen.
3. Bei `[-]` zuerst die unter `Current Work` genannten Dateien, `git diff` und
   die dort notierte letzte Verifikation lesen. Unfertige Arbeit nicht neu
   beginnen oder ungeprüft überschreiben.
4. Vor Codeänderungen genau einen Planpunkt auf `[-]` setzen und unter
   `Current Work` Ziel, Akzeptanzkriterien, betroffene Dateien und nächsten
   Schritt eintragen.

Damit ist ein nicht committeter Stand jederzeit einem konkreten Task
zuordenbar.

## Statuskonvention

- `[ ]`: geplant, noch nicht begonnen
- `[-]`: in Arbeit; es können nicht committete Änderungen existieren
- `[x]`: abgeschlossen, verifiziert und als eigener sinnvoller Stand committet
- `~~Verworfen~~ — Grund`: bewusst nicht umgesetzt

Es darf grundsätzlich nur einen `[-]`-Punkt gleichzeitig geben. Eine begründete
Ausnahme muss in `Current Work` dokumentiert sein.

## Vertikale Slices

- In kleinen, testbaren, nutzbaren Slices arbeiten.
- Ein Slice umfasst bei Bedarf Modell, Logik, Rendering, UI und Tests.
- Keine breite Schicht komplett auf Vorrat implementieren.
- Keine Abstraktion ohne gegenwärtige fachliche oder technische Grenze.
- Bestehende, nicht zum Task gehörende Änderungen nicht anfassen.

## Testpflicht

- Jede Business-Logik benötigt automatisierte Unit- oder Integrationstests.
- Fachregeln werden bevorzugt als schnelle Dart-Unit-Tests abgedeckt.
- Widget-Verhalten erhält Flutter-Widget-Tests.
- Canvas-, Maskierungs- und Koordinatenintegration erhält Integrations- oder
  geeignete visuelle Regressionstests zusätzlich zu den Unit-Tests.
- Plattformabhängige Kernflüsse erhalten gezielte Patrol-Tests auf Emulator
  und bei relevantem Risiko auf einem Referenzgerät.
- Jeder Bugfix benötigt den kleinsten sinnvollen Regressionstest, der vor dem
  Fix fehlgeschlagen wäre.
- Ein Test darf nicht nur deshalb angepasst werden, weil die Implementierung
  ihn bricht; zuerst ist zu klären, welches Verhalten fachlich richtig ist.

## Abschluss- und Commit-Vertrag

Ein Planpunkt darf erst auf `[x]` gesetzt werden, wenn:

1. alle Akzeptanzkriterien erfüllt sind,
2. relevante Analyse- und Testbefehle erfolgreich waren,
3. erforderliche visuelle oder Geräteprüfungen erfolgt sind,
4. `PLAN.md`, `DECISIONS.md` und technische Dokumente dem echten Stand
   entsprechen,
5. Implementierung, Tests und Dokumentation gemeinsam committet wurden.

Vorgehen beim Abschluss:

1. Tests ausführen und Ergebnis in `PLAN.md` notieren.
2. Task auf `[x]` setzen und `Current Work` leeren.
3. Den gesamten zusammengehörigen Slice in einem beschreibenden Commit sichern.
4. `git status --short` muss danach leer sein. Falls bewusst nicht zugehörige
   Änderungen verbleiben, werden sie mit Besitzer und Grund dokumentiert.

Ein fehlgeschlagener oder nicht ausführbarer Test hält den Task auf `[-]`; der
Grund und der nächste Schritt werden dokumentiert. Nicht automatisch pushen,
solange kein Remote und keine Push-Regel vereinbart wurden.

## Artefakthygiene

- Temporäre Screenshots, Testreports, Build-Ausgaben und lokale Laufzeitdaten
  nicht committen.
- Bewusst erstellte Test-Fixtures und Golden-Baselines dürfen committet werden.
- Keine Assets, Figuren, Sounds oder Texte aus fremden Apps übernehmen.
