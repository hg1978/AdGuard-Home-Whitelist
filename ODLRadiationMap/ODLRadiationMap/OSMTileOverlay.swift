import MapKit

/// OpenStreetMap tile overlay – uses the standard OSM tile server.
final class OSMTileOverlay: MKTileOverlay {
    init() {
        // {z}/{x}/{y} template – MKTileOverlay uses {z}, {x}, {y}
        super.init(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
        canReplaceMapContent = true
        maximumZ = 19
        tileSize = CGSize(width: 256, height: 256)
    }
}
