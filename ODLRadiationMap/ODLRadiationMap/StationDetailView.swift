import SwiftUI

struct StationDetailView: View {
    let station: ODLStation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("Messwert") {
                    HStack {
                        Circle()
                            .fill(station.color)
                            .frame(width: 14, height: 14)
                        Text(station.displayValue)
                            .font(.title2.bold())
                    }
                    levelBar
                }

                Section("Station") {
                    labeledRow("Name", station.name)
                    labeledRow("Kennung", station.kenn)
                    labeledRow("Status", station.status.rawValue.capitalized)
                }

                Section("Koordinaten") {
                    labeledRow("Breitengrad",
                               String(format: "%.5f°", station.coordinate.latitude))
                    labeledRow("Längengrad",
                               String(format: "%.5f°", station.coordinate.longitude))
                }

                if let date = station.lastUpdate {
                    Section("Letzte Messung") {
                        Text(date.formatted(date: .abbreviated, time: .standard))
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Hintergrund") {
                    Text("Das ODL-Messnetz des Bundesamts für Strahlenschutz (BfS) besteht aus über 1.800 automatischen Messstationen, die kontinuierlich die Gamma-Ortsdosisleistung in Deutschland erfassen.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(station.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }

    private var levelBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(station.color)
                        .frame(width: barWidth(geo.size.width))
                }
            }
            .frame(height: 10)
            HStack {
                Text("0").font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Text("0.1").font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Text("0.3").font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Text("1.0 µSv/h").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    private func barWidth(_ total: CGFloat) -> CGFloat {
        guard let v = station.value else { return 0 }
        let clamped = min(v / 1.0, 1.0)
        return total * clamped
    }

    private func labeledRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}
