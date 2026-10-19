# Motivpipeline

## Ziel

Illustratorinnen und Illustratoren sollen Motive als editierbare Vektorgrafiken
erstellen können. Die App benötigt daraus stabile Regions-IDs, geschlossene
Geometrie für Hit-Tests und Clipping sowie eine getrennte Konturebene.

## Bewertete Varianten

| Variante | Vorteile | Nachteile | Ergebnis |
|---|---|---|---|
| SVG zur Laufzeit parsen und rendern | Originaldatei kann direkt gebündelt werden; Kurven bleiben erhalten | Parser-/Renderer-Abhängigkeit im Kernpfad; Regionen und IDs werden erst auf dem Gerät validiert; Hit-Tests hängen von der Bibliothek ab | Nicht für den Laufzeit-Kernpfad |
| Vorverarbeitete Rastermasken pro Region | Einfacher Pixel-Lookup; beliebige Quellgrafik | Speicherbedarf pro Region und Auflösung; Skalierungs- und Kantenartefakte | Nur als späterer Fallback für Spezialeffekte |
| SVG als Quelle, vorverarbeitete Vektorgeometrie zur Laufzeit | Frühe Validierung; stabile IDs; auflösungsunabhängig; deterministische Flutter-Pfade; kein SVG-Parser im Malpfad | Build-Werkzeug muss entwickelt werden; Quelle und generiertes Asset müssen gemeinsam versioniert werden | Gewählt |

## Gewählter Ablauf

```text
Illustrations-SVG
      │
      ▼
Validierung und Konvertierung beim Asset-Build
      │
      ├─ stabile Motiv- und Regions-IDs
      ├─ geschlossene normalisierte Vektorpfade
      ├─ getrennte Konturpfade
      └─ Metadaten und ViewBox
      │
      ▼
Versioniertes Laufzeit-Asset
      │
      ▼
Flutter Path: Hit-Test, Clip und Kontur-Rendering
```

Das Phase-1-Testmotiv verwendet bewusst bereits vorverarbeitete Polygonpunkte.
Damit prüft der Spike den Laufzeitpfad, ohne die spätere SVG-Konvertierung
vorwegzunehmen. Produktionsmotive dürfen zusätzlich Bézier-Pfadkommandos
enthalten; das Domainformat wird vor dem ersten Produktionsmotiv entsprechend
erweitert.

## Validierungsanforderungen

Der spätere Konverter muss mindestens fehlschlagen bei:

- fehlender oder doppelter Motiv-/Regions-ID
- offener ausmalbarer Region
- Geometrie außerhalb der deklarierten ViewBox
- leerer oder degenerierter Fläche
- fehlender Konturebene
- nicht unterstützten Transformationen oder SVG-Features

Kleine oder schwer berührbare Flächen sollen als Warnung mit ihrer
Motivkoordinaten-Größe gemeldet werden.
