import SwiftUI

struct LegendView: View {
    @Environment(\.dismiss) private var dismiss

    private let levels: [(color: Color, range: String, description: String)] = [
        (.green,  "< 0,10 µSv/h", "Normal (natürlicher Hintergrund)"),
        (.yellow, "0,10 – 0,30 µSv/h", "Leicht erhöht"),
        (.orange, "0,30 – 1,00 µSv/h", "Erhöht"),
        (.red,    "> 1,00 µSv/h", "Alarm"),
        (.gray,   "–", "Keine Daten / Offline"),
    ]

    var body: some View {
        NavigationView {
            List {
                Section("Messwert-Skala") {
                    ForEach(levels, id: \.range) { level in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(level.color)
                                .frame(width: 16, height: 16)
                                .overlay(Circle().strokeBorder(.white, lineWidth: 1))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.range).font(.subheadline.bold())
                                Text(level.description).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section("Datenquelle") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bundesamt für Strahlenschutz (BfS)")
                            .font(.subheadline.bold())
                        Text("Das ODL-Messnetz umfasst über 1.800 automatische Messstationen in Deutschland. Die Gammastrahlen-Ortsdosisleistung wird stündlich gemessen und veröffentlicht.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Aktualisierung: alle 5 Minuten")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Karte: © OpenStreetMap-Mitwirkende")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Legende")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }
}
