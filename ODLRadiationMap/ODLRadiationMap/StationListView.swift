import SwiftUI

struct StationListView: View {
    let stations: [ODLStation]
    @Binding var selected: ODLStation?
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .value
    @Environment(\.dismiss) private var dismiss

    enum SortOrder: String, CaseIterable {
        case value = "Messwert"
        case name = "Name"
    }

    private var filtered: [ODLStation] {
        let base = stations.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
        return base.sorted {
            switch sortOrder {
            case .value:
                return ($0.value ?? -1) > ($1.value ?? -1)
            case .name:
                return $0.name < $1.name
            }
        }
    }

    var body: some View {
        NavigationView {
            List(filtered) { station in
                Button {
                    selected = station
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(station.color)
                            .frame(width: 12, height: 12)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(station.name)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text(station.kenn)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(station.displayValue)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Station suchen")
            .navigationTitle("Messstationen (\(stations.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Sortierung", selection: $sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }
}
