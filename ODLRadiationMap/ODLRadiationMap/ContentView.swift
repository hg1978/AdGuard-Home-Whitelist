import SwiftUI

struct ContentView: View {
    @StateObject private var service = ODLService()
    @State private var selectedStation: ODLStation?
    @State private var showLegend = false
    @State private var showList = false

    var body: some View {
        ZStack(alignment: .top) {
            MapView(stations: service.stations, selectedStation: $selectedStation)
                .ignoresSafeArea()

            // Top status bar
            VStack(spacing: 0) {
                statusBar
                Spacer()
                bottomBar
            }
        }
        .sheet(item: $selectedStation) { station in
            StationDetailView(station: station)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showList) {
            StationListView(stations: service.stations, selected: $selectedStation)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showLegend) {
            LegendView()
                .presentationDetents([.medium])
        }
        .task {
            service.startAutoRefresh()
        }
        .onDisappear {
            service.stopAutoRefresh()
        }
    }

    private var statusBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("BfS ODL-Messnetz")
                    .font(.headline)
                if let last = service.lastRefresh {
                    Text("Aktualisiert \(last.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if service.isLoading {
                ProgressView()
            } else {
                Button {
                    Task { await service.fetchStations() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if let err = service.errorMessage {
                Label(err, systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.regularMaterial, in: Capsule())
            } else if let stats = service.statistics {
                statsChip("Stationen", "\(service.stations.count)")
                statsChip("Ø", String(format: "%.4f µSv/h", stats.avg))
                statsChip("Max", String(format: "%.4f", stats.max))
            }
            Spacer()
            Button {
                showLegend = true
            } label: {
                Image(systemName: "info.circle.fill")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            .padding(10)
            .background(.regularMaterial, in: Circle())

            Button {
                showList = true
            } label: {
                Image(systemName: "list.bullet")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            .padding(10)
            .background(.regularMaterial, in: Circle())
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
    }

    private func statsChip(_ label: String, _ value: String) -> some View {
        VStack(spacing: 0) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 11, weight: .bold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.regularMaterial, in: Capsule())
    }
}
