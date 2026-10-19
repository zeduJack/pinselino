# Pinselino

Eine offline-fähige Flutter-Ausmal-App für Kinder von etwa 3½ bis 4½ Jahren.

Die erste Produktversion konzentriert sich auf vordefinierte Ausmalbilder. Das
Kind wählt Werkzeug und Farbe und malt mit dem Finger. Ein Strich bleibt in der
Teilfläche, in der er begonnen wurde, und kann schwarze Konturlinien nicht
überschreiten.

## Projektdokumente

- `AGENTS.md`: verbindliche Arbeits-, Test- und Commit-Regeln
- `PLAN.md`: einzige Quelle für Roadmap und aktuellen Fortschritt
- `ARCHITECTURE.md`: Architektur, Abhängigkeitsregeln und Datenfluss
- `TESTING.md`: Teststrategie und spätere Verifikationsbefehle
- `DECISIONS.md`: aktive, verschobene und verworfene Entscheidungen

## Aktueller Zustand

Das Flutter-Projekt liegt unter `app/`. Die Phasen 1 bis 3 sind abgeschlossen:
Die App enthält sechs kategorisierte Motive, acht Farben, drei Malwerkzeuge,
einen regionsbegrenzten Radierer, Undo/Redo sowie eine lokale Galerie mit
automatischem, versioniertem Fortschritt.

## Lokale Verifikation

Der vollständige Pflicht-Gate vor jedem Commit und erneut vor jedem Push ist:

```bash
./scripts/verify.sh
```
