# Performance-Verifikation

## Phase-1-Szenario

Der Test erzeugt 180 kontinuierliche Pointer-Updates quer durch das Testmotiv.
Dabei werden Controllerzustand, Widget-Rebuild, Pfad-Clipping, Stroke-Rendering
und die abschließende Konturebene ausgeführt.

Der reproduzierbare Befehl lautet:

```bash
./scripts/verify-coloring-performance.sh <device-id> --profile
```

Da iOS-Simulatoren keine Profile-Builds unterstützen, wird dort ausgeführt:

```bash
./scripts/verify-coloring-performance.sh <simulator-id> --debug
```

## Budgets

- automatischer Phase-1-Gate: Total-p90 höchstens 32 ms
- Produktziel auf Referenzgeräten im Profile-Build: Total-p90 höchstens 16,7 ms
- mindestens 120 auswertbare Frames pro Lauf

Der 32-ms-Gate verhindert grobe Regressionen auch in instrumentierten Debug-
Läufen. Das strengere 60-fps-Ziel wird anhand physischer Referenzgeräte
bewertet.

## Messungen

### iPhone-17-Simulator, iOS 26.3, Debug

Gemessen am 2026-10-20:

| Metrik | Ergebnis |
|---|---:|
| Frames | 361 |
| Total p50 | 20,308 ms |
| Total p90 | 22,647 ms |
| Total p99 | 23,852 ms |
| Build p90 | 3,773 ms |
| Raster p90 | 1,000 ms |

Ergebnis: Phase-1-Gate bestanden. Der Simulator-Debug-Wert ist nicht mit einem
physischen Profile-Build gleichzusetzen.

### Physisches Referenzgerät

Samsung SM-S928B, Android 16 / API 36, Profile-Build, gemessen am 2026-10-20:

| Metrik | Ergebnis |
|---|---:|
| Frames | 363 |
| Total p50 | 1,192 ms |
| Total p90 | 1,693 ms |
| Total p99 | 2,770 ms |
| Build p90 | 0,361 ms |
| Raster p90 | 0,890 ms |

Ergebnis: Phase-1-Gate und 60-fps-Produktziel bestanden. Eine zusätzliche
reale ADB-Wischgeste quer durch alle drei Regionen wurde visuell geprüft: Farbe
blieb in der linken Startregion, die zwei Nachbarregionen blieben weiß und die
schwarzen Konturen blieben sichtbar.
