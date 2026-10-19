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
- Ein Slice ist die kleinste in sich abgeschlossene Produktänderung, die aus
  Benutzersicht oder technisch einen nachweisbaren Nutzen liefert. Er umfasst
  alle dafür erforderlichen Teile – bei Bedarf Modell, Logik, Rendering, UI,
  Tests und Dokumentation – und hinterlässt keine wissentlich halbfertige
  Funktion auf dem Hauptzweig.
- Beispiel für einen guten Slice: „Ein Testmotiv laden, beim Aufsetzen die
  Teilfläche erkennen und einen Strich nachweislich auf diese Fläche begrenzen“,
  inklusive automatisierter Tests.
- Kein abgeschlossener Slice wäre: nur alle Datenklassen anzulegen, ohne einen
  nutzbaren Ablauf und ohne Tests zu integrieren.
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

1. Unmittelbar vor jedem Commit die vollständige in `TESTING.md` definierte
   Prüfsuite ausführen. Gezielte Tests während der Entwicklung sind zusätzlich
   sinnvoll, ersetzen diesen vollständigen Gate aber nicht.
2. Nur wenn der vollständige Gate erfolgreich ist, Ergebnis und Zeitpunkt in
   `PLAN.md` notieren.
3. Task auf `[x]` setzen und `Current Work` leeren.
4. Den gesamten zusammengehörigen Slice in einem beschreibenden Commit sichern.
5. `git status --short` muss danach leer sein. Falls bewusst nicht zugehörige
   Änderungen verbleiben, werden sie mit Besitzer und Grund dokumentiert.
6. Unmittelbar vor jedem Push die vollständige Prüfsuite auf dem committeten
   Stand erneut ausführen. Nur ein grüner Stand darf gepusht werden.
7. Den verifizierten Commit pushen. Ist kein Remote konfiguriert oder ein Push
   nicht möglich, wird dies in `PLAN.md` festgehalten; niemals stillschweigend
   behaupten, der Stand sei remote gesichert.

Ein fehlgeschlagener oder nicht ausführbarer Test hält den Task auf `[-]`; der
Grund und der nächste Schritt werden dokumentiert. Kein Commit und kein Push
mit fehlgeschlagenem oder unvollständigem Pflicht-Gate.

Solange noch kein Anwendungscode und kein `scripts/verify.sh` existieren, gilt
für reine Dokumentations-Commits der in `TESTING.md` beschriebene vorläufige
Dokument-Gate. Sobald `scripts/verify.sh` existiert, gilt er vor ausnahmslos
jedem Commit und jedem Push, auch bei reinen Dokumentationsänderungen.

## Artefakthygiene

- Temporäre Screenshots, Testreports, Build-Ausgaben und lokale Laufzeitdaten
  nicht committen.
- Bewusst erstellte Test-Fixtures und Golden-Baselines dürfen committet werden.
- Keine Assets, Figuren, Sounds oder Texte aus fremden Apps übernehmen.
