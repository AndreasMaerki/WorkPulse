import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var selectedClock: Clock?
  @State private var showDeleteAlert = false
  @State private var showResetAlert = false
  @State private var showExportDialog = false
  @State private var exportDocument: ClockCSVDocument?
  @State private var minimumDuration: Double

  init() {
    // Initialize with the current value from UserDefaults
    _minimumDuration = State(initialValue: UserDefaults.standard.double(forKey: "minimumTimeSegmentDuration"))
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        HStack {
          Text("Settings")
            .font(.largeTitle)

          Spacer()

          Button {
            prepareExportAll()
          } label: {
            Label("Export All", systemImage: "square.and.arrow.up")
          }
          .buttonStyle(.bordered)
        }

        clockManagementSection
        timeSegmentSettingsSection
      }
      .padding()
    }
    .alert("Delete Clock", isPresented: $showDeleteAlert) {
      Button("Cancel", role: .cancel) {}
      Button("Delete", role: .destructive) {
        deleteSelectedClock()
      }
    } message: {
      Text("Are you sure you want to delete this clock? This action cannot be undone.")
    }
    .alert("Reset Clock", isPresented: $showResetAlert) {
      Button("Cancel", role: .cancel) {}
      Button("Reset", role: .destructive) {
        resetSelectedClock()
      }
    } message: {
      Text("Are you sure you want to reset this clock? All time segments will be deleted.")
    }
    .fileExporter(
      isPresented: $showExportDialog,
      document: exportDocument,
      contentType: .commaSeparatedText,
      defaultFilename: exportDocument?.clockName ?? "clock_export"
    ) { result in
      handleExportResult(result)
    }
  }

  private var clockManagementSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Clock Management")
        .font(.headline)

      ForEach(viewModel.clocks) { clock in
        HStack {
          Circle()
            .fill(clock.color)
            .frame(width: 12, height: 12)

          Text(clock.name)
            .foregroundStyle(.secondary)

          Spacer()

          Text(clock.elapsedTime().formattedHHMMSS())
            .monospacedDigit()

          Menu {
            Button(role: .destructive) {
              showDeleteConfirmation(for: clock)
            } label: {
              Label("Delete", systemImage: "trash")
            }

            Button {
              showResetConfirmation(for: clock)
            } label: {
              Label("Reset", systemImage: "arrow.counterclockwise")
            }

            Button {
              prepareExport(for: clock)
            } label: {
              Label("Export CSV", systemImage: "square.and.arrow.up")
            }
          } label: {
            Image(systemName: "ellipsis.circle")
              .foregroundStyle(.secondary)
              .frame(width: 24, height: 24)
          }
          .menuStyle(.borderlessButton)
          .fixedSize()
        }
        .padding(8)
        .cardBackground()
      }
    }
  }

  private var timeSegmentSettingsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Time Segment Settings")
        .font(.headline)

      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text("Minimum Time Segment Duration")
            .font(.subheadline)
            .foregroundStyle(Theme.Colors.textSecondary)

          Image(systemName: "questionmark.circle")
            .foregroundStyle(Theme.Colors.textSecondary)
            .frame(width: 24, height: 24)
            .help("Time segments shorter than this duration will be automatically removed when stopping the clock. This helps prevent accidental short segments from being recorded.")
        }

        HStack {
          Slider(
            value: $minimumDuration,
            in: 0 ... 300,
            step: 10
          )
          .frame(width: 200)
          .onChange(of: minimumDuration) { _, newValue in
            viewModel.minimumTimeSegmentDuration = newValue
          }

          Text("\(Int(minimumDuration)) seconds")
            .monospacedDigit()
            .foregroundStyle(Theme.Colors.textSecondary)
        }
      }
      .padding(8)
      .cardBackground()
    }
  }

  // MARK: - Private Actions

  private func showDeleteConfirmation(for clock: Clock) {
    selectedClock = clock
    showDeleteAlert = true
  }

  private func showResetConfirmation(for clock: Clock) {
    selectedClock = clock
    showResetAlert = true
  }

  private func deleteSelectedClock() {
    if let clock = selectedClock {
      viewModel.deleteClock(clock)
    }
  }

  private func resetSelectedClock() {
    if let clock = selectedClock {
      viewModel.resetClock(clock)
    }
  }

  private func handleExportResult(_ result: Result<URL, Error>) {
    switch result {
    case let .success(url):
      print("Saved to \(url)")
    case let .failure(error):
      print(error.localizedDescription)
    }
  }

  private func prepareExport(for clock: Clock) {
    exportDocument = ClockCSVDocument(clock: clock)
    showExportDialog = true
  }

  private func prepareExportAll() {
    exportDocument = ClockCSVDocument(clocks: viewModel.clocks)
    showExportDialog = true
  }
}

struct ClockCSVDocument: FileDocument {
  static var readableContentTypes: [UTType] { [.commaSeparatedText] }

  struct TimeSegmentData: Sendable {
    let clockName: String
    let startTime: Date
    let endTime: Date?
    let note: String?
  }

  let clockName: String
  let segments: [TimeSegmentData]

  init(clock: Clock?) {
    clockName = clock?.name ?? "Unknown Clock"
    segments = clock?.timeSegments.map { segment in
      TimeSegmentData(
        clockName: clock?.name ?? "Unknown Clock",
        startTime: segment.startTime,
        endTime: segment.endTime,
        note: segment.note
      )
    } ?? []
  }

  init(clocks: [Clock]) {
    clockName = "All Clocks"
    segments = clocks.flatMap { clock in
      clock.timeSegments.map { segment in
        TimeSegmentData(
          clockName: clock.name,
          startTime: segment.startTime,
          endTime: segment.endTime,
          note: segment.note
        )
      }
    }
  }

  init(configuration: ReadConfiguration) throws {
    clockName = "Unknown Clock"
    segments = []
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    let header = "Clock Name,Start Time,End Time,Note\n"
    let rows = segments.map { segment in
      let endTime = segment.endTime?.formatted(date: .numeric, time: .standard) ?? "Running"
      let note = segment.note?.replacingOccurrences(of: ",", with: ";") ?? ""
      return "\(segment.clockName),\(segment.startTime.formatted(date: .numeric, time: .standard)),\(endTime),\(note)"
    }
    let content = header + rows.joined(separator: "\n")
    return FileWrapper(regularFileWithContents: content.data(using: .utf8)!)
  }
}

#Preview {
  SettingsView()
    .environment(GlobalEnvironment())
}
