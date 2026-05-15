import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let stations: [ODLStation]
    @Binding var selectedStation: ODLStation?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator

        // OpenStreetMap tile layer
        let osm = OSMTileOverlay()
        map.addOverlay(osm, level: .aboveLabels)

        // Center on Germany
        let germany = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.2, longitude: 10.4),
            span: MKCoordinateSpan(latitudeDelta: 9, longitudeDelta: 9)
        )
        map.setRegion(germany, animated: false)
        map.showsUserLocation = true
        map.mapType = .mutedStandard   // base tiles are replaced by OSM overlay

        map.register(RadiationAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: RadiationAnnotationView.reuseID)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        let existing = Set(map.annotations.compactMap { ($0 as? RadiationAnnotation)?.station.id })
        let incoming = Set(stations.map(\.id))

        let toRemove = map.annotations.filter {
            guard let ra = $0 as? RadiationAnnotation else { return false }
            return !incoming.contains(ra.station.id)
        }
        map.removeAnnotations(toRemove)

        let toAdd = stations.filter { !existing.contains($0.id) }
            .map { RadiationAnnotation(station: $0) }
        map.addAnnotations(toAdd)

        // Update values on existing annotations
        for ann in map.annotations.compactMap({ $0 as? RadiationAnnotation }) {
            if let updated = stations.first(where: { $0.id == ann.station.id }) {
                if let view = map.view(for: ann) as? RadiationAnnotationView {
                    view.backgroundColor = UIColor(updated.color)
                }
            }
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tile = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: tile)
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView,
                     viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let ra = annotation as? RadiationAnnotation else { return nil }
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: RadiationAnnotationView.reuseID,
                for: ra) as? RadiationAnnotationView
            return view
        }

        func mapView(_ mapView: MKMapView,
                     annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {
            guard let ra = view.annotation as? RadiationAnnotation else { return }
            parent.selectedStation = ra.station
        }
    }
}
