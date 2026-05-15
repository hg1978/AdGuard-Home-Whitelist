import Foundation
import CoreLocation
import SwiftUI

struct ODLStation: Identifiable, Codable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let value: Double?        // µSv/h
    let status: StationStatus
    let lastUpdate: Date?
    let kenn: String          // BfS station ID

    enum StationStatus: String, Codable {
        case normal = "normal"
        case elevated = "elevated"
        case alarm = "alarm"
        case offline = "offline"
        case unknown = "unknown"
    }

    var displayValue: String {
        guard let v = value else { return "–" }
        return String(format: "%.4f µSv/h", v)
    }

    var color: Color {
        guard let v = value else { return .gray }
        switch v {
        case ..<0.1:   return .green
        case 0.1..<0.3: return .yellow
        case 0.3..<1.0: return .orange
        default:        return .red
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, value, status, lastUpdate, kenn
        case longitude, latitude
    }

    init(id: String, name: String, coordinate: CLLocationCoordinate2D,
         value: Double?, status: StationStatus, lastUpdate: Date?, kenn: String) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.value = value
        self.status = status
        self.lastUpdate = lastUpdate
        self.kenn = kenn
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        kenn = try c.decode(String.self, forKey: .kenn)
        value = try c.decodeIfPresent(Double.self, forKey: .value)
        status = try c.decodeIfPresent(StationStatus.self, forKey: .status) ?? .unknown
        lastUpdate = try c.decodeIfPresent(Date.self, forKey: .lastUpdate)
        let lon = try c.decode(Double.self, forKey: .longitude)
        let lat = try c.decode(Double.self, forKey: .latitude)
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(kenn, forKey: .kenn)
        try c.encodeIfPresent(value, forKey: .value)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(lastUpdate, forKey: .lastUpdate)
        try c.encode(coordinate.longitude, forKey: .longitude)
        try c.encode(coordinate.latitude, forKey: .latitude)
    }
}

// MARK: - BfS GeoJSON response models

struct GeoJSONFeatureCollection: Codable {
    let features: [GeoJSONFeature]
}

struct GeoJSONFeature: Codable {
    let properties: ODLProperties
    let geometry: GeoJSONGeometry
}

struct GeoJSONGeometry: Codable {
    let coordinates: [Double]  // [lon, lat]
}

struct ODLProperties: Codable {
    let kenn: String
    let name: String?
    let plz: String?
    let mw: Double?            // Messwert µSv/h
    let mw_nn: Double?         // auf Meereshöhe normiert
    let end_measure: String?   // Zeitstempel
    let nuclide_name: String?
    let site_status: Int?      // 1 = in Betrieb

    enum CodingKeys: String, CodingKey {
        case kenn, name, plz, mw, mw_nn, end_measure, nuclide_name, site_status
    }
}
