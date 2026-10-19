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

Das Flutter-Projekt liegt unter `app/`. Phase 1 enthält einen technischen
Mal-Spike mit drei Testflächen, deterministischer Flächenerkennung,
randbegrenzten Strichen und Kontur-Rendering. Der erste Produktfluss folgt in
Phase 2.

## Lokale Verifikation

Der vollständige Pflicht-Gate vor jedem Commit und erneut vor jedem Push ist:

```bash
./scripts/verify.sh
```
