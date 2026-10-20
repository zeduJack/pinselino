# Raster-Pipeline: Slice-1-Ergebnis

## Geprüfte Vorlagen

Die Pipeline wurde lokal auf drei eigenen KI-Testvorlagen und drei ignorierten
Unity-Referenzkonturen unterschiedlicher Komplexität ausgeführt. Fremde
Referenzbilder und generierte Ausgaben sind nicht Teil des Repositorys.

| Vorlage | Technische Regionen | Kleine Regionen | Schmale Regionen |
|---|---:|---:|---:|
| Elefant | 32 | 14 | 16 |
| Fisch | 62 | 22 | 22 |
| Dinosaurier | 68 | 27 | 35 |
| Unity-Referenz einfach | 11 | 4 | 4 |
| Unity-Referenz mittel | 21 | 0 | 0 |
| Unity-Referenz komplex | 34 | 0 | 0 |

Alle sechs Vorlagen wurden in voller Quellauflösung verarbeitet. Kontur,
ID-Maske und Debug-Vorschau besitzen jeweils exakt dieselben Abmessungen.

## Visuelle Bewertung

- Die großen Hauptflächen von Elefant, Fisch und Dinosaurier werden sauber
  getrennt.
- Augen, Reflexe, Flecken, Zehen, Pflanzen und Hintergrunddetails erklären die
  hohe technische Regionsanzahl der eigenen Testbilder.
- Die professionell vorbereiteten Unity-Motive enthalten im sichtbaren Outline
  mehr geschlossene Flächen als die Anwendung tatsächlich als Malbereiche
  anbietet. Dies bestätigt die Notwendigkeit einer expliziten, redaktionell
  geprüften Malgruppenzuordnung.
- Offene Linienenden treten auch bei korrekten Vorlagen durch Wimpern,
  Augenbrauen und dekorative Linien auf. Sie sind ein Review-Hinweis, kein
  automatischer Fehler.

## Ergebnis

Die technische Segmentierung ist als Grundlage geeignet. Eine direkte
Auslieferung aller erkannten Regionen wäre für Kinder von drei bis fünf Jahren
nicht geeignet. Slice 2 muss kleine technische Regionen zu ungefähr 7 bis 14
logischen Malgruppen zusammenfassen oder als geschützte Dekoration markieren.

## Elefant-Pilot

Das Easy-Profil reduziert 32 technische Regionen auf fünf große Malgruppen:

- Kopf inklusive Rüssel und Nasenfläche
- linkes Ohr
- rechtes Ohr
- Körper inklusive Zehenflächen
- Schwanz

Augen, Lichtreflexe, Mund sowie die kleinen Vordergrunddekorationen bleiben
geschützt. Die kombinierte Debug-Vorschau wurde visuell geprüft: Die fünf
Gruppen sind groß, klar unterscheidbar und alle geschützten Details bleiben
weiß.
