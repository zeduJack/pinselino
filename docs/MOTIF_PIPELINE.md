# Motivpipeline

## Ziel und Grenze

Die Pipeline bereitet detaillierte Schwarz-Weiß-Zeichnungen offline für das
randbegrenzte freie Ausmalen vor. Sie erkennt technische Flächen, füllt sie aber
nicht automatisch und arbeitet niemals während einer Fingerbewegung.

Slice 1 erzeugt technische Regionen. Die kindgerechte Zuordnung mehrerer
technischer Regionen zu logischen Malgruppen folgt in Slice 2 und benötigt eine
visuelle, menschliche Freigabe.

## Installation und Verifikation

```bash
./scripts/verify-coloring-pipeline.sh
```

Das Skript erstellt bei Bedarf die ignorierte Umgebung
`tools/coloring_pipeline/.venv` und installiert die Versionen aus
`tools/coloring_pipeline/requirements.txt`.

## Eine Vorlage verarbeiten

```bash
tools/coloring_pipeline/.venv/bin/python \
  tools/coloring_pipeline/prepare_coloring_page.py \
  input.png \
  local_data/coloring_pipeline/example \
  --id example-001 \
  --title "Beispiel" \
  --category animals
```

Optionale Parameter:

- `--line-threshold`: maximale Helligkeit eines Konturpixels, Standard 210
- `--close-gap-pixels`: Radius für vorsichtiges morphologisches Schließen,
  Standard 1
- `--minimum-region-pixels`: Warnschwelle für kleine Regionen, Standard 400
- `--minimum-touch-dimension`: Warnschwelle für schmale Regionen, Standard 24

Die Quelle wird nur gelesen und nie verändert.

## Ausgabeformat

```text
<template>/
├── outline.png
├── regions.png
├── metadata.json
├── technical_region_paths.json
├── debug_regions.png
└── quality_report.json
```

### `outline.png`

Transparente schwarze Konturebene mit identischen Abmessungen zur Quelle. Sie
wird beim Malen immer oberhalb der Farbe gerendert.

### `regions.png`

Verlustfreie RGB-PNG ohne Farbrauminterpretation der IDs. ID 0 bedeutet
nicht ausmalbar, Hintergrund oder Kontur. Positive IDs sind technische
geschlossene Regionen.

Kodierung:

```text
id = R + (G << 8) + (B << 16)
```

Die Pixelwerte dürfen niemals skaliert, als JPEG gespeichert oder mit
Interpolation geladen werden.

### `technical_region_paths.json`

Exakte, vorberechnete Konturen der technischen Regionen in Bildpixeln. Pfade
besitzen `isHole`; die vorgesehene Füllregel ist `evenOdd`. Dieses Artefakt dient
Slice 2 als Ausgangspunkt und muss nicht unverändert in die App ausgeliefert
werden.

### `metadata.json`

Enthält Schema-/Asset-Version, Motivdaten, Abmessungen, Quell-Hash und
Statistiken aller technischen Regionen. Der SHA-256-Hash macht sichtbar, wenn
eine Quelle nach der Verarbeitung ausgetauscht wurde.

### Debug und Qualität

`debug_regions.png` zeigt jede technische Region in einer deterministischen
Farbe und die Konturen in Schwarz. `quality_report.json` meldet:

- kleine Regionen
- schmale und schwer treffbare Regionen
- mögliche offene Linienenden
- Vorlagen ohne geschlossene Flächen

Linienenden sind Hinweise, keine automatisch bewiesenen Fehler: Wimpern,
Augenbrauen oder Graslinien sind absichtlich offen. Deshalb bleibt eine
visuelle Freigabe verpflichtend.

## Algorithmus

1. PNG oder JPG laden und Transparenz auf Weiß zusammensetzen.
2. Graustufen erzeugen und dunkle Konturpixel binarisieren.
3. Konfiguriert kleine Lücken morphologisch schließen.
4. Zusammenhangskomponenten des freien Raums bestimmen.
5. Alle mit dem Bildrand verbundenen Komponenten als Hintergrund/ID 0
   behandeln.
6. Geschlossene Komponenten in stabiler Rasterreihenfolge nummerieren.
7. RGB-ID-Maske und exakte Konturpfade inklusive Löchern erzeugen.
8. Debug-Vorschau, Metadaten und Qualitätsbericht schreiben.

## Grenzen und manuelle Kontrolle

- Die Pipeline versteht nicht, dass eine Form ein Auge, Ohr oder Fuß ist.
- Eine geschlossene Pupille ist technisch genauso eine Region wie ein Körper.
- Eine offene Kontur verbindet die vermeintliche Innenfläche mit dem
  Hintergrund.
- Automatisches Schließen darf nur kleine Bildfehler korrigieren; ein großer
  Radius kann fachlich getrennte Flächen verfälschen.
- Kleine Regionen werden nicht automatisch mit beliebigen Nachbarn vereinigt.

Slice 2 ergänzt daher ein explizites, geprüftes Modell für eigenständige,
zusammengefasste und geschützte Regionen.

## Malgruppenprofile

Ein Profil weist jede technische Region genau einmal entweder einer Malgruppe
oder `protectedRegions` zu. Unbekannte, doppelte und fehlende Zuordnungen
brechen die Generierung ab.

```json
{
  "schemaVersion": 1,
  "profileId": "easy",
  "paintGroups": [
    {"id": "head", "title": "Kopf", "regions": [1, 8]}
  ],
  "protectedRegions": [4, 5, 6, 7]
}
```

Die Runtime-Datei wird mit folgendem Befehl erzeugt:

```bash
tools/coloring_pipeline/.venv/bin/python \
  tools/coloring_pipeline/prepare_paint_groups.py \
  <verarbeitetes-motiv> \
  <profil.json> \
  <ausgabe>/paint_groups_easy.json
```

Die Ausgabe enthält die vorbereiteten Pfade jeder Malgruppe sowie eine
Lookup-Tabelle von technischer Region zu Malgruppen-ID. Dadurch sind zur
Laufzeit keine Pfadvereinigungen erforderlich. Geschützte Augen, Reflexe und
Dekorationen bleiben Löcher, obwohl sie innerhalb eines größeren Körperteils
liegen.

## Lokale Fremdreferenzen

Fremde Bilder dürfen zur lokalen technischen Beurteilung verarbeitet werden,
aber weder committed noch ausgeliefert werden. Tests verwenden ausschließlich
programmatisch erzeugte Fixtures. Eigene oder passend lizenzierte
Produktionsbilder ersetzen alle Referenzen vor einer Veröffentlichung.

## Flutter-Laufzeit (Slice 3)

Ein produktives Rastermotiv liegt unter `app/assets/coloring/<motiv>/` und
enthält genau die Laufzeitartefakte `outline.png`, `regions.png`,
`metadata.json` und `paint_groups_easy.json`. `RasterMotifLoader` dekodiert die
ID-Maske einmal beim Öffnen und erzeugt daraus einen kompakten Pixel-Lookup.
`PointerDown` bestimmt damit in konstanter Zeit die Malgruppe. Diese Gruppen-ID
bleibt bis `PointerUp` unverändert; die zwischen Touchpunkten gezeichnete Linie
wird vollständig mit dem vorberechneten Even-Odd-Gruppenpfad beschnitten.

Die Kontur wird zuletzt als Rasterbild gezeichnet. Dadurch bleiben auch
geschützte Details sichtbar. Radierer, Undo/Redo und lokales Speichern verwenden
dieselben gruppengebundenen `PaintStroke`-Objekte wie die handmodellierten
Motive. Die Bildschirm-/Bildkoordinaten werden über `CanvasTransform` mit
`BoxFit.contain` abgebildet, sodass Letterboxing und verschiedene Displays die
Regionsauswahl nicht verschieben.

Der Elefant ist das erste eingecheckte Produktionsbeispiel. Lokal dürfen die
ignorierten Verzeichnisse unter `app/assets/local_reference/` mit
Referenzmotiven befüllt werden. Sie erscheinen ausschließlich in einem lokalen
Build mit:

```bash
flutter run --dart-define=PINSELINO_LOCAL_REFERENCES=true
```

Die Referenzdateien selbst bleiben durch `.gitignore` aus Commit, Push und
späteren Veröffentlichungen ausgeschlossen.
