import Foundation
import CoreLocation

@MainActor
class ODLService: ObservableObject {
    @Published var stations: [ODLStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastRefresh: Date?

    private let baseURL = "https://www.imis.bfs.de/ogc/opendata/ows"
    private var refreshTask: Task<Void, Never>?

    func fetchStations() async {
        isLoading = true
        errorMessage = nil

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "service", value: "WFS"),
            URLQueryItem(name: "version", value: "2.0.0"),
            URLQueryItem(name: "request", value: "GetFeature"),
            URLQueryItem(name: "typeName", value: "opendata:odlinfo_odl_1h_latest"),
            URLQueryItem(name: "outputFormat", value: "application/json"),
        ]

        guard let url = components.url else {
            errorMessage = "Ungültige URL"
            isLoading = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                errorMessage = "Server-Fehler"
                isLoading = false
                return
            }

            let collection = try JSONDecoder().decode(GeoJSONFeatureCollection.self, from: data)
            stations = collection.features.compactMap { feature -> ODLStation? in
                guard feature.geometry.coordinates.count >= 2 else { return nil }
                let lon = feature.geometry.coordinates[0]
                let lat = feature.geometry.coordinates[1]
                let props = feature.properties

                let status: ODLStation.StationStatus
                if props.site_status == 1 {
                    if let v = props.mw {
                        status = v >= 1.0 ? .alarm : v >= 0.3 ? .elevated : .normal
                    } else {
                        status = .offline
                    }
                } else {
                    status = .offline
                }

                var lastUpdate: Date?
                if let ts = props.end_measure {
                    lastUpdate = ISO8601DateFormatter().date(from: ts)
                }

                return ODLStation(
                    id: props.kenn,
                    name: props.name ?? props.kenn,
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    value: props.mw,
                    status: status,
                    lastUpdate: lastUpdate,
                    kenn: props.kenn
                )
            }
            lastRefresh = Date()
        } catch {
            errorMessage = "Ladefehler: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func startAutoRefresh(interval: TimeInterval = 300) {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                await fetchStations()
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    var statistics: (min: Double, max: Double, avg: Double)? {
        let values = stations.compactMap(\.value)
        guard !values.isEmpty else { return nil }
        return (values.min()!, values.max()!, values.reduce(0, +) / Double(values.count))
    }
}
