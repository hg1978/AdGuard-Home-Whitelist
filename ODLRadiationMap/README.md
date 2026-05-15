# ODL Strahlenkarte – iOS App

iPhone-App zur Anzeige der aktuellen Ortsdosisleistungs-Messungen des BfS ODL-Netzes auf einer OpenStreetMap-Karte.

## Features

- **OpenStreetMap-Karte** als Basis (OSM-Tile-Server via MKTileOverlay)
- **1.800+ Messstationen** aus dem BfS ODL-Netz
- **Farbkodierte Marker** nach Messwert
- **Stations-Detail** mit Messwert, Balkenanzeige und Metadaten
- **Stationsliste** mit Suche und Sortierung (Messwert / Name)
- **Legende** mit Erklärung der Dosisstufen
- **Automatische Aktualisierung** alle 5 Minuten

## Farbskala

| Farbe  | Messwert        | Bedeutung                  |
|--------|-----------------|----------------------------|
| Grün   | < 0,10 µSv/h   | Normal (natürl. Hintergrund)|
| Gelb   | 0,10–0,30 µSv/h | Leicht erhöht              |
| Orange | 0,30–1,00 µSv/h | Erhöht                     |
| Rot    | > 1,00 µSv/h   | Alarm                      |
| Grau   | –               | Offline / keine Daten      |

## Datenquelle

**Bundesamt für Strahlenschutz (BfS)** – Open Data WFS-API  
Endpunkt: `https://www.imis.bfs.de/ogc/opendata/ows`  
Typ: `opendata:odlinfo_odl_1h_latest`

## Einrichtung

1. `ODLRadiationMap/ODLRadiationMap.xcodeproj` in Xcode öffnen
2. Team in den Signing-Einstellungen auswählen
3. Auf iPhone deployen (iOS 17+)

## Anforderungen

- Xcode 15+
- iOS 17+
- Keine Drittanbieter-Abhängigkeiten (nur Apple-Frameworks: SwiftUI, MapKit)

## Datenschutz

- Standort-Berechtigung optional (nur für „Mein Standort" auf der Karte)
- Keine Daten werden an Dritte übermittelt
- Kartendaten: © OpenStreetMap-Mitwirkende (ODbL)
