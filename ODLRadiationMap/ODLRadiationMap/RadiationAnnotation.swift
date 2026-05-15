import MapKit
import SwiftUI

final class RadiationAnnotation: NSObject, MKAnnotation {
    let station: ODLStation
    var coordinate: CLLocationCoordinate2D { station.coordinate }
    var title: String? { station.name }
    var subtitle: String? { station.displayValue }

    init(station: ODLStation) {
        self.station = station
        super.init()
    }
}

final class RadiationAnnotationView: MKAnnotationView {
    static let reuseID = "RadiationAnnotation"

    override var annotation: MKAnnotation? {
        didSet { reconfigure() }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        layer.cornerRadius = 11
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        reconfigure()
    }

    required init?(coder: NSCoder) { nil }

    private func reconfigure() {
        guard let ra = annotation as? RadiationAnnotation else { return }
        backgroundColor = UIColor(ra.station.color)
    }
}
